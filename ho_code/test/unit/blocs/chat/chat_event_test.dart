import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/chat/chat_bloc.dart';

void main() {
  group('ChatEvent', () {
    test('LoadGroupChat should be equatable', () {
      expect(const LoadGroupChat(groupId: '123'),
          const LoadGroupChat(groupId: '123'));
    });

    test('LoadGroupChat should have correct props', () {
      expect(const LoadGroupChat(groupId: '123').props, ['123']);
    });

    test('LoadEventChat should be equatable', () {
      expect(
          const LoadEventChat(eventId: '123'), const LoadEventChat(eventId: '123'));
    });

    test('LoadEventChat should have correct props', () {
      expect(const LoadEventChat(eventId: '123').props, ['123']);
    });
  });
}
