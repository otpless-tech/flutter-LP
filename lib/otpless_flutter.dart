import 'otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter_lp/otpless_flutter_method_channel.dart';

class Otpless {
  final MethodChannelOtplessFlutter _otplessChannel =
      MethodChannelOtplessFlutter();

  Future<String?> getPlatformVersion() {
    return OtplessFlutterPlatform.instance.getPlatformVersion();
  }

  Future<void> start(LoginPageParams? loginPageParams) async {
    _otplessChannel.start(loginPageParams);
  }

  Future<String> initialize(String appid, CctSupportConfig config) async {
    return await _otplessChannel.initialize(appid, config);
  }

  Future<void> setResponseCallback(OtplessResultCallback callback) async {
    _otplessChannel.setResponseCallback(callback);
  }

  Future<void> stop() async {
    _otplessChannel.stop();
  }
}

enum CctSupportType { tWA, cCT }

class CctSupportConfig {
  final CctSupportType type;
  final Uri? origin;

  const CctSupportConfig({
    this.type = CctSupportType.tWA,
    this.origin,
  });

  @override
  String toString() => 'CctSupportConfig(type: $type, origin: $origin)';

  Map<String, dynamic> newDynamicMap() {
    String name = "";
    switch (type) {
      case CctSupportType.tWA:
        name = "tWA";
        break;
      case CctSupportType.cCT:
        name = "cCt";
        break;
    }
    final Map<String, dynamic> data = {
      'origin': origin?.toString(),
      'type': name
    };
    return data;
  }
}

/// tab customization class for android
class CustomTabParam {
  final String toolbarColor;
  final String secondaryToolbarColor;
  final String navigationBarColor;
  final String navigationBarDividerColor;
  final String? backgroundColor;

  const CustomTabParam({
    this.toolbarColor = '',
    this.secondaryToolbarColor = '',
    this.navigationBarColor = '',
    this.navigationBarDividerColor = '',
    this.backgroundColor,
  });

  Map<String, dynamic> newDynamicMap() {
    return {
      'toolbarColor': toolbarColor,
      'secondaryToolbarColor': secondaryToolbarColor,
      'navigationBarColor': navigationBarColor,
      'navigationBarDividerColor': navigationBarDividerColor,
      'backgroundColor': backgroundColor,
    };
  }
}

/// tab customization class for ios
class SafariCustomParams {
  final String? preferredBarTintColor;
  final String? preferredControlTintColor;
  final DismissButtonStyle? dismissButtonStyle;
  final ModalPresentationStyle? modalPresentationStyle;

  const SafariCustomParams({
    this.preferredBarTintColor,
    this.preferredControlTintColor,
    this.dismissButtonStyle,
    this.modalPresentationStyle,
  });

  Map<String, dynamic> newDynamicMap() {
    final Map<String, dynamic> map = {
      'preferredBarTintColor': preferredBarTintColor,
      'preferredControlTintColor': preferredControlTintColor,
    };
    // name conversion was giving version warning
    if (dismissButtonStyle != null) {
      switch (dismissButtonStyle!) {
        case DismissButtonStyle.done:
          map['dismissButtonStyle'] = 'done';
          break;
        case DismissButtonStyle.cancel:
          map['dismissButtonStyle'] = 'cancel';
          break;
        case DismissButtonStyle.close:
          map['dismissButtonStyle'] = 'close';
          break;
      }
    }
    // name conversion was giving version warning
    if (modalPresentationStyle != null) {
      switch (modalPresentationStyle!) {
        case ModalPresentationStyle.pageSheet:
          map['modalPresentationStyle'] = 'pageSheet';
          break;
        case ModalPresentationStyle.automatic:
          map['modalPresentationStyle'] = 'automatic';
          break;
        case ModalPresentationStyle.overFullScreen:
          map['modalPresentationStyle'] = 'overFullScreen';
          break;
        case ModalPresentationStyle.formSheet:
          map['modalPresentationStyle'] = 'formSheet';
          break;
      }
    }
    return map;
  }
}

enum DismissButtonStyle { done, cancel, close }

enum ModalPresentationStyle { automatic, pageSheet, formSheet, overFullScreen }

class LoginPageParams {
  final int waitTime;
  final Map<String, String> extraQueryParams;
  final CustomTabParam customTabParam;
  final SafariCustomParams safarCustomParams;
  final String? loadingUrl;

  const LoginPageParams({
    this.waitTime = 2000,
    this.extraQueryParams = const {},
    this.customTabParam = const CustomTabParam(),
    this.safarCustomParams = const SafariCustomParams(),
    this.loadingUrl,
  });

  Map<String, dynamic> newDynamicMap() {
    return {
      'waitTime': waitTime,
      'extraQueryParams': extraQueryParams,
      'customTabParam': customTabParam.newDynamicMap(),
      'safarCustomParams': safarCustomParams.newDynamicMap(),
      'loadingUrl': loadingUrl,
    };
  }
}
