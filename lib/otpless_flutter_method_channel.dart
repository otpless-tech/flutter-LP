import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'otpless_flutter_platform_interface.dart';

typedef OtplessResultCallback = void Function(dynamic);
typedef OtplessSimEventListener = void Function(List<Map<String, dynamic>>);

/// An implementation of [OtplessFlutterPlatform] that uses method channels.
class MethodChannelOtplessFlutter extends OtplessFlutterPlatform {
  final eventChannel = const EventChannel('otpless_callback_event');

  @visibleForTesting
  final methodChannel = const MethodChannel('otpless_flutter_lp');

  OtplessResultCallback? _callback;

  MethodChannelOtplessFlutter() {
    _setEventChannel();
  }

  void _setEventChannel() {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == "otpless_callback_event") {
        final json = call.arguments as String;
        final result = jsonDecode(json);
        _callback!(result);
      }
    });
  }

  Future<bool> isWhatsAppInstalled() async {
    final isInstalled = await methodChannel.invokeMethod("isWhatsAppInstalled");
    return isInstalled as bool;
  }

  Future<void> initialize(String appid, String secret) async {
    await methodChannel.invokeMethod("initialize", {'appId': appid, 'secret': secret});
  }

  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _callback = callback;
    await methodChannel.invokeMethod("setResponseCallback");
  }

  Future<void> start() async {
    await methodChannel.invokeMethod("start");
  }

  Future<void> stop() async {
    await methodChannel.invokeListMethod("stop");
  }
}
