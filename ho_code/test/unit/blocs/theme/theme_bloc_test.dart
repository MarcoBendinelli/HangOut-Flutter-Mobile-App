import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/theme/theme_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(
      () => storage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  test('initial theme with no storage is the one given', () {
    expect(
      ThemeBloc(initialValue: true).state,
      true,
    );
    expect(
      ThemeBloc(initialValue: false).state,
      false,
    );
  });
  group("stored initial value", () {
    setUp(() {
      when<dynamic>(() => storage.read(any())).thenReturn(true);
    });
    test('from Json return the value in the json', () {
      expect(
        ThemeBloc(initialValue: false)
            .fromJson({"value": true, "toIgnore": false}),
        true,
      );
      expect(
        ThemeBloc(initialValue: false)
            .fromJson({"value": false, "toIgnore": true}),
        false,
      );
    });
  });
  group('ThemeChanged', () {
    blocTest<ThemeBloc, bool>(
      'emits true when theme is changed to dark',
      build: () => ThemeBloc(
        initialValue: false,
      ),
      act: (bloc) => bloc.add(const ThemeChanged(isThemeDark: true)),
      expect: () => [true],
    );
    blocTest<ThemeBloc, bool>(
      'emits false when theme is changed to bright',
      build: () => ThemeBloc(
        initialValue: true,
      ),
      act: (bloc) => bloc.add(const ThemeChanged(isThemeDark: false)),
      expect: () => [false],
    );
  });
}
