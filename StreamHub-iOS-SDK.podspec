Pod::Spec.new do |s|
  s.name         = "StreamHub-iOS-SDK"
  s.version      = "0.2.3"
  s.summary      = "A client library for Livefyre's API"
  s.description  = <<-DESC
The StreamHub-iOS-SDK is a framework for building native iOS apps that interact with Livefyre services.
It lets you create apps that obtain user-generated content through Livefyre, poll for updates, and modify content.
                   DESC
  s.homepage     = "https://github.com/Livefyre/StreamHub-iOS-SDK"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "JJ Weber" => "jj@livefyre.com", "Eugene Scherba" => "escherba@livefyre.com" }
  s.platform     = :ios
  s.ios.deployment_target = '6.0'
  s.source       = { :git => "https://github.com/Livefyre/StreamHub-iOS-SDK.git", :tag => "0.2.3" }
  s.resources    = 'LFSClient/Resources/*'
  s.subspec 'arc' do |sp|
    sp.ios.prefix_header_file = 'LFSClient/LFSClient-Prefix.pch'
    sp.source_files  = 'LFSClient/**/*.{h,m}'
    sp.requires_arc = true
    sp.dependency 'AFNetworking', '~> 1.3.2'
    sp.dependency 'JWT', '~> 1.0.3'
    sp.dependency 'Base64', '~> 1.0.1'
    sp.dependency 'NSString-Hashes', '~> 1.2.0'
  end
  s.subspec 'no-arc' do |sp|
    sp.requires_arc = false
    sp.dependency 'LFJSONKit', '~> 1.6a'
  end
end
