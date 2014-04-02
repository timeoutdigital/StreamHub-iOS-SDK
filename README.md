StreamHub-iOS-SDK
=================

Use this open-source library to integrate Livefyre services into your native iOS app.  This SDK provides a thin layer for common API mechanisms and endpoints on top of the excellent AFNetworking stack.

For more information, please see the CommentStream sample app [[1]] or Livefyre HTTP API documentation [[2]].

## Getting Started

If you just want to download the SDK and take a look at the sample app(s),
follow these steps:

    cd ~/dev
    git clone https://github.com/Livefyre/StreamHub-iOS-SDK.git
    cd StreamHub-iOS-SDK
    git submodule init
    git submodule update
    pod install
    cd examples/CommentStream
    pod install
    open CommentStream.xcworkspace

## Integrating the SDK into your project

### As a Cocoa Pod (recommended)

The most convenient way to add StreamHub SDK to your project is to use CocoaPods. StreamHub SDK does not yet have a spec on CocoaPods.org, so for now just specify the Github repository when adding it to your pods. An example Podfile:

    platform :ios, :deployment_target => '6.0'

    pod 'StreamHub-iOS-SDK', :git => 'https://github.com/Livefyre/StreamHub-iOS-SDK'

Note that the above command will use the latest commit from master branch on GitHub. You can force CocoaPods to use a particular commit by appending to the command above the following: `:commit => '2523e6f500bab738d04ff68bae1545869ad2543a'`. Once your Podfile is placed in your app project root, simply run:

    pod install

This will download all the dependencies and create a file called `MyApp.xcworkspace` which you should use to open your app project in Xcode in the future.

### As an Xcode subproject

Alternatively, clone the repository:

    git clone https://github.com/Livefyre/StreamHub-iOS-SDK.git

Next, add the Xcode project (LFSClient.xcodeproj) to your app as a subproject (easily done by simply dragging the LFSClient.xcodeproj file into Project Navigator pane in Xcode).

## Xcode Documentation

You can browse the documentation online [[3]] or you can build the "Documentation" target in your Xcode (requires `appledoc` to be installed) on your system.

## Requirements

StreamHub iOS SDK versions since v0.2.0 require iOS 6.0 or higher.

## License

This software is licensed under the MIT License.

The MIT License (MIT)

Copyright (c) 2013 Livefyre

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


[1]: https://github.com/Livefyre/StreamHub-iOS-Example-App
[2]: http://answers.livefyre.com/developers/reference/http-reference/
[3]: http://livefyre.github.com/StreamHub-iOS-SDK/
