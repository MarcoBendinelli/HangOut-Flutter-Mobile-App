import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/message.dart' as message_model;

void main() {
  group("message tests", () {
    test("test can be converted to map and from map with abstract Text", () {
      message_model.Message message1 = message_model.TextMessage(
          text: "text",
          timeStamp: 1,
          dateHour: "dateHour",
          senderId: "senderId",
          senderNickname: "senderNickname",
          senderPhoto: "senderPhoto");
      dynamic mapMessage = message1.toMap();
      message_model.Message message2 = message_model.Message.fromMap(mapMessage);
      expect(message2, message1);
    });
    test("test can be converted to map and from map with TextMessage", () {
      message_model.Message message1 = message_model.TextMessage(
          text: "text",
          timeStamp: 1,
          dateHour: "dateHour",
          senderId: "senderId",
          senderNickname: "senderNickname",
          senderPhoto: "senderPhoto");
      dynamic mapMessage = message1.toMap();
      message_model.Message message2 =
          message_model.TextMessage.fromMap(mapMessage);
      expect(message2, message1);
    });
    test("test to string", () {
      String text = "text";
      int timeStamp = 1;
      String dateHour = "dateHour";
      String senderId = "senderId";
      String senderNickname = "senderNickname";
      String senderPhoto = "senderPhoto";

      message_model.TextMessage ourNotification = message_model.TextMessage(
          text: text,
          timeStamp: timeStamp,
          dateHour: dateHour,
          senderId: senderId,
          senderNickname: senderNickname,
          senderPhoto: senderPhoto);
      String string = ourNotification.toString();
      expect(string,
          '{ sender_id : $senderId, sender_nickname : $senderNickname, sender_photo : $senderPhoto, time_stamp : $timeStamp, date_hour : $dateHour, type : 0, text: $text }');
    });
  });
}
