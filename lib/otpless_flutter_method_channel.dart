import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:otpless_flutter_lp/otpless_flutter.dart';

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

  Future<String> initialize(String appid, CctSupportConfig config) async {
    String traceId = await methodChannel.invokeMethod(
        "initialize", {'appId': appid, 'config': config.newDynamicMap()});
    return traceId;
  }

  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _callback = callback;
    await methodChannel.invokeMethod("setResponseCallback");
  }

  Future<void> start(LoginPageParams? loginPageParams) async {
    if (loginPageParams == null) {
      await methodChannel.invokeMethod("start");
    } else {
      await methodChannel.invokeMethod(
          "start", {'loginPageParams': loginPageParams.newDynamicMap()});
    }
  }

  Future<void> stop() async {
    await methodChannel.invokeListMethod("stop");
  }
}
