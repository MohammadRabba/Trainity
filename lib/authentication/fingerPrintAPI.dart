import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final isAvailable = await _auth.isDeviceSupported();
      if (!isAvailable) {
        throw PlatformException(
          code: 'NotAvailable',
          message: 'Biometric authentication is not available on this device.',
        );
      }

      return await _auth.authenticate(
        localizedReason: 'Scan Fingerprint to Authenticate',
      );
    } on PlatformException catch (e) {
      print('PlatformException occurred: ${e.message}');
      return false;
    } catch (e) {
      print('Exception occurred: $e');
      return false;
    }
  }
}
