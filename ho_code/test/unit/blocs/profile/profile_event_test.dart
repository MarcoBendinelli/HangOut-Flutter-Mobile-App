import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/profile/profile_bloc.dart';

void main() {
  group('LoadGroupsInCommon', () {
    test('props returns correct values', () {
      const String firstId = '123';
      const String secondId = '456';
      const LoadGroupsInCommon event = LoadGroupsInCommon(firstId: firstId, secondId: secondId);

      expect(event.props, [firstId, secondId]);
      expect(event.props.length, 2);
    });
  });
}
