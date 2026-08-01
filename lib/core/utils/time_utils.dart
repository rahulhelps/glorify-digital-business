import 'dart:convert';
import 'package:http/http.dart' as http;

class TimeUtils {
  /// Fetches the current UTC time from a network API (WorldTimeAPI).
  /// Falls back to the device's current UTC time if the network request fails.
  static Future<DateTime> getNetworkUtcTime() async {
    try {
      final response = await http
          .get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Dhaka'))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final datetimeStr = data['utc_datetime'] as String?;
        if (datetimeStr != null) {
          return DateTime.parse(datetimeStr).toUtc();
        }
      }
    } catch (_) {
      // Ignore errors and fallback to device time
    }
    return DateTime.now().toUtc();
  }

  /// Returns the current time in Bangladesh Standard Time (BST, UTC+6).
  static Future<DateTime> getBangladeshTime() async {
    final utcTime = await getNetworkUtcTime();
    return utcTime.add(const Duration(hours: 6));
  }
}
