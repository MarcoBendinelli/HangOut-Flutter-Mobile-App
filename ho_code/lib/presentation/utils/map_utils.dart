import 'package:url_launcher/url_launcher_string.dart';

class MapUtils {
  // MapUtils._();
  static Future<void> openMap(double latitude, double longitude) async {
    String googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    // Uri url = Uri(path: googleMapUrl);
    Uri url = Uri(
        scheme: 'https',
        host: 'google.com',
        path: '/maps/search/',
        queryParameters: {'api': '1', 'query': '$latitude,$longitude'});
    try {
      if (!await launchUrlString(googleMapUrl,
          mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (_) {
      return;
    }
  }
}
