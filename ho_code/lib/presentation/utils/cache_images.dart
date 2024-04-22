import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageManager {
  static bool isTest = false;
  static CacheManager customCachemanager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 5),
      maxNrOfCacheObjects: 20,
    ),
  );

  static ImageProvider getImageProvider(String url) {
    if (isTest) {
      return NetworkImage(url);
    }
    return CachedNetworkImageProvider(url, cacheManager: customCachemanager);
  }
}
