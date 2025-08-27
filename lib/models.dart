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

/// class for model response
///
///
class OtplessResult {
  const OtplessResult();

  factory OtplessResult.fromJson(Map<String, dynamic> json) {
    final status = json["type"] as String?;
    if ("success" == status) {
      return OtplessResultSuccess(
        token: json["token"] ?? "",
        traceId: json['traceId'] ?? '',
        jwtToken: json['jwtToken'] ?? '',
      );
    } else {
      return OtplessResultError(
        errorType: ErrorType.values.firstWhere(
          (t) => t.name.toUpperCase() == json["errorType"],
          orElse: () => ErrorType.initiate,
        ),
        errorCode: json['errorCode'] ?? 0,
        errorMessage: json['errorMessage'] ?? "",
        traceId: json['traceId'] ?? "",
      );
    }
  }
}

class OtplessResultSuccess extends OtplessResult {
  final String token;
  final String traceId;
  final String jwtToken;

  const OtplessResultSuccess({
    required this.token,
    required this.traceId,
    this.jwtToken = "",
  });
}

class OtplessResultError extends OtplessResult {
  final ErrorType errorType;
  final int errorCode;
  final String errorMessage;
  final String traceId;

  const OtplessResultError({
    required this.errorType,
    required this.errorCode,
    required this.errorMessage,
    required this.traceId,
  });
}

enum ErrorType { initiate, verify, network }

extension ErrorTypeName on ErrorType {
  String get name => toString().split(".").last;
}

/// classes for otpless event
///
///

enum EventCategory { action, click, load }

extension EventCategoryName on EventCategory {
  String get name => toString().split(".").last;
}

enum EventType {
  initiate,
  verifyError,
  otpAutoRead,
  deliveryStatus,
  fallbackTriggered,
  phoneChange,
  verify,
  resend,
  pageLoaded,
  custom
}

extension EventTypeName on EventType {
  String get name => toString().split('.').last;
}

class OtplessEventData {
  final EventCategory category;
  final EventType eventType;
  final Map<String, dynamic>? metaData;

  const OtplessEventData({
    required this.category,
    required this.eventType,
    required this.metaData,
  });

  factory OtplessEventData.fromMap(Map<String, dynamic> json) {
    return OtplessEventData(
      category: EventCategory.values.firstWhere(
        (e) => e.name.toUpperCase() == json['category'],
        orElse: () => EventCategory.action,
      ),
      eventType: EventType.values.firstWhere(
        (e) => e.name.toUpperCase() == json['eventType'],
        orElse: () => EventType.custom,
      ),
      metaData: json['metaData'] != null
          ? Map<String, dynamic>.from(json['metaData'])
          : null,
    );
  }

  @override
  String toString() {
    return "category: ${category.name}, eventType: ${eventType.name}, metaData: $metaData";
  }
}
