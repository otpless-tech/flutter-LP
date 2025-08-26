/// model classes for login page params
///
///

class CustomTabParam {
  final String? toolbarColor;
  final String? secondaryToolbarColor;
  final String? navigationBarColor;
  final String? navigationBarDividerColor;
  final String? backgroundColor;

  const CustomTabParam({
    this.toolbarColor,
    this.secondaryToolbarColor,
    this.navigationBarColor,
    this.navigationBarDividerColor,
    this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      if (toolbarColor != null) 'toolbarColor': toolbarColor,
      if (secondaryToolbarColor != null)
        'secondaryToolbarColor': secondaryToolbarColor,
      if (navigationBarColor != null) 'navigationBarColor': navigationBarColor,
      if (navigationBarDividerColor != null)
        'navigationBarDividerColor': navigationBarDividerColor,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
    };
  }
}

class LoginPageParams {
  /// milliseconds to wait (default 2000)
  final int waitTime;

  /// extra query params (default {})
  final Map<String, String> extraQueryParams;

  /// custom tab options (default new CustomTabParam())
  final CustomTabParam? customTabParam;

  final SafariCustomizationOptions? safariCustomizationOptions;

  /// optional loading URL
  final String? loadingUrl;

  const LoginPageParams({
    this.waitTime = 2000,
    this.extraQueryParams = const {},
    this.customTabParam,
    this.safariCustomizationOptions,
    this.loadingUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'waitTime': waitTime,
      'extraQueryParams': extraQueryParams,
      if (customTabParam != null) 'customTabParam': customTabParam,
      if (safariCustomizationOptions != null)
        'safariCustomizationOptions': safariCustomizationOptions,
      if (loadingUrl != null) 'loadingUrl': loadingUrl,
    };
  }
}

enum DismissButtonStyle { done, cancel, close }

enum ModalPresentationStyle { automatic, pageSheet, formSheet, overFullScreen }

class SafariCustomizationOptions {
  final String? preferredBarTintColor;
  final String? preferredControlTintColor;
  final DismissButtonStyle? dismissButtonStyle;
  final ModalPresentationStyle? modalPresentationStyle;

  const SafariCustomizationOptions({
    this.preferredBarTintColor,
    this.preferredControlTintColor,
    this.dismissButtonStyle,
    this.modalPresentationStyle,
  });

  Map<String, dynamic> toMap() {
    return {
      if (preferredBarTintColor != null)
        'preferredBarTintColor': preferredBarTintColor,
      if (preferredControlTintColor != null)
        'preferredControlTintColor': preferredControlTintColor,
      if (dismissButtonStyle != null)
        'dismissButtonStyle': dismissButtonStyle!.name,
      if (modalPresentationStyle != null)
        'modalPresentationStyle': modalPresentationStyle!.name,
    };
  }
}
