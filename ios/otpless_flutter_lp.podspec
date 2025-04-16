#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint otpless_flutter_lp.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'otpless_flutter_lp'
  s.version          = '0.0.1'
  s.summary          = 'A Swift SDK for integrating Otpless Pre Build UI.'
  s.description      = <<-DESC
                          OtplessSwiftLP is a Swift-based SDK that enables seamless 
                          integration with the Otpless platform for user authentication, using the Pre Built UI provided by Otpless.
                         DESC
  s.homepage         = 'https://github.com/otpless-tech/iOS-LP'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Otpless' => 'developer@otpless.com' }
  s.source           = { :git => 'https://github.com/otpless-tech/iOS-LP.git', :tag => s.version.to_s }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'OtplessSwiftLP', '1.0.1'
  s.ios.deployment_target = '13.0'

  s.swift_versions = ['5.5']
end
