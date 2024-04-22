import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:mocktail/mocktail.dart';

class MockTwitterLogin extends Mock implements TwitterLogin {}

class MocktailFirebaseAuth extends Mock implements auth.FirebaseAuth {}

class MocktailGoogleSignin extends Mock implements GoogleSignIn {}

void main() {
  late FirebaseFirestore firebaseFirestore;
  late FirebaseStorage firebaseStorage;
  late GoogleSignIn googleSignIn;
  late TwitterLogin twitterLogin;
  late auth.FirebaseAuth firebaseAuth;
  late AuthenticationRepository authenticationRepository;
  const String email = "test@test.it";
  const String name = "Tester";
  const String password = "password";

  group("auth repository", () {
    setUp(() async {
      firebaseFirestore = FakeFirebaseFirestore();
      firebaseStorage = MockFirebaseStorage();
      firebaseAuth = MockFirebaseAuth();
      googleSignIn = MockGoogleSignIn();
      twitterLogin = MockTwitterLogin();
      when(
        () => twitterLogin.loginV2(),
      ).thenAnswer((_) async {
        return AuthResult(
            status: TwitterLoginStatus.loggedIn,
            authToken: "",
            authTokenSecret: "");
      });
      authenticationRepository = AuthenticationRepository(
          testMode: true,
          firebaseAuth: firebaseAuth,
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage,
          googleSignIn: googleSignIn,
          twitterLogin: twitterLogin);
    });
    test("signup with email and password", () async {
      await authenticationRepository.signUp(
          email: email, password: password, name: name);
      expect(firebaseAuth.currentUser!.email, email);
    });
    test("logIn with google", () async {
      await authenticationRepository.logInWithGoogle();
      expect(googleSignIn.currentUser, isNotNull);
      expect(firebaseAuth.currentUser, isNotNull);
    });
    test("logIn with twitter", () async {
      await authenticationRepository.logInWithTwitter();
      verify(() => twitterLogin.loginV2()).called(1);
      expect(firebaseAuth.currentUser, isNotNull);
    });
    test("logIn with email and password", () async {
      ///create account and signout
      await authenticationRepository.signUp(
          email: email, password: password, name: name);
      expect(firebaseAuth.currentUser!.email, email);
      await firebaseAuth.signOut();
      expect(firebaseAuth.currentUser, isNull);

      ///attempt sign in with credentials
      await authenticationRepository.logInWithEmailAndPassword(
          email: email, password: password);
      expect(firebaseAuth.currentUser!.email, email);
    });
    test("save new user to db", () async {
      ///create account and signout
      await authenticationRepository.signUp(
          email: email, password: password, name: name);
      expect(firebaseAuth.currentUser!.email, email);
      await authenticationRepository.saveUserToDB(
          const User(id: "userxId", email: email, name: name, photo: ""));

      final snapshot =
          await firebaseFirestore.collection("users").doc("userxId").get();
      final userData = UserData.fromSnapshot(snapshot);
      expect(userData.name, name);
      expect(userData.email, email);
      expect(userData.photo, "");
      expect(userData.interests, []);
      expect(userData.notificationsEventChat, true);
      expect(userData.notificationsGroupChat, true);
      expect(userData.notificationsInviteEvent, true);
      expect(userData.notificationsJoinGroup, true);
      expect(userData.notificationsPublicEvent, true);
      expect(userData.notificationsPublicGroup, true);
      expect(userData.notificationsPush, true);

      ///attempt sign in with credentials
      await authenticationRepository.logInWithEmailAndPassword(
          email: email, password: password);
      expect(firebaseAuth.currentUser!.email, email);
    });
    test("save old user to db does not modify", () async {
      ///create account and signout
      await authenticationRepository.signUp(
          email: email, password: password, name: name);
      expect(firebaseAuth.currentUser!.email, email);
      await authenticationRepository.saveUserToDB(
          const User(id: "userxId", email: email, name: name, photo: ""));

      ///try to relog same id with different values and check they are not changed
      await authenticationRepository.saveUserToDB(
          const User(id: "userxId", email: "email", name: "name", photo: ""));

      final snapshot =
          await firebaseFirestore.collection("users").doc("userxId").get();
      final userData = UserData.fromSnapshot(snapshot);
      expect(userData.name, name);
      expect(userData.email, email);
      expect(userData.photo, "");
      expect(userData.interests, []);
      expect(userData.notificationsEventChat, true);
      expect(userData.notificationsGroupChat, true);
      expect(userData.notificationsInviteEvent, true);
      expect(userData.notificationsJoinGroup, true);
      expect(userData.notificationsPublicEvent, true);
      expect(userData.notificationsPublicGroup, true);
      expect(userData.notificationsPush, true);

      ///attempt sign in with credentials
      await authenticationRepository.logInWithEmailAndPassword(
          email: email, password: password);
      expect(firebaseAuth.currentUser!.email, email);
    });
    test("save new user to with photo", () async {
      ///create account and signout
      await authenticationRepository.signUp(
          email: email,
          password: password,
          name: name,
          photo: XFile("test_resources/example.jpg"));
      expect(firebaseAuth.currentUser!.email, email);
      await authenticationRepository
          .saveUserToDB(const User(id: "userxId", email: email, name: name));

      final snapshot =
          await firebaseFirestore.collection("users").doc("userxId").get();
      final userData = UserData.fromSnapshot(snapshot);
      expect(userData.name, name);
      expect(userData.email, email);
      expect(userData.photo.isNotEmpty, true);
      expect(userData.interests, []);
      expect(userData.notificationsEventChat, true);
      expect(userData.notificationsGroupChat, true);
      expect(userData.notificationsInviteEvent, true);
      expect(userData.notificationsJoinGroup, true);
      expect(userData.notificationsPublicEvent, true);
      expect(userData.notificationsPublicGroup, true);
      expect(userData.notificationsPush, true);

      ///attempt sign in with credentials
      await authenticationRepository.logInWithEmailAndPassword(
          email: email, password: password);
      expect(firebaseAuth.currentUser!.email, email);
    });
    test("delete user owner of groups and event", () async {
      ///create account and signout
      await authenticationRepository.signUp(
          email: email,
          password: password,
          name: name,
          photo: XFile("test_resources/example.jpg"));
      expect(firebaseAuth.currentUser!.email, email);
      String id = firebaseAuth.currentUser!.uid;
      await authenticationRepository
          .saveUserToDB(User(id: id, email: email, name: name));

      ///add stuff to user for deletion

      await firebaseFirestore.collection("users").doc(id).update({
        // "name": "user1",
        // "email": "user1@mail.com",
        "description": "tester description",
        // "photo": "",
        "interests": <String>["food", "party"],
        "events": <String>["event1Id"],
        "groups": <String>["group1Id"],
        'notifications_group_chat': true,
        'notifications_event_chat': true,
        'notifications_join_group': true,
        'notifications_invite_event': true,
        'notifications_public_event': true,
        'notifications_public_group': true,
        'notifications_push': true,
      });
      await firebaseFirestore.collection("users").doc("user1Id").set({
        "name": "user1",
        "email": "user1@mail.com",
        "description": "tester description",
        "photo": "",
        "interests": <String>["food", "party"],
        "events": <String>["event1Id"],
        "groups": <String>["group1Id"],
        'notifications_group_chat': true,
        'notifications_event_chat': true,
        'notifications_join_group': true,
        'notifications_invite_event': true,
        'notifications_public_event': true,
        'notifications_public_group': true,
        'notifications_push': true,
      });
      await firebaseFirestore.collection("groups").doc("group1Id").set({
        "num_participants": 2,
        "id": "group1Id",
        "name": "group1",
        "creator_id": id,
        "caption": "group1Caption",
        "private": false,
        "interests": <String>["food", "music"],
        "photo": "",
        "members": <String>[id, "user1Id"],
      });
      await firebaseFirestore.collection("events").doc("event1Id").set({
        "num_participants": 2,
        "id": "event1Id",
        "name": "event1",
        "creator_id": id,
        "description": "event1Caption",
        "private": false,
        "category": "sport",
        "photo": "",
        "date": Timestamp.fromDate(DateTime(2022, 10, 30, 18, 30)),
        "location": const GeoPoint(0, 0),
        "locationName": "test location name",
        "members": <String>[id, "user1Id"],
      });

      ///attempt sign in with credentials
      await authenticationRepository.delete();

      ///Check that event and group do not exists anymore
      final eventSnapshot =
          await firebaseFirestore.collection("events").doc("event1Id").get();
      expect(eventSnapshot.exists, false);
      final groupSnapshot =
          await firebaseFirestore.collection("groups").doc("group1Id").get();
      expect(groupSnapshot.exists, false);
    });
    test("delete user participant to groups and event", () async {
      ///create account and signout
      await authenticationRepository.signUp(
          email: email,
          password: password,
          name: name,
          photo: XFile("test_resources/example.jpg"));
      expect(firebaseAuth.currentUser!.email, email);
      String id = firebaseAuth.currentUser!.uid;
      await authenticationRepository
          .saveUserToDB(User(id: id, email: email, name: name));

      ///add stuff to user for deletion

      await firebaseFirestore.collection("users").doc(id).update({
        // "name": "user1",
        // "email": "user1@mail.com",
        "description": "tester description",
        // "photo": "",
        "interests": <String>["food", "party"],
        "events": <String>["event1Id"],
        "groups": <String>["group1Id"],
        'notifications_group_chat': true,
        'notifications_event_chat': true,
        'notifications_join_group': true,
        'notifications_invite_event': true,
        'notifications_public_event': true,
        'notifications_public_group': true,
        'notifications_push': true,
      });
      await firebaseFirestore.collection("users").doc("user1Id").set({
        "name": "user1",
        "email": "user1@mail.com",
        "description": "tester description",
        "photo": "",
        "interests": <String>["food", "party"],
        "events": <String>["event1Id"],
        "groups": <String>["group1Id"],
        'notifications_group_chat': true,
        'notifications_event_chat': true,
        'notifications_join_group': true,
        'notifications_invite_event': true,
        'notifications_public_event': true,
        'notifications_public_group': true,
        'notifications_push': true,
      });
      await firebaseFirestore.collection("groups").doc("group1Id").set({
        "num_participants": 2,
        "id": "group1Id",
        "name": "group1",
        "creator_id": "user1Id",
        "caption": "group1Caption",
        "private": false,
        "interests": <String>["food", "music"],
        "photo": "",
        "members": <String>[id, "user1Id"],
      });
      await firebaseFirestore
          .collection("groups")
          .doc("group1Id")
          .collection("chat")
          .doc("chatId")
          .set({
        "sender_id": id,
      });
      await firebaseFirestore.collection("events").doc("event1Id").set({
        "num_participants": 2,
        "id": "event1Id",
        "name": "event1",
        "creator_id": "user1Id",
        "description": "event1Caption",
        "private": false,
        "category": "sport",
        "photo": "",
        "date": Timestamp.fromDate(DateTime(2022, 10, 30, 18, 30)),
        "location": const GeoPoint(0, 0),
        "locationName": "test location name",
        "members": <String>[id, "user1Id"],
      });

      ///attempt sign in with credentials
      await authenticationRepository.delete();

      ///Check that event and group still exists
      final eventSnapshot =
          await firebaseFirestore.collection("events").doc("event1Id").get();
      final event = Event.fromSnapshot(eventSnapshot);
      final groupSnapshot =
          await firebaseFirestore.collection("groups").doc("group1Id").get();
      final group = Group.fromSnapshot(groupSnapshot);
      expect(event.members!.length, 1);
      expect(event.members!.first, "user1Id");
      expect(group.members!.length, 1);
      expect(group.members!.first, "user1Id");
    });

    group('LogInWithGoogleFailure', () {
      test(
          'should return LogInWithGoogleFailure with specific error message for valid codes',
          () {
        expect(
          LogInWithGoogleFailure.fromCode(
                  'account-exists-with-different-credential')
              .message,
          'Account exists with different credentials.',
        );

        expect(
          LogInWithGoogleFailure.fromCode('invalid-credential').message,
          'The credential received is malformed or has expired.',
        );

        expect(
          LogInWithGoogleFailure.fromCode('operation-not-allowed').message,
          'Operation is not allowed.  Please contact support.',
        );

        expect(
          LogInWithGoogleFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support for help.',
        );

        expect(
          LogInWithGoogleFailure.fromCode('user-not-found').message,
          'Email is not found, please create an account.',
        );

        expect(
          LogInWithGoogleFailure.fromCode('wrong-password').message,
          'Incorrect password, please try again.',
        );

        expect(
          LogInWithGoogleFailure.fromCode('invalid-verification-code').message,
          'The credential verification code received is invalid.',
        );

        expect(
          LogInWithGoogleFailure.fromCode('invalid-verification-id').message,
          'The credential verification ID received is invalid.',
        );

        // Test the default case
        expect(
          LogInWithGoogleFailure.fromCode('non-existent-code').message,
          'An error occured.',
        );
      });

      test(
          'should return LogInWithGoogleFailure without a specific error message for an empty code',
          () {
        expect(
          LogInWithGoogleFailure.fromCode('').message,
          'An error occured.',
        );
      });
    });
    group('LogInWithTwitterFailure', () {
      test(
          'should return LogInWithTwitterFailure with specific error message for valid codes',
          () {
        expect(
          LogInWithTwitterFailure.fromCode(
                  'account-exists-with-different-credential')
              .message,
          'Account exists with different credentials.',
        );

        expect(
          LogInWithTwitterFailure.fromCode('invalid-credential').message,
          'The credential received is malformed or has expired.',
        );

        expect(
          LogInWithTwitterFailure.fromCode('operation-not-allowed').message,
          'Operation is not allowed.  Please contact support.',
        );

        expect(
          LogInWithTwitterFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support for help.',
        );

        expect(
          LogInWithTwitterFailure.fromCode('user-not-found').message,
          'Email is not found, please create an account.',
        );

        expect(
          LogInWithTwitterFailure.fromCode('wrong-password').message,
          'Incorrect password, please try again.',
        );

        expect(
          LogInWithTwitterFailure.fromCode('invalid-verification-code').message,
          'The credential verification code received is invalid.',
        );

        expect(
          LogInWithTwitterFailure.fromCode('invalid-verification-id').message,
          'The credential verification ID received is invalid.',
        );

        // Test the default case
        expect(
          LogInWithTwitterFailure.fromCode('non-existent-code').message,
          'An error occured.',
        );
      });

      test(
          'should return LogInWithGoogleFailure without a specific error message for an empty code',
          () {
        expect(
          LogInWithGoogleFailure.fromCode('').message,
          'An error occured.',
        );
      });
    });

    group('LogInWithEmailAndPasswordFailure', () {
      test(
          'should return LogInWithEmailAndPasswordFailure with specific error message for valid codes',
          () {
        expect(
          LogInWithEmailAndPasswordFailure.fromCode('invalid-email').message,
          'Email is not valid or badly formatted.',
        );

        expect(
          LogInWithEmailAndPasswordFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support for help.',
        );

        expect(
          LogInWithEmailAndPasswordFailure.fromCode('user-not-found').message,
          'Email is not found, please create an account.',
        );

        expect(
          LogInWithEmailAndPasswordFailure.fromCode('wrong-password').message,
          'Incorrect password, please try again.',
        );

        // Test the default case
        expect(
          LogInWithEmailAndPasswordFailure.fromCode('non-existent-code')
              .message,
          'An error occured.',
        );
      });

      test(
          'should return LogInWithEmailAndPasswordFailure with a default error message for an empty code',
          () {
        expect(
          LogInWithEmailAndPasswordFailure.fromCode('').message,
          'An error occured.',
        );
      });
    });

    group('SignUpWithEmailAndPasswordFailure', () {
      test(
          'should return SignUpWithEmailAndPasswordFailure with specific error message for valid codes',
          () {
        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('invalid-email').message,
          'Email is not valid or badly formatted.',
        );

        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support for help.',
        );

        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('email-already-in-use')
              .message,
          'An account already exists for that email.',
        );

        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('operation-not-allowed')
              .message,
          'Operation is not allowed.  Please contact support.',
        );

        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('weak-password').message,
          'Please enter a stronger password.',
        );

        // Test the default case
        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('non-existent-code')
              .message,
          'An error occured.',
        );
      });

      test(
          'should return SignUpWithEmailAndPasswordFailure with a default error message for an empty code',
          () {
        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('').message,
          'An error occured.',
        );
      });
    });
    group("fail twitter login with auth expection", () {
      setUp(() => {
            when(
              () => twitterLogin.loginV2(),
            ).thenThrow(auth.FirebaseAuthException(
                code: "account-exists-with-different-credential"))
          });
      test("throws login with twitter failures", () async {
        expect(
            () => authenticationRepository.logInWithTwitter(),
            throwsA(const LogInWithTwitterFailure(
                "Account exists with different credentials.")));
      });
    });

    group("fail signup with email and password", () {
      final scopeFirebaseAuth = MocktailFirebaseAuth();
      late AuthenticationRepository scopeAuth;
      setUp(() async {
        scopeAuth = AuthenticationRepository(
            testMode: true,
            firebaseAuth: scopeFirebaseAuth,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
            googleSignIn: googleSignIn,
            twitterLogin: twitterLogin);
        when(
          () => scopeFirebaseAuth.createUserWithEmailAndPassword(
              email: "email", password: "password"),
        ).thenThrow(auth.FirebaseAuthException(code: "invalid-email"));
      });
      test("throws login with twitter failures", () async {
        expect(
            () => scopeAuth.signUp(
                email: "email", password: "password", name: ""),
            throwsA(const SignUpWithEmailAndPasswordFailure(
                "Email is not valid or badly formatted.")));
      });
    });
    group("fail sigin with google", () {
      final scopeGoogleSignin = MocktailGoogleSignin();
      late AuthenticationRepository scopeAuth;
      setUp(() async {
        scopeAuth = AuthenticationRepository(
            testMode: true,
            firebaseAuth: firebaseAuth,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
            googleSignIn: scopeGoogleSignin,
            twitterLogin: twitterLogin);
        when(
          () => scopeGoogleSignin.signIn(),
        ).thenThrow(auth.FirebaseAuthException(code: ""));
      });
      test("throws login with twitter failures", () async {
        expect(() => scopeAuth.logInWithGoogle(),
            throwsA(isA<LogInWithGoogleFailure>()));
      });
    });
    group("fail sigin with email and password", () {
      final scopeFirebaseAuth = MocktailFirebaseAuth();
      late AuthenticationRepository scopeAuth;
      setUp(() async {
        scopeAuth = AuthenticationRepository(
            testMode: true,
            firebaseAuth: scopeFirebaseAuth,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
            googleSignIn: googleSignIn,
            twitterLogin: twitterLogin);
        when(
          () => scopeFirebaseAuth.signInWithEmailAndPassword(
              email: "email", password: "password"),
        ).thenThrow(auth.FirebaseAuthException(code: ""));
      });
      test("throws login with twitter failures", () async {
        expect(
            () => scopeAuth.logInWithEmailAndPassword(
                email: "email", password: "password"),
            throwsA(isA<LogInWithEmailAndPasswordFailure>()));
      });
    });
    group("fail logout", () {
      final scopeFirebaseAuth = MocktailFirebaseAuth();
      final scopeGoogleSignin = MocktailGoogleSignin();
      late AuthenticationRepository scopeAuth;
      setUp(() async {
        scopeAuth = AuthenticationRepository(
            testMode: false,
            firebaseAuth: scopeFirebaseAuth,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
            googleSignIn: scopeGoogleSignin,
            twitterLogin: twitterLogin);
        when(
          () => scopeFirebaseAuth.signOut(),
        ).thenAnswer((_) async {});
        when(
          () => scopeGoogleSignin.signOut(),
        ).thenThrow(auth.FirebaseAuthException(code: ""));
      });
      test("throws login with twitter failures", () async {
        expect(() => scopeAuth.logOut(), throwsA(isA<LogOutFailure>()));
      });
    });
    group("success logout", () {
      final scopeFirebaseAuth = MocktailFirebaseAuth();
      final scopeGoogleSignin = MocktailGoogleSignin();
      late AuthenticationRepository scopeAuth;
      setUp(() async {
        scopeAuth = AuthenticationRepository(
            testMode: false,
            firebaseAuth: scopeFirebaseAuth,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
            googleSignIn: scopeGoogleSignin,
            twitterLogin: twitterLogin);
        when(
          () => scopeFirebaseAuth.signOut(),
        ).thenAnswer((_) async {
          return;
        });
        when(
          () => scopeGoogleSignin.signOut(),
        ).thenAnswer((_) async {
          return;
        });
      });
      test("login succesfully", () async {
        scopeAuth.logOut();
        verify(() => scopeFirebaseAuth.signOut()).called(1);
        verify(() => scopeGoogleSignin.signOut()).called(1);
      });
    });

    test("delete failure", () async {
      expect(() => authenticationRepository.delete(),
          throwsA(isA<LogOutFailure>()));
    });
  });
}
