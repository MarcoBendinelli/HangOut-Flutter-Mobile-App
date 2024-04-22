import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/our_notification.dart';

void main() {
  group("OurNotification tests", () {
    test("our notification to string", () {
      var chatMessage = "chatMessage";
      var dateHour = "dateHour";
      var eventCategory = "eventCategory";
      var notificationId = "notificationId";
      var public = true;
      var sourceName = "sourceName";
      var thingToNotifyName = "thingToNotifyName";
      var thingToOpenId = "thingToOpenId";
      var userIds = ["userIds"];
      OurNotification ourNotification = OurNotification(
        notificationId: notificationId,
        userIds: userIds,
        thingToOpenId: thingToOpenId,
        thingToNotifyName: thingToNotifyName,
        sourceName: sourceName,
        dateHour: dateHour,
        timestamp: 1,
        chatMessage: chatMessage,
        eventCategory: eventCategory,
        public: true,
      );
      String string = ourNotification.toString();
      expect(string,
          '{ notificationId : $notificationId, userIds : $userIds, thingToOpenId : $thingToOpenId, thingToNotifyName : $thingToNotifyName, eventCategory : $eventCategory, chatMessage : $chatMessage, source_name : $sourceName, date_hour : $dateHour, public : $public');
    });
  });
}
