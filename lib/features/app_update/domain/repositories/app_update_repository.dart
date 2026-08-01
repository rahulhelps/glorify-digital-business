abstract class AppUpdateRepository {
  /// Fetches version control data from Firestore at `app_config/version_control`.
  /// Returns a map with at minimum:
  ///   - `latest_version` : String  (e.g. "1.2.0")
  ///   - `download_url`   : String  (Play Store or direct APK URL)
  Future<Map<String, dynamic>> fetchVersionControl();
}
