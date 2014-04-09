platform :ios, '6.0'
xcodeproj 'LFSClient.xcodeproj'

link_with 'LFSClient'
pod 'AFNetworking', '~> 2.2.1'
pod 'JWT', '~> 1.0.3'
pod 'Base64', '~> 1.0.1'
pod 'NSString-Hashes', '~> 1.2.0'
pod 'LFJSONKit', '~> 1.6a'

target :test do
    link_with 'LFSClientTests'
    pod 'JWT', '~> 1.0.3'
    pod 'Base64', '~> 1.0.1'
    pod 'NSString-Hashes', '~> 1.2.0'
    pod 'AFHTTPRequestOperationLogger', '~> 2.0.0'
    pod 'LFJSONKit', '~> 1.6a'
    pod 'OCMock', '~> 2.1.1' # mock objects
    pod 'Expecta', '~> 0.2.1' # readable pass conditions
end
