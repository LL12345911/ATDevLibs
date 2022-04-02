#
#  Be sure to run `pod spec lint ATDevLibs.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name         = "ATDevLibs"
s.version      = "1.0.3"
s.summary      = "iOS开发基本库"

s.description  = <<-DESC
***
iOS开发基本库
***
DESC
s.homepage     = "https://github.com/LL12345911/ATDevLibs"
s.license      = { :type => "MIT", :file => 'LICENSE' }
s.author             = { "Mars" => "sky12345911@163.com" }
s.authors      = { "Mars" => "sky12345911@163.com" }
s.platform     = :ios, '9.0'
s.source       = {:git => 'https://github.com/LL12345911/ATDevLibs.git', :tag => s.version}
s.social_media_url = 'https://github.com/LL12345911/ATDevLibs'
s.source_files = 'ATDevLibs/*.{h,m}' #'UIKitLib/*.{h,m}','FoundationKitLib/*.{h,m}','ShareLib/*.{h,m}','ShareLib/*.{h,m}',



#  UIKitLib
s.subspec 'UIKitLib' do |ss|
ss.source_files = 'ATDevLibs/UIKitLib/**/*.{h,m}'
end

#  FoundationKitLib
s.subspec 'FoundationKitLib' do |ss|
ss.source_files = 'ATDevLibs/FoundationKitLib/**/*.{h,m}'
end

#  ShareLib
s.subspec 'ShareLib' do |ss|
ss.source_files = 'ATDevLibs/ShareLib/**/*.{h,m}'
end

#  AuthorizeRequestLib
s.subspec 'AuthorizeRequestLib' do |ss|
ss.source_files = 'ATDevLibs/AuthorizeRequestLib/**/*.{h,m}'
end

#  PPCounter
s.subspec 'PPCounter' do |ss|
ss.source_files = 'ATDevLibs/PPCounter/**/*.{h,m}'
end

s.requires_arc = true
s.ios.frameworks = 'UIKit','Foundation'
s.ios.deployment_target = '9.0'

end
