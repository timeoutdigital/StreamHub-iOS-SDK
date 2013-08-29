Pod::Spec.new do |s|
  s.name         = "StreamHub-iOS-SDK"
  s.version      = "0.2.0"
  s.summary      = "A client library for Livefyre's API"
  s.description  = <<-DESC
                   A longer description of StreamHub-iOS-SDK in Markdown format.
                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
  s.homepage     = "https://github.com/escherba/StreamHub-iOS-SDK"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "JJ Weber" => "jj@livefyre.com", "Eugene Scherba" => "escherba@livefyre.com" }
  s.platform     = :ios
  s.ios.deployment_target = '6.0'
  s.source       = { :git => "https://github.com/escherba/StreamHub-iOS-SDK.git", :tag => "0.2.0" }
  s.ios.prefix_header_file = 'LFSClient/LFSClient-Prefix.pch'
  s.source_files  = 'LFSClient/**/*.{h,m}'
  s.requires_arc = true
  s.subspec 'no-arc' do |sp|
    sp.source_files = 'JSONKit/**/*.{h,m}'
    sp.requires_arc = false
  end
  s.dependency 'AFNetworking', '~> 1.3.2'
  s.dependency 'JWT', '~> 1.0.3'
  s.dependency 'Base64', '~> 1.0.1'
  s.dependency 'NSString-Hashes', '~> 1.2.0'
end
