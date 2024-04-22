import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('LoadExploreEvents', () {
    test('props returns correct values', () {
      const loadEvents1 = LoadExploreEvents(userId: 'user123', categories: ['category1']);
      const loadEvents2 = LoadExploreEvents(userId: 'user123', categories: ['category1']);
      const loadEvents3 = LoadExploreEvents(userId: 'user456', categories: ['category2']);

      expect(loadEvents1.props, [loadEvents1.userId, loadEvents1.categories]);
      expect(loadEvents1.props, loadEvents2.props);
      expect(loadEvents1.props, isNot(loadEvents3.props));
    });
  });

  group('LoadExploreGroups', () {
    test('props returns correct values', () {
      const loadGroups1 = LoadExploreGroups(userId: 'user123', categories: ['category1']);
      const loadGroups2 = LoadExploreGroups(userId: 'user123', categories: ['category1']);
      const loadGroups3 = LoadExploreGroups(userId: 'user456', categories: ['category2']);

      expect(loadGroups1.props, [loadGroups1.userId, loadGroups1.categories]);
      expect(loadGroups1.props, loadGroups2.props);
      expect(loadGroups1.props, isNot(loadGroups3.props));
    });
  });
}
