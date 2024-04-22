import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/theme/theme_bloc.dart';

void main() {
  group('ThemeEvent', () {
    test('supports value comparison', () {
      expect(
        const ThemeChanged(isThemeDark: true),
        const ThemeChanged(isThemeDark: true),
      );
    });

    test('returns correct props', () {
      const event = ThemeChanged(isThemeDark: false);
      expect(event.props.length, 1);
      expect(event.props.first, false);
    });
  });
}
