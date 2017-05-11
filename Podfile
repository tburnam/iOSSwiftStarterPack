platform :ios, '10.0'

target 'iOSSwiftStarterPack' do
  use_frameworks!

  # Pods for starterpack
  pod 'RealmSwift'
  pod 'SwiftLint'
  pod 'Alamofire', '~> 4.4'

  target 'iOSSwiftStarterPackTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'iOSSwiftStarterPackUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
