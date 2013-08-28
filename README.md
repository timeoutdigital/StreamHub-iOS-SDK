StreamHub-iOS-SDK
=================

Make iOS apps powered by Livefyre StreamHub

Read the docs: http://livefyre.github.com/StreamHub-iOS-SDK/

# Using

Drag LFSClient into your Xcode workspace

Import the Clients that you'd like to use

# iOS SDK Getting Started

Clone the repo:

    git clone git@github.com:Livefyre/StreamHub-iOS-SDK.git

Setup test config:
    
    mv LFSClientTests/TestConfig.plist.sample LFSClientTests/TestConfig.plist

Then edit `TestConfig.plist' to include your network info. When done, open the project in Xcode:

    open LFSClient/LFSClient.xcodeproj/

Make sure you've selected the iOS Emulator as your Device in Xcode

Run the Unit Tests

    Type Cmd+'U' to run the unit tests
