Pod::Spec.new do |s|
  s.name             = 'everlink_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.module_map       = 'Classes/EverlinkSdkPlugin.modulemap' 
  s.public_header_files = 'Classes/**/*.h',
  s.source_files = 'Classes/**/*.{h,m,swift}'
  s.dependency 'Flutter'
  s.dependency 'EverlinkBroadcastSDK', '3.0.0-beta.2'
  s.platform = :ios, '12.0'

  # Swift version
  s.swift_version = '5.0'

  # Exclude unsupported architecture for simulator
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  # Define module map
  # s.module_map = 'Classes/everlink_sdk.modulemap'

  # If your plugin requires privacy manifest
  s.resource_bundles = {'everlink_sdk_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
