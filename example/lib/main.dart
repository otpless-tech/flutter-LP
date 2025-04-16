import 'dart:convert';
import 'dart:io';
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
  static const String appId = "OD6F3SJGCP93605DA5OM";
  String secret = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtfcggKbl2NQTrVf63uRi0zYyppFd4Vk3xPiu4fYug7MmNf5Vg5/9RNr7jjchWx0bCkB13ALyPEs8SJggGLnfzMigzXiVaDjjuuIdQKSYtZGfo6dnxg8EMPwUT9GCKcZuIM4dyYGHXMSP+Wa9XtyfuU2oR88MXfSmyDZDe7o5Lfi6Lpgw0sNQmG/eSnCbC11+CyvnCnYSeO4f4++X1TqaaXAczZlcJZK71lndFOYjx/4oSj2PAW57SkJLCep+FDgX74aEwBuqtwaGqyInt7bvAA36kRJcySPNW6KF139Wi4+dsOqvHPZNtkgO8ZLiE+Zd9LJdwcYf+PldOiEixqh5qwIDAQAB";

  @override
  void initState() {
    super.initState();
    _otplessFlutterLP.initialize(appId, secret);
    _otplessFlutterLP.setResponseCallback(onLoginPageResult);
  }

  Future<void> openLoginPage() async {
    _otplessFlutterLP.start();
  }

  void onLoginPageResult(dynamic result) {
    setState(() {
      _dataResponse = jsonEncode(result);
    });
  }

  void stop() {
    setState(() {
      _dataResponse = "Stopping and Reinitializing Otpless...";
    });
    _otplessFlutterLP.stop();
    _otplessFlutterLP.initialize(appId, secret);
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
                    child: const Text("Stop & Re Initialize")
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
        )),
      ),
    );
  }
}
