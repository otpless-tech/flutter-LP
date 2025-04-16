#import "OtplessFlutterLP.h"
#if __has_include(<otpless_flutter_lp/otpless_flutter_lp-Swift.h>)
#import <otpless_flutter_lp/otpless_flutter_lp-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "otpless_flutter_lp-Swift.h"
#endif

@implementation OtplessFlutterLP
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOtplessFlutterLP registerWithRegistrar:registrar];
}
@end
