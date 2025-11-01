# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'SoundScape' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SoundScape
  pod 'SwiftLint'

  # Firebase - use version 10.x for Xcode 16 compatibility
  pod 'Firebase/Firestore', '~> 10.0'
  pod 'FirebaseFirestoreSwift', '~> 10.0'
  pod 'Firebase/Storage', '~> 10.0'
  pod 'Firebase/Database', '~> 10.0'
  pod 'Firebase/Auth', '~> 10.0'
  pod 'Firebase/Crashlytics', '~> 10.0'

  pod 'IQKeyboardManagerSwift'
  pod 'lottie-ios'
  pod 'GoogleMaps', '~> 9.0'
  pod 'GooglePlaces', '~> 9.0'
  pod 'SPAlert'
  pod 'JGProgressHUD'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end

  # Fix BoringSSL-GRPC compiler flags in the project file
  project_file_path = File.join(installer.pods_project.path, 'project.pbxproj')
  project_content = File.read(project_file_path)
  project_content.gsub!('-GCC_WARN_INHIBIT_ALL_WARNINGS ', '')
  File.write(project_file_path, project_content)
end
