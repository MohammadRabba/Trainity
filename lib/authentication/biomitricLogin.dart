import 'package:Trainity/authentication/fingerPrintAPI.dart';
import 'package:flutter/material.dart';

class BiometricAuthentication extends StatelessWidget {
  final Function(BuildContext) authenticate;

  const BiometricAuthentication({super.key, required this.authenticate});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final isAuthenticated = await LocalAuthApi.authenticate();

        if (isAuthenticated) {
          await authenticate(context);
        }
      },
      icon: const Icon(Icons.fingerprint),
    );
  }
}
