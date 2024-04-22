import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';

void main() {
  group('CustomRectTween', () {
    test('lerp should return the correct Rect values', () {
      final tween = CustomRectTween(
          begin: const Rect.fromLTRB(0, 0, 10, 10),
          end: const Rect.fromLTRB(20, 20, 30, 30));

      expect(tween.lerp(0.0), equals(const Rect.fromLTRB(0, 0, 10, 10)));
      // expect(tween.lerp(0.5), equals(const Rect.fromLTRB(10, 10, 25, 25)));
      expect(tween.lerp(1.0), equals(const Rect.fromLTRB(20, 20, 30, 30)));
    });
    test('should instantiate CustomRectTween with required parameters', () {
      expect(() => CustomRectTween(begin: Rect.zero, end: Rect.zero),
          returnsNormally);
    });
  });
}
