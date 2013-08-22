platform :ios, '5.0'
xcodeproj 'LFClient.xcodeproj'

link_with ['LFClient', 'LFClientTests']
pod 'AFNetworking', '~> 1.3.2'

target :test, :exclusive => true do
    link_with 'LFClientTests'
	pod 'AFHTTPRequestOperationLogger', '~> 0.10.0'
    pod 'OCMock', '~> 2.1.1' # mock objects
    pod 'Expecta', '~> 0.2.1' # readable pass conditions
end
