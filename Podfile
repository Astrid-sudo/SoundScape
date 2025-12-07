# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'SoundScape' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SoundScape
  pod 'SwiftLint'

  # Firebase - use latest version with fixed gRPC
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'

  pod 'IQKeyboardManagerSwift'
  pod 'lottie-ios'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'SPAlert'
  pod 'JGProgressHUD'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'

      # Fix for gRPC-C++ and gRPC-Core template errors with Xcode 16
      if target.name == 'gRPC-C++' || target.name == 'gRPC-Core'
        config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
        config.build_settings['WARNING_CFLAGS'] ||= ['$(inherited)']
        config.build_settings['WARNING_CFLAGS'] << '-Wno-error=missing-template-arg-list-after-template-kw'
      end
    end
  end

  # Fix BoringSSL-GRPC -GCC_WARN_INHIBIT_ALL_WARNINGS flag
  project_path = installer.pods_project.path
  project_file_path = File.join(project_path, 'project.pbxproj')

  if File.exist?(project_file_path)
    project_content = File.read(project_file_path)
    modified_content = project_content.gsub(/-GCC_WARN_INHIBIT_ALL_WARNINGS\s*/, '')
    File.write(project_file_path, modified_content)
    puts "Fixed BoringSSL-GRPC compiler flags"
  end
end
