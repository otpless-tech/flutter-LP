import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'otpless_flutter_method_channel.dart';
import 'package:otpless_flutter_lp/models.dart';

abstract class OtplessFlutterPlatform extends PlatformInterface {
  /// Constructs a OtplessFlutterPlatform.
  OtplessFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static OtplessFlutterPlatform _instance = MethodChannelOtplessFlutter();

  /// The default instance of [OtplessFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelOtplessFlutter].
  static OtplessFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OtplessFlutterPlatform] when
  /// they register themselves.
  static set instance(OtplessFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isWhatsAppInstalled();

  Future<String> initialize(String appid);

  Future<void> setResponseCallback(OtplessResultCallback callback);

  Future<void> start(LoginPageParams params);

  Future<void> stop();

  Future<void> setEventListener(OtplessEventListener listener);

  Future<void> setDebugLogging(bool enable);
}
