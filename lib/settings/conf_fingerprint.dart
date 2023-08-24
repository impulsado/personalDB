import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:personaldb/main.dart';

class FingerprintSetupScreen extends StatefulWidget {
  const FingerprintSetupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FingerprintSetupScreenState createState() => _FingerprintSetupScreenState();
}

class _FingerprintSetupScreenState extends State<FingerprintSetupScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isFingerprintConfigured = false;

  @override
  void initState() {
    super.initState();
    _checkFingerprintConfigured();
  }

  Future<void> _checkFingerprintConfigured() async {
    String? storedPassword = await _secureStorage.read(key: "dbPassword");
    setState(() {
      _isFingerprintConfigured = storedPassword != null;
    });
  }

  Future<void> _setupFingerprint() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

    if (canCheckBiometrics) {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: "Please authenticate with your fingerprint.",
      );

      if (authenticated) {
        await _secureStorage.write(key: "dbPassword", value: MyApp.dbPassword);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fingerprint successfully configured")),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication failed")),
        );
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric authentication not available")),
      );
    }
  }

  Future<void> _removeFingerprint() async {
    await _secureStorage.delete(key: "dbPassword");
    setState(() {
      _isFingerprintConfigured = false;
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fingerprint configuration removed")),
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Fingerprint", style: headingStyle(color: Colors.black)),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isFingerprintConfigured)
                    const Text(
                      "Fingerprint is already configured. \n"
                      "You can remove it anytime.",
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  if (!_isFingerprintConfigured) ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: const Text(
                        "Setting a fingerprint does NOT make the application MORE SECURE. \n",
                        style: TextStyle(fontSize: 12.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: const Text(
                        "You can set it up for convenience, but you should know that you are more likely to forget your password, and it cannot be recovered.\n\n",
                        style: TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: const Text(
                        "The application will NEVER do anything with your biometric data.",
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: _setupFingerprint,
                          child: const Text("Accept"),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                  if (_isFingerprintConfigured)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      onPressed: _removeFingerprint,
                      child: const Text("Remove"),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
