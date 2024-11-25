platform :ios, '14.0'

target 'Moves' do
  use_frameworks!
  project 'Moves.xcodeproj'
  
  # Core dependencies
  pod 'SDWebImage', '~> 5.0'
  pod 'DPOTPView'
  pod 'PhoneNumberKit', '~> 3.7'
  pod 'Toast-Swift', '~> 5.1.1'
  pod 'Alamofire'

  # Firebase dependencies
  pod 'FirebaseFunctions'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'FirebaseDatabase'
  pod 'FirebaseMessaging'

  # Google and Facebook SDKs
  pod 'GoogleSignIn'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'

  # Media and Animation
  pod 'SwiftVideoGenerator'
  pod 'GSPlayer'
  pod 'NextLevel', '~> 0.16.3'
  pod 'YPImagePicker'
  pod 'PryntTrimmerView'
  pod 'CoreAnimator'
  pod 'lottie-ios'

  # UI Enhancements
  pod 'SVProgressHUD'
  pod 'GrowingTextView', '0.7.2'
  pod 'SkeletonView'
  pod 'BadgeControl'
  pod 'GTProgressBar'
  pod 'TextFieldFormatter'
  pod 'MarqueeLabel'
  pod 'JXSegmentedView'
  pod 'DZNEmptyDataSet'

  # Video and Cache
  pod 'ZFPlayer'
  pod 'ZFPlayer/ControlView'
  pod 'KTVHTTPCache'
  pod 'QCropper'

  # Debugging
  pod 'CocoaDebug', :configurations => ['Debug']

  # Miscellaneous
  pod 'MJRefresh'
  pod 'ZoomingTransition'
  pod 'SwiftyStoreKit'
  pod 'AgoraRtcEngine_iOS'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Ensure deployment target matches project
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'

      # Fix BoringSSL-GRPC warnings
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
    end
  end
end


#platform :ios, '12.0'
#use_frameworks!
#
#project 'Moves.xcodeproj'
#
#target 'Moves' do
#  pod 'Alamofire' # Example dependency
#end
#
