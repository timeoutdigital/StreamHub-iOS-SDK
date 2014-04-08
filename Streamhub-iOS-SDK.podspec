Pod::Spec.new do |s|
  s.name         = "StreamHub-iOS-SDK"
  s.version      = "0.3.0"
  s.summary      = "A client library for Livefyre's API"
  s.description  = <<-DESC
StreamHub-iOS is the official Livefyre SDK for building real-time native iOS apps that interact with Livefyre services. With it, you can easily create apps that obtain user-generated content sourced by Livefye, poll for updates, and create or modify content.
                   DESC
  s.homepage     = "https://github.com/Livefyre/StreamHub-iOS-SDK"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "JJ Weber" => "jj@livefyre.com", "Eugene Scherba" => "escherba@livefyre.com" }
  s.platform     = :ios
  s.ios.deployment_target = '6.0'
  s.source       = { :git => 'https://github.com/Livefyre/StreamHub-iOS-SDK.git', :tag => "0.3.0" }
  s.resources    = 'LFSClient/Resources/*'
  s.subspec 'arc' do |sp|
    s.ios.prefix_header_file = 'LFSClient/LFSClient-Prefix.pch'
    s.source_files  = 'LFSClient/**/*.{h,m}'
    s.requires_arc = true
    s.dependency 'AFNetworking', '~> 2.2.1'
    s.dependency 'JWT', '~> 1.0.3'
    s.dependency 'Base64', '~> 1.0.1'
    s.dependency 'NSString-Hashes', '~> 1.2.0'
    s.dependency 'AFHTTPRequestOperationLogger', '~> 2.0.0'
  end
  s.subspec 'no-arc' do |sp|
    sp.requires_arc = false
    s.dependency 'LFJSONKit', '~> 1.6a'
  end
end
