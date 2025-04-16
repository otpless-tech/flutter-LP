import 'otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter_lp/otpless_flutter_method_channel.dart';

class Otpless {
  final MethodChannelOtplessFlutter _otplessChannel =
      MethodChannelOtplessFlutter();

  Future<String?> getPlatformVersion() {
    return OtplessFlutterPlatform.instance.getPlatformVersion();
  }

  Future<void> start() async {
    _otplessChannel.start();
  }

  Future<void> initialize(String appid, String secret) async {
    _otplessChannel.initialize(appid, secret);
  }

  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _otplessChannel.setResponseCallback(callback);
  }

  Future<void> stop() async {
    _otplessChannel.stop();
  }
}
