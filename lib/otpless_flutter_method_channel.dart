import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:otpless_flutter_lp/models.dart';

import 'otpless_flutter_platform_interface.dart';

typedef OtplessResultCallback = void Function(dynamic);
typedef OtplessSimEventListener = void Function(List<Map<String, dynamic>>);
typedef OtplessEventListener = void Function(dynamic);

/// An implementation of [OtplessFlutterPlatform] that uses method channels.
class MethodChannelOtplessFlutter extends OtplessFlutterPlatform {
  final eventChannel = const EventChannel('otpless_callback_event');

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
        final result = jsonDecode(json);
        _callback!(result);
      } else if (call.method == "otpless_event") {
        if (eventListener == null) return;
        final json = call.arguments as String;
        final eventData = jsonDecode(json);
        eventListener!(eventData);
      }
    });
  }

  Future<bool> isWhatsAppInstalled() async {
    final isInstalled = await methodChannel.invokeMethod("isWhatsAppInstalled");
    return isInstalled as bool;
  }

  Future<String> initialize(String appid) async {
    return await methodChannel.invokeMethod("initialize", {'appId': appid});
  }

  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _callback = callback;
    await methodChannel.invokeMethod("setResponseCallback");
  }

  Future<void> start(LoginPageParams params) async {
    await methodChannel.invokeMethod("start", params.toMap());
  }

  Future<void> stop() async {
    await methodChannel.invokeMethod("stop");
  }

  Future<void> setEventListener(OtplessEventListener listener) async {
    eventListener = listener;
    await methodChannel.invokeMethod("setEventListener");
  }

  Future<void> setDebugLogging(bool enable) async {
    await methodChannel.invokeMethod("setDebugLogging", {'enable': enable});
  }
}
