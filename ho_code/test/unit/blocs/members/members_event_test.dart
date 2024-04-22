import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';

void main() {
  group('MembersEvent', () {
    test('GoInInitState should have empty props', () {
      expect(GoInInitState().props, isEmpty);
    });

    test('LoadMembersInEvent should have props with eventId', () {
      const eventId = '123';
      expect(const LoadMembersInEvent(eventId: eventId).props, [eventId]);
    });

    test('LoadMembersInGroup should have props with groupId and currentUserId',
        () {
      const groupId = '456';
      const currentUserId = '789';
      expect(
          const LoadMembersInGroup(
                  groupId: groupId, currentUserId: currentUserId)
              .props,
          [groupId, currentUserId]);
    });

    test('LoadGroupForUser should have props with userId', () {
      const userId = 'abc';
      expect(const LoadGroupForUser(userId: userId).props, [userId]);
    });

    test('LoadSelectedUsers should have props with idUsers and currentUserId',
        () {
      const idUsers = ['111', '222'];
      const currentUserId = '333';
      expect(
          const LoadSelectedUsers(
                  idUsers: idUsers, currentUserId: currentUserId)
              .props,
          [idUsers, currentUserId]);
    });

    test(
        'LoadSelectedUsersAndGroupMembers should have props with groupId and currentUserId',
        () {
      const groupId = 'xyz';
      const currentUserId = '456';
      expect(
          const LoadSelectedUsersAndGroupMembers(
                  groupId: groupId, currentUserId: currentUserId)
              .props,
          [groupId, currentUserId]);
    });
  });
}
