![Icon](icon.png)

A Quick  Introduction To Core Bluetooth
=
This is a repo that will accompany [a series of posts on introduction to Core Bluetooth](https://littlegreenviper.com/series/bluetooth/).

The "working code" for the repo is in the `SDK-Src` directory. This will be a simple framework project that implements a very simple "[Magic 8-Ball](https://en.wikipedia.org/wiki/Magic_8-Ball)" application that runs on two different Apple devices.

One device acts as a [Bluetooth Central](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) device, and the other as a [Bluetooth Peripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager) device.

The user "asks a question" from the Central device, and "gets an answer" from a Peripheral device.

The communication between the devices is Bluetooth Low Energy, managed by [Apple's Core Bluetooth API](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html#//apple_ref/doc/uid/TP40013257-CH1-SW1).

The `Apps-src` directory contains 4 applications. These are for each of the Apple platforms: [Mac](https://apple.com/macos), [iOS/iPadOS](https://apple.com/ios), [Watch](https://apple.com/watchos), and [TV](https://apple.com/tvos).