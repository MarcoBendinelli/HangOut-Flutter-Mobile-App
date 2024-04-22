import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/cache/cache.dart';

void main() {
  group('CacheClient', () {
    late CacheClient cacheClient;

    setUp(() {
      cacheClient = CacheClient();
    });

    test('write should add a value to the cache', () {
      cacheClient.write(key: 'test', value: 'value');
      expect(cacheClient.cache.containsKey('test'), true);
    });

    test('read should retrieve a value from the cache', () {
      cacheClient.write(key: 'test', value: 'value');
      final value = cacheClient.read<String>(key: 'test');
      expect(value, 'value');
    });

    test('read should return null if value does not exist for key', () {
      final value = cacheClient.read<String>(key: 'test');
      expect(value, null);
    });

    test('read should return null if value is of incorrect type', () {
      cacheClient.write(key: 'test', value: 123);
      final value = cacheClient.read<String>(key: 'test');
      expect(value, null);
    });
  });
}
