import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:otpless_flutter_lp/models.dart';

import 'otpless_flutter_platform_interface.dart';

typedef OtplessResultCallback = void Function(OtplessResult);
typedef OtplessSimEventListener = void Function(List<Map<String, dynamic>>);
typedef OtplessEventListener = void Function(OtplessEventData);

/// An implementation of [OtplessFlutterPlatform] that uses method channels.
class MethodChannelOtplessFlutter extends OtplessFlutterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('otpless_flutter_lp');

  OtplessResultCallback? _callback;
  OtplessEventListener? eventListener;

  MethodChannelOtplessFlutter() {
    _setEventChannel();
  }

  void _setEventChannel() {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == "otpless_callback_event") {
        final json = call.arguments as String;
        final dynamic result = jsonDecode(json);
        final OtplessResult otplessResult = OtplessResult.fromJson(result);
        _callback!(otplessResult);
      } else if (call.method == "otpless_event") {
        if (eventListener == null) return;
        final json = call.arguments as String;
        final eventJsonData = jsonDecode(json);
        final OtplessEventData eventData =
            OtplessEventData.fromMap(eventJsonData);
        eventListener!(eventData);
      }
    });
  }

  @override
  Future<bool> isWhatsAppInstalled() async {
    final isInstalled = await methodChannel.invokeMethod("isWhatsAppInstalled");
    return isInstalled as bool;
  }

  @override
  Future<String> initialize(String appid) async {
    return await methodChannel.invokeMethod("initialize", {'appId': appid});
  }

  @override
  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _callback = callback;
    await methodChannel.invokeMethod("setResponseCallback");
  }

  @override
  Future<void> start(LoginPageParams params) async {
    await methodChannel.invokeMethod("start", params.toMap());
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod("stop");
  }

  @override
  Future<void> setEventListener(OtplessEventListener listener) async {
    eventListener = listener;
    await methodChannel.invokeMethod("setEventListener");
  }

  @override
  Future<void> setDebugLogging(bool enable) async {
    await methodChannel.invokeMethod("setDebugLogging", {'enable': enable});
  }
}
