abstract class PinRepository {
  Future<String?> getPinStatus(String uid);
  Future<void> setPin(String uid, String newPin);
  Future<void> changePin(String uid, String currentPin, String newPin);
}
