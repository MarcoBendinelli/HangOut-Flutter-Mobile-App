import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';
import '../cache/cache.dart';
import '../models/user.dart';

/// {@template sign_up_with_email_and_password_failure}
/// Thrown if during the sign up process if a failure occurs.
/// {@endtemplate}
class SignUpWithEmailAndPasswordFailure implements Exception {
  /// {@macro sign_up_with_email_and_password_failure}
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An error occured.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/createUserWithEmailAndPassword.html
  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password.',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_email_and_password_failure}
/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
/// {@endtemplate}
class LogInWithEmailAndPasswordFailure implements Exception {
  /// {@macro log_in_with_email_and_password_failure}
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An error occured.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class LogInWithGoogleFailure implements Exception {
  /// {@macro log_in_with_google_failure}
  const LogInWithGoogleFailure([
    this.message = 'An error occured.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class LogInWithTwitterFailure implements Exception {
  /// {@macro log_in_with_google_failure}
  const LogInWithTwitterFailure([
    this.message = 'An error occured.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithTwitterFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithTwitterFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithTwitterFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithTwitterFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithTwitterFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithTwitterFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithTwitterFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithTwitterFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithTwitterFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithTwitterFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    bool testMode = false,
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firebaseFirestore,
    FirebaseStorage? firebaseStorage,
    TwitterLogin? twitterLogin,
  })  : _cache = cache ?? CacheClient(),
        _testMode = testMode,
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _db = firebaseFirestore ?? FirebaseFirestore.instance,
        referenceDirImages = firebaseStorage?.ref().child("users") ??
            FirebaseStorage.instance.ref().child("users"),
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        _twitterLogin = twitterLogin ??
            TwitterLogin(
                apiKey: "E3Y35G206ZT8TJ1MyXCYaSPiY",
                apiSecretKey:
                    "aBaEIF05cClxiRtnrCf4ePcBPFio6g3od0kSAnzuy4Aum3heSD",
                redirectURI: "hangout://");

  final CacheClient _cache;
  final FirebaseFirestore _db;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final Reference referenceDirImages;
  final GoogleSignIn _googleSignIn;
  final TwitterLogin _twitterLogin;
  final bool _testMode;
  late String _name;
  XFile? _photo;

  /// Whether or not the current environment is web
  /// Should only be overridden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUp(
      {required String email,
      required String password,
      required String name,
      XFile? photo}) async {
    _name = name;
    _photo = photo;
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      late final GoogleSignInAccount? googleUser;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  Future<void> logInWithTwitter() async {
    late final firebase_auth.AuthCredential credential;
    late final AuthResult? twitterUser;
    try {
      twitterUser = await _twitterLogin.loginV2();
      if (twitterUser.status == TwitterLoginStatus.loggedIn) {
        credential = firebase_auth.TwitterAuthProvider.credential(
            accessToken: twitterUser.authToken!,
            secret: twitterUser.authTokenSecret!);
      }

      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithTwitterFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithTwitterFailure();
    }
  }

  /// Save user data to firestore
  Future<void> saveUserToDB(User user) async {
    var userDocRef = _db.collection('users').doc(user.id);
    var doc = await userDocRef.get();
    String imageURL = "";
    if (!doc.exists) {
      try {
        if (_photo != null) {
          imageURL = await uploadImage(_photo!, user.id);
        }
        await _db.collection('users').doc(user.id).set({
          'email': user.email,
          'name': user.name ?? _name,
          'photo': user.photo ?? imageURL,
          'interests': [],
          'groups': [],
          'events': [],
          'description': "Hello! I'm a new user",
          'notifications_group_chat': true,
          'notifications_event_chat': true,
          'notifications_join_group': true,
          'notifications_invite_event': true,
          'notifications_public_event': true,
          'notifications_public_group': true,
          'notifications_push': true,
        });
        if (kDebugMode) {
          debugPrint('......saved user data.......');
        }
      } on Exception {
        debugPrint("Error while saving the user");
      }
    } else {
      debugPrint("......logging existing user.......");
    }
  }

  Future<String> uploadImage(XFile file, String id) async {
    String imageURL;

    Reference imageRef = referenceDirImages.child(id);

    try {
      //store file in reference
      await imageRef.putFile(File(file.path));
      imageURL = await imageRef.getDownloadURL();
      return imageURL;
    } on Exception {
      debugPrint("Error in uploading the image");
      return "";
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }

  /// Delete current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> delete() async {
    try {
      String id = _firebaseAuth.currentUser!.uid;
      List<Event> events = await getEventsOfUser(id);
      List<Group> groups = await getGroupsOfUser(id);
      for (Event event in events) {
        if (event.creatorId == id) {
          await deleteSingleEvent(eventId: event.id);
        } else {
          await removeEventfromUser(user: id, eventId: event.id);
          // await removeUserImageFromChat(
          //     collectionName: "events", idDoc: event.id, id: id);
        }
      }
      for (Group group in groups) {
        if (group.creatorId == id) {
          await deleteSingleGroup(groupId: group.id);
        } else {
          await removeGroupfromUser(groupId: group.id, userId: id);
          // await removeUserImageFromChat(
          //     collectionName: "groups", idDoc: group.id, id: id);
        }
      }
      await _db.collection('users').doc(id).delete();
      await _db
          .collectionGroup('chat')
          .where('sender_id', isEqualTo: id)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var documentSnapshot in querySnapshot.docs) {
          documentSnapshot.reference.update({"sender_photo": ""});
        }
      });
      await Future.wait([
        _firebaseAuth.currentUser!.delete(),
        _testMode ? Future(() => null) : _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }

  /// To get the groups where the current User is inside
  Future<List<Event>> getEventsOfUser(String userId) async {
    return _db
        .collection('events')
        .where("members", arrayContains: userId)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    });
  }

  Future<List<Group>> getGroupsOfUser(String userId) async {
    return _db
        .collection('groups')
        .where("members", arrayContains: userId)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) => Group.fromSnapshot(doc)).toList();
    });
  }

  Future<void> removeEventfromUser(
      {required String user, required String eventId}) async {
    /// Remove the id of the new event from the user events Array
    await _db.collection("users").doc(user).update({
      "events": FieldValue.arrayRemove([eventId]),
    });

    /// remove the id of the user from event members
    await _db.collection("events").doc(eventId).update({
      "members": FieldValue.arrayRemove([user]),
      "num_participants": FieldValue.increment(-1)
    });
  }

  Future<void> removeGroupfromUser(
      {required String groupId, required String userId}) async {
    /// Remove the id of the new event from the user events Array
    await _db.collection("users").doc(userId).update({
      "groups": FieldValue.arrayRemove([groupId]),
    });

    /// remove the id of the user from event members
    await _db.collection("groups").doc(groupId).update({
      "members": FieldValue.arrayRemove([userId]),
      "num_participants": FieldValue.increment(-1)
    });
  }

  Future<void> deleteSingleEvent({required String eventId}) async {
    List<String> ids = [];

    await _db
        .collection('users')
        .where("events", arrayContains: eventId)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          ids.add(docSnapshot.id);
        }
      },
    );

    for (final idUser in ids) {
      /// Remove the id of the new event from the user events Array
      await _db.collection("users").doc(idUser).update({
        "events": FieldValue.arrayRemove([eventId]),
      });
    }

    /// Delete all the messages inside the chat
    var collection = _db.collection("events").doc(eventId).collection("chat");
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    try {
      await referenceDirImages.child(eventId).delete();
    } on Exception catch (_) {}

    /// Finally delete the group collection
    await _db.collection("events").doc(eventId).delete();
  }

  Future<void> deleteSingleGroup({required String groupId}) async {
    List<String> ids = [];

    await _db
        .collection('users')
        .where("groups", arrayContains: groupId)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          ids.add(docSnapshot.id);
        }
      },
    );

    for (final idUser in ids) {
      /// Remove the id of the new group from the user groups Array
      await _db.collection("users").doc(idUser).update({
        "groups": FieldValue.arrayRemove([groupId]),
      });
    }

    /// Delete all the messages inside the chat

    var collection = _db.collection("groups").doc(groupId).collection("chat");
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    try {
      await referenceDirImages.child(groupId).delete();
    } on Exception catch (_) {}

    /// Finally delete the group collection
    await _db.collection("groups").doc(groupId).delete();
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
