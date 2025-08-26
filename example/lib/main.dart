import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otpless_flutter_lp/models.dart';
import 'package:otpless_flutter_lp/otpless_flutter.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _dataResponse = 'Unknown';
  String lastResponse = "";
  final _otplessFlutterLP = Otpless();
  static const String appId = "";
  String secret = "";

  // NEW: controller/focus for phone input
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _otplessFlutterLP.initialize(appId);
    _otplessFlutterLP.setResponseCallback(onLoginPageResult);
    _otplessFlutterLP.setEventListener(onOtplessEvent);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void onOtplessEvent(dynamic result) {
    String str = '$result\n$lastResponse';
    setState(() {
      _dataResponse = jsonEncode(str);
    });
    lastResponse = str;
  }

  void onLoginPageResult(dynamic result) {
    String str = '$result\n$lastResponse';
    setState(() {
      _dataResponse = jsonEncode(str);
    });
    lastResponse = str;
  }

  void stop() {
    setState(() {
      _dataResponse = "Stopping and Reinitializing Otpless...";
    });
    _otplessFlutterLP.stop();
    _otplessFlutterLP.initialize(appId);
  }

  // --- NEW: phone parsing + submission ---
  /// Returns only digits (E.164-ready local digits) or null if invalid length.
  String? _parsePhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) return null; // basic sanity
    return digits;
  }

  void _submitPhone() {
    final raw = _phoneController.text.trim();
    final parsed = _parsePhone(raw);

    if (parsed == null) {
      setState(() {
        _dataResponse = "Invalid phone number. Enter 7–15 digits.";
      });
      return;
    }

    // TODO: If your SDK has a dedicated method, call it here with `parsed`.
    // e.g. _otplessFlutterLP.startWithPhone(parsed);
    // For now, we just demonstrate the call point + feedback:
    setState(() {
      _dataResponse = "Parsed phone: $parsed";
    });
    LoginPageParams pageParams = LoginPageParams(
        extraQueryParams: {"phone": parsed, "countryCode": "91"});
    _otplessFlutterLP.start(pageParams);
  }
  // --- NEW end ---

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OTPless Flutter Plugin example app'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NEW: phone input
                    const Text(
                      "Phone Number",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.phone,
                      placeholder: "+91 98765 43210",
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitPhone(),
                      prefix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(CupertinoIcons.phone),
                      ),
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minSize: 0,
                            onPressed: () {
                              _phoneController.clear();
                              _phoneFocus.requestFocus();
                            },
                            child: const Icon(
                                CupertinoIcons.clear_thick_circled,
                                size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      onPressed: _submitPhone,
                      color: CupertinoColors.activeBlue,
                      child: const Text("Start Otpless"),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: stop,
                      child: const Text("Stop & Re Initialize"),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      _dataResponse,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
