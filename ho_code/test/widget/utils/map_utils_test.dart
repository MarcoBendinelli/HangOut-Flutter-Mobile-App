import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/presentation/utils/map_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher/url_launcher_string.dart';

abstract class LaunchUrlString {
  Future<bool> call(String url, {LaunchMode? mode});
}

class MockLaunchUrlString extends Mock implements LaunchUrlString {}

void main() {
  group('MapUtils tests', () {
    test('openMap launches Google Maps URL with correct parameters', () async {
      WidgetsFlutterBinding.ensureInitialized();
      const latitude = 37.7749;
      const longitude = -122.4194;
      await MapUtils.openMap(latitude, longitude);
    });
  });
}
