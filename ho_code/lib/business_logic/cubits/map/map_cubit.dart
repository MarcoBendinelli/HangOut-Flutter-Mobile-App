import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapState());

  void addPosition({
    required double latitude,
    required double longitude,
    required String locationName,
  }) {
    emit(state.copyWith(
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        status: MapStatus.success));
  }

  void setFailure() {
    emit(
      state.copyWith(
        latitude: 0,
        longitude: 0,
        locationName: "",
        status: MapStatus.error,
      ),
    );
  }
}
