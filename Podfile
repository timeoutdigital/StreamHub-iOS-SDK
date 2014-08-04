platform :ios, '6.0'
xcodeproj 'LFSClient.xcodeproj'

link_with 'LFSClient'
pod 'AFNetworking', '~> 2.3.0'
pod 'JWT', '~> 1.0.3'
pod 'Base64', '~> 1.0.1'
pod 'NSString-Hashes', '~> 1.2.0'
pod 'LFJSONKit', '~> 1.6a'

target :test, :exclusive => true do
    link_with 'LFSClientTests'
    platform :ios, '7.0'
    #pod 'Kiwi/XCTest'
    pod 'OHHTTPStubs'
    pod 'XCTest+OHHTTPStubSuiteCleanUp'
    pod 'JWT', '~> 1.0.3'
    pod 'Base64', '~> 1.0.1'
    pod 'NSString-Hashes', '~> 1.2.0'
    pod 'AFHTTPRequestOperationLogger', '~> 2.0.0'
    pod 'LFJSONKit', '~> 1.6a'
    pod 'Expecta', '~> 0.2.1' # readable pass conditions
end
