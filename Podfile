# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'

target 'projecthang' do
  # Uncomment this line if you're using Swift or would like to use dynamic frameworks
   use_frameworks!

  # Pods for projecthang
   pod 'AFNetworking', '~> 3.0'
   pod 'DLImageLoader'
   pod 'Reveal-iOS-SDK', :configurations => ['Debug']
   pod 'JSQMessagesViewController'
   pod 'XLForm', '~> 3.0'
   pod 'IDMPhotoBrowser'
   pod 'OHQBImagePicker'
   pod 'Socket.IO-Client-Swift', '~> 8.0.2'
   pod 'SVProgressHUD'
   pod 'HHRouter', '~> 0.1.9'
   pod 'GooglePlacePicker', '= 2.0.1'
   pod 'GooglePlaces', '= 2.0.1'
   pod 'GoogleMaps', '= 2.0.1'
   pod 'AWSS3', '~> 2.4.1'
   pod 'JLRoutes'
   pod 'ASHorizontalScrollViewForObjectiveC', '~> 1.2'
   pod 'GoogleAPIClient/Drive', '~> 1.0.2'
   pod 'GTMOAuth2', '~> 1.1.0'
   pod 'box-ios-sdk'
   pod 'SwiftyDropbox'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.0'
			config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
		end
	end
end