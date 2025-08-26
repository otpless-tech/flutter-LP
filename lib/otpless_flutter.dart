import 'package:otpless_flutter_lp/models.dart';

import 'otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter_lp/otpless_flutter_method_channel.dart';

class Otpless {
  final MethodChannelOtplessFlutter _otplessChannel =
      MethodChannelOtplessFlutter();

  Future<String?> getPlatformVersion() {
    return OtplessFlutterPlatform.instance.getPlatformVersion();
  }

  Future<void> start(LoginPageParams params) async {
    _otplessChannel.start(params);
  }

  Future<String> initialize(String appid) async {
    return await _otplessChannel.initialize(appid);
  }

  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _otplessChannel.setResponseCallback(callback);
  }

  Future<void> stop() async {
    _otplessChannel.stop();
  }

  Future<void> setEventListener(OtplessEventListener listener) async {
    _otplessChannel.setEventListener(listener);
  }

  Future<void> setDebugLogging(bool enable) async {
    _otplessChannel.setDebugLogging(enable);
  }
}
