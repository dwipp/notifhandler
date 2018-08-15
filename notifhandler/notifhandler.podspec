#
#  Be sure to run `pod spec lint notifhandler.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "notifhandler"
  s.version      = "0.1.4"
  s.summary      = "Simple notif handler for testing"
  s.description  = "This is a super cool framework dude. you need to install this one"
  s.homepage     = "https://github.com/dwipp/notifhandler"
  s.license      = "MIT"
  s.author             = { "Dwi Permana Putra" => "dwi.putra@icloud.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/dwipp/notifhandler.git", :tag => "0.1.4" }
  s.source_files = "notifhandler/**/*"
#s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.frameworks = "UIKit", "UserNotifications"

end
