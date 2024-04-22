import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class Message extends Equatable {
  final int timeStamp;
  final String dateHour;
  final String senderId;
  final String senderNickname;
  final String senderPhoto;
  late final String documentId;

  // ignore: prefer_const_constructors_in_immutables
  Message(
      {required this.senderPhoto,
      required this.timeStamp,
      required this.dateHour,
      required this.senderId,
      required this.senderNickname});

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    final int type = data?['type'];
    late Message message;
    switch (type) {
      case 0:
        message = TextMessage.fromFirestore(data!);
        break;
      // case 1:
      //   message = ImageMessage.fromFirestore(doc);
      //   break;
      // case 2:
      //   message = VideoMessage.fromFirestore(doc);
      //   break;
      // case 3:
      //   message = FileMessage.fromFirestore(doc);
    }

    message.documentId = snapshot.id;
    return message;
  }

  factory Message.fromMap(Map map) {
    final int type = map['type'];
    late Message message;
    switch (type) {
      case 0:
        message = TextMessage.fromMap(map);
        break;
      // case 1:
      //   message = ImageMessage.fromMap(map);
      //   break;
      // case 2:
      //   message = VideoMessage.fromMap(map);
      //   break;
      // case 3:
      //   message = FileMessage.fromMap(map);
    }

    return message;
  }

  Map<String, dynamic> toMap();
}

class TextMessage extends Message {
  final String text;

  TextMessage(
      {required this.text,
      required timeStamp,
      required dateHour,
      required senderId,
      required senderNickname,
      required senderPhoto})
      : super(
            senderPhoto: senderPhoto,
            timeStamp: timeStamp,
            dateHour: dateHour,
            senderId: senderId,
            senderNickname: senderNickname);

  factory TextMessage.fromFirestore(Map<String, dynamic> data) {
    return TextMessage.fromMap(data);
  }

  factory TextMessage.fromMap(Map data) {
    return TextMessage(
        text: data['text'],
        timeStamp: data['time_stamp'],
        dateHour: data['date_hour'],
        senderId: data['sender_id'],
        senderNickname: data['sender_nickname'],
        senderPhoto: data['sender_photo']);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['text'] = text;
    map['time_stamp'] = timeStamp;
    map['date_hour'] = dateHour;
    map['sender_id'] = senderId;
    map['sender_nickname'] = senderNickname;
    map['sender_photo'] = senderPhoto;
    map['type'] = 0;
    return map;
  }

  @override
  String toString() =>
      '{ sender_id : $senderId, sender_nickname : $senderNickname, sender_photo : $senderPhoto, time_stamp : $timeStamp, date_hour : $dateHour, type : 0, text: $text }';

  @override
  List<Object?> get props =>
      [text, timeStamp, dateHour, senderId, senderNickname, senderPhoto];
}

// class ImageMessage extends Message {
//   String imageUrl;
//   String fileName;
//
//   ImageMessage(
//       this.imageUrl, this.fileName, timeStamp, senderName, senderUsername)
//       : super(timeStamp, senderName, senderUsername);
//
//   factory ImageMessage.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     return ImageMessage.fromMap(data);
//   }
//
//   factory ImageMessage.fromMap(Map data) {
//     return ImageMessage(data['imageUrl'], data['fileName'], data['timeStamp'],
//         data['senderName'], data['senderUsername']);
//   }
//
//   @override
//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> map = {};
//     map['imageUrl'] = imageUrl;
//     map['fileName'] = fileName;
//     map['timeStamp'] = timeStamp;
//     map['senderName'] = senderId;
//     map['senderUsername'] = senderUsername;
//     map['type'] = 1;
//     print('map $map');
//     return map;
//   }
//
//   @override
//   String toString() =>
//       '{ senderName : $senderId, senderUsername : $senderUsername, timeStamp : $timeStamp, type : 3, fileName: $fileName, imageUrl : $imageUrl  }';
// }
//
// class VideoMessage extends Message {
//   String videoUrl;
//   String fileName;
//
//   VideoMessage(
//       this.videoUrl, this.fileName, timeStamp, senderName, senderUsername)
//       : super(timeStamp, senderName, senderUsername);
//
//   factory VideoMessage.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     return VideoMessage.fromMap(data);
//   }
//
//   factory VideoMessage.fromMap(Map data) {
//     return VideoMessage(data['videoUrl'], data['fileName'], data['timeStamp'],
//         data['senderName'], data['senderUsername']);
//   }
//
//   @override
//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> map = {};
//     map['videoUrl'] = videoUrl;
//     map['fileName'] = fileName;
//     map['timeStamp'] = timeStamp;
//     map['senderName'] = senderId;
//     map['senderUsername'] = senderUsername;
//     map['type'] = 2;
//     return map;
//   }
//
//   @override
//   String toString() =>
//       '{ senderName : $senderId, senderUsername : $senderUsername, timeStamp : $timeStamp, type : 3, fileName: $fileName, videoUrl : $videoUrl  }';
// }
//
// class FileMessage extends Message {
//   String fileUrl;
//   String fileName;
//
//   FileMessage(
//       this.fileUrl, this.fileName, timeStamp, senderName, senderUsername)
//       : super(timeStamp, senderName, senderUsername);
//
//   factory FileMessage.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     return FileMessage.fromMap(data);
//   }
//
//   factory FileMessage.fromMap(Map data) {
//     return FileMessage(data['fileUrl'], data['fileName'], data['timeStamp'],
//         data['senderName'], data['senderUsername']);
//   }
//
//   @override
//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> map = {};
//     map['fileUrl'] = fileUrl;
//     map['fileName'] = fileName;
//     map['timeStamp'] = timeStamp;
//     map['senderName'] = senderId;
//     map['senderUsername'] = senderUsername;
//     map['type'] = 3;
//     return map;
//   }
//
//   @override
//   String toString() =>
//       '{ senderName : $senderId, senderUsername : $senderUsername, timeStamp : $timeStamp, type : 3, fileName: $fileName, fileUrl : $fileUrl  }';
// }
