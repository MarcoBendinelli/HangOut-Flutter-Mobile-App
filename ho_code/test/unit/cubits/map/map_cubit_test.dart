import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/cubits/map/map_cubit.dart';

void main() {
  group("map_cubit", () {
    test('initial state is initial', () {
      expect(MapCubit().state.status, MapStatus.initial);
    });
    test('initial state is 0,0,"",initial', () {
      expect(MapCubit().state,
          const MapState(latitude: 0, longitude: 0, status: MapStatus.initial));
    });
    blocTest<MapCubit, MapState>(
      'emits [success] when add position is called',
      build: () => MapCubit(),
      act: (cubit) =>
          cubit.addPosition(latitude: 0, longitude: 0, locationName: "Name"),
      expect: () => const <MapState>[
        MapState(
            latitude: 0,
            longitude: 0,
            locationName: "Name",
            status: MapStatus.success),
      ],
    );
    blocTest<MapCubit, MapState>(
      'emits [error] when setFailure is called',
      build: () => MapCubit(),
      act: (cubit) => cubit.setFailure(),
      expect: () => const <MapState>[
        MapState(
            latitude: 0,
            longitude: 0,
            locationName: "",
            status: MapStatus.error),
      ],
    );
  });
}
