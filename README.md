![Icon](icon.png)

A Quick  Introduction To Core Bluetooth
=
[This is a repo](https://github.com/LittleGreenViper/IntroToCoreBluetooth) that will accompany [a series of posts on introduction to Core Bluetooth](https://littlegreenviper.com/series/bluetooth/).

The "working code" for the repo is in the [`SDK-Src`](https://github.com/LittleGreenViper/IntroToCoreBluetooth/tree/master/SDK-src) directory. This will be a simple framework project that implements a very simple "[Magic 8-Ball](https://en.wikipedia.org/wiki/Magic_8-Ball)" application that runs on two different Apple devices.

One device acts as a [Bluetooth Central](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) device, and the other as a [Bluetooth Peripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager) device.

 **IMPORTANT NOTE:** Peripheral Mode is not supported for WatchOS or TVOS. Those targets will only support Bluetooth Central Mode.

The user "asks a question" from the Central device, and "gets an answer" from a Peripheral device.

The communication between the devices is Bluetooth Low Energy, managed by [Apple's Core Bluetooth API](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html#//apple_ref/doc/uid/TP40013257-CH1-SW1).

The [`Apps-src`](https://github.com/LittleGreenViper/IntroToCoreBluetooth/tree/master/Apps-src) directory contains 4 pre-written applications. These are for each of the Apple platforms: [Mac](https://apple.com/macos), [iOS/iPadOS](https://apple.com/ios), [Watch](https://apple.com/watchos), and [TV](https://apple.com/tvos).

The way that the progress of the lesson is tracked, is through [a series of Git tags](https://github.com/LittleGreenViper/IntroToCoreBluetooth/releases). This is different from the traditional "zip-compressed file" that people may be used to. Using Git allows a much more intimate examination of the code, and there's a great many moving parts that need to be tracked.