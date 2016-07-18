#
# Be sure to run `pod lib lint MVImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name = 'MVImagePicker'
    s.version = '1.0.0'
    s.summary = 'MVImagePicker allows you to inject the photo library to your app'

    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description = <<-DESC
        MVImagePicker allows you to inject the photo library to your app and to pick images from it.
        That is an attempt to create instagram-like image picker.
    DESC

    s.homepage = 'https://github.com/mvetoshkin/MVImagePicker'
    s.screenshots = [
        'https://cloud.githubusercontent.com/assets/882141/16874775/578cd18e-4aac-11e6-802e-dc614d92a52e.PNG',
        'https://cloud.githubusercontent.com/assets/882141/16874806/7c261190-4aac-11e6-9103-19fb6d21965a.PNG'
    ]
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'Mikhail Vetoshkin' => 'mvetoshkin@gmail.com' }
    s.source = { :git => 'https://github.com/mvetoshkin/MVImagePicker.git', :tag => s.version.to_s }

    s.ios.deployment_target = '8.0'

    s.source_files = 'MVImagePicker/Classes/**/*'
    s.resource_bundles = {
        'MVImagePicker' => ['MVImagePicker/Assets/**/*.png']
    }

    # s.public_header_files = 'Pod/**/*.h'

    s.frameworks = 'UIKit', 'Photos'
    s.dependency 'SnapKit'
end
