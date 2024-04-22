part of 'map_cubit.dart';

enum MapStatus { initial, success, error }

class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    // this.geoPoint =   GeoPoint(latitude: 0, longitude: 0),
    this.latitude = 0,
    this.longitude = 0,
    this.locationName = "",
  });

  final MapStatus status;
  final double latitude;
  final double longitude;
  final String locationName;

  @override
  List<Object> get props => [status, latitude, longitude, locationName];

  MapState copyWith({
    required MapStatus status,
    required double latitude,
    required double longitude,
    required String locationName,
  }) {
    return MapState(
      status: status,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }
}
