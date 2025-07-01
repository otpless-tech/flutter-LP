import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final _otplessFlutterLP = Otpless();
  static const String appId = "PULP572EREYRMYBHXZJG";

  @override
  void initState() {
    super.initState();
    _initializeLoginPage();
  }

  Future<void> _initializeLoginPage() async {
    const CctSupportConfig config =
        CctSupportConfig(type: CctSupportType.cCT, origin: null);
    final String traceId = await _otplessFlutterLP.initialize(appId, config);
    _otplessFlutterLP.setResponseCallback(onLoginPageResult);
    print('LoginPage initialized with traceId: $traceId');
  }

  Future<void> openLoginPage() async {
    _otplessFlutterLP.start(null);
  }

  void onLoginPageResult(dynamic result) {
    setState(() {
      _dataResponse = jsonEncode(result);
    });
  }

  Future<void> stop() async {
    setState(() {
      _dataResponse = "Stopping and Reinitializing Otpless...";
    });
    _otplessFlutterLP.stop();
    const CctSupportConfig config =
        CctSupportConfig(type: CctSupportType.cCT, origin: null);
    final String traceId = await _otplessFlutterLP.initialize(appId, config);
    _otplessFlutterLP.initialize(appId, config);
  }

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
            padding: const EdgeInsets.all(16.0), // Adjusted margin
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Makes the buttons fill the width
                children: [
                  CupertinoButton.filled(
                    onPressed: openLoginPage,
                    child: const Text("Start"),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                      onPressed: stop,
                      child: const Text("Stop & Re Initialize")),
                  const SizedBox(height: 16),
                  Text(
                    _dataResponse,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
