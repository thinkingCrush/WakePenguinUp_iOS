# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'

target 'WakePenguinUp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WakePenguinUp
  pod 'ImageSlideshow', '~> 1.8'
  pod 'MBCircularProgressBar'
  pod 'SideMenu', '~> 6.0.0'
  pod 'FlexColorPicker'

  target 'WakePenguinUpTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'WakePenguinUpUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
