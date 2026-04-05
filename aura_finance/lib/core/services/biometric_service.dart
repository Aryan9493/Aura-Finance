import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._();
  factory BiometricService() => _instance;
  BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false; // Native authentication not supported on web
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    if (kIsWeb) return true; // Grant access automatically on web as it's not supported
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Secure your Aura Finance data',
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    } catch (e) {
      return false;
    }
  }
}
