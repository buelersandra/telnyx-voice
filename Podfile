# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'TelnyxVoice' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TelnyxVoice
  pod 'TelnyxRTC', '~> 0.1.3'
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'
  pod 'RxFlow'
  

  target 'TelnyxVoiceTests' do
    inherit! :search_paths
    pod 'RxBlocking', '6.5.0'
    pod 'RxTest', '6.5.0'
  end

 

end

#Disable bitecode -> WebRTC pod doesn't have bitcode enabled
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
