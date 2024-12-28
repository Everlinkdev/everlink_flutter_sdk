Pod::Spec.new do |s|
  s.name             = 'everlink_sdk'
  s.version          = '2.0.0-beta.1'
  s.summary          = 'The Everlink SDK for Flutter.'
  s.description      = <<-DESC
Allows apps developed using Flutter to use Everlink native SDKs to enable proximity verification.
                       DESC
  s.homepage         = 'https://everlink.co/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Everlink' => 'nathan@everlink.co' }
  s.source           = { :path => '.' }
  s.module_map       = 'Classes/EverlinkSdkPlugin.modulemap' 
  s.public_header_files = 'Classes/**/*.h',
  s.source_files = 'Classes/**/*.{h,m,swift}'
  s.dependency 'Flutter'
  s.dependency 'EverlinkBroadcastSDK', '3.1.1'
  s.platform = :ios, '12.0'

  # Swift version
  s.swift_version = '4.2'

  # Exclude unsupported architecture for simulator
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  # Define module map
  # s.module_map = 'Classes/everlink_sdk.modulemap'

  # If your plugin requires privacy manifest
  s.resource_bundles = {'everlink_sdk_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
