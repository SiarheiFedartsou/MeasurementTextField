#
# Be sure to run `pod lib lint MeasurementTextField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MeasurementTextField'
  s.version          = '0.1.4'
  s.summary          = 'TextField-based control for (NS)Measurement values input'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
UITextField-based control for (NS)Measurement values input. Provides type-safe keyboard and picker based input of different measurement such as length, mass, speed etc.
                       DESC

  s.homepage         = 'https://github.com/SiarheiFedartsou/MeasurementTextField'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SiarheiFedartsou' => 'siarhei.fedartsou@gmail.com' }
  s.source           = { :git => 'https://github.com/SiarheiFedartsou/MeasurementTextField.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'MeasurementTextField/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MeasurementTextField' => ['MeasurementTextField/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
