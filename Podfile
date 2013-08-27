platform :ios, '6.0'
xcodeproj 'LFClient.xcodeproj'

target :default do
	link_with 'LFClient'
	pod 'AFNetworking', '~> 1.3.2'
	pod 'JWT', '~> 1.0.3'
	pod 'Base64', '~> 1.0.1'
	pod 'NSString-Hashes', '~> 1.2.0'
end

target :test do
    link_with 'LFClientTests'
	pod 'Base64', '~> 1.0.1'
	pod 'AFHTTPRequestOperationLogger', '~> 0.10.0'
    pod 'OCMock', '~> 2.1.1' # mock objects
    pod 'Expecta', '~> 0.2.1' # readable pass conditions
end
