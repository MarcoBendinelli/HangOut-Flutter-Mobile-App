import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  group('ImageManager tests', () {
    late MockCacheManager mockCacheManager;

    setUp(() {
      mockCacheManager = MockCacheManager();
      ImageManager.customCachemanager = mockCacheManager;
    });

    test(
        'getImageProvider returns CachedNetworkImageProvider with custom cache manager',
        () {
      const url = 'https://example.com/image.png';
      final expectedProvider =
          CachedNetworkImageProvider(url, cacheManager: mockCacheManager);

      final actualProvider = ImageManager.getImageProvider(url);

      expect(actualProvider, equals(expectedProvider));
      // verify(() => mockCacheManager.getSingleFile(url)).called(1);
    });
  });
}
