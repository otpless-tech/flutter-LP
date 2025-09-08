import 'package:otpless_flutter_lp/models.dart';

import 'otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter_lp/otpless_flutter_method_channel.dart';

class OtplessSdk {
  static final OtplessSdk _instance = OtplessSdk._internal();
  OtplessSdk._internal();

  factory OtplessSdk() {
    return _instance;
  }
  static OtplessSdk get instance => _instance;

  final OtplessFlutterPlatform _otplessPlatform = MethodChannelOtplessFlutter();

  Future<void> start(LoginPageParams params) async {
    _otplessPlatform.start(params);
  }

  Future<String> initialize(String appid) async {
    return await _otplessPlatform.initialize(appid);
  }

  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _otplessPlatform.setResponseCallback(callback);
  }

  Future<void> stop() async {
    _otplessPlatform.stop();
  }

  Future<void> setEventListener(OtplessEventListener listener) async {
    _otplessPlatform.setEventListener(listener);
  }

  Future<void> setDebugLogging(bool enable) async {
    _otplessPlatform.setDebugLogging(enable);
  }
}
