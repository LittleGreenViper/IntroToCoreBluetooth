/*
© Copyright 2020, Little Green Viper Software Development LLC

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Little Green Viper Software Development LLC: https://littlegreenviper.com
*/

import Foundation
import CoreBluetooth

/* ###################################################################################################################################### */
// MARK: - Main SDK Peripheral Variant Interface Class -
/* ###################################################################################################################################### */
/**
 These are the observer notification message senders.
 */
internal extension ITCB_SDK_Peripheral {
    /* ################################################################## */
    /**
     This is a specific cast of the manager object that wil be attached to this instance.
     */
    var peripheralManagerInstance: CBPeripheralManager! {
        managerInstance as? CBPeripheralManager
    }

    /* ################################################################## */
    /**
     We override the typeless stored property with a computed one, and instantiate our manager, the first time through.
     */
    override var _managerInstance: Any! {
        get {
            if nil == super._managerInstance {
                super._managerInstance = CBPeripheralManager()
                peripheralManagerInstance.delegate = self   // TVOS doesn't seem to have a proper delegate initializer, so we have an extra step, here.
            }
            
            return super._managerInstance
        }
        
        set {
            super._managerInstance = newValue
        }
    }

    /* ################################################################## */
    /**
     This sends the "An answer was successfully sent" message to all registered observers.

     - parameters:
        - device: The Central device
        - answer: The answer that was sent
        - toQuestion: The question that was asked
     */
    func _sendSuccessInSendingAnswerToAllObservers(device inDevice: ITCB_Device_Central_Protocol, answer inAnswer: String, toQuestion inToQuestion: String) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Peripheral_Protocol {
                observer.answerSentToDevice(inDevice, answer: inAnswer, toQuestion: inToQuestion)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sends the "A question was asked" message to all registered observers.
     
     - parameters:
        - device: The Central device
        - question: The question that was asked
     */
    func _sendQuestionAskedToAllObservers(device inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Peripheral_Protocol {
                observer.questionAskedByDevice(inDevice, question: inQuestion)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralManagerDelegate Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Peripheral: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ inPeripheral: CBPeripheralManager) {
        assert(inPeripheral === managerInstance)   // Make sure that we are who we say we are...
        // Once we are powered on, we can start advertising.
        if .poweredOn == inPeripheral.state {
            inPeripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [_static_ITCB_SDK_8BallServiceUUID],
                                           CBAdvertisementDataLocalNameKey: localName
            ])
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Peripheral Device Base Class -
/* ###################################################################################################################################### */
/**
 We need to keep in mind that Peripheral objects are actually owned by Central SDK instances.
 */
internal class ITCB_SDK_Device_Peripheral: ITCB_SDK_Device, ITCB_Device_Peripheral_Protocol {
    /// This is the Central SDK that "owns" this device.
    internal var owner: ITCB_SDK_Central!

    /// The question property to conform to the protocol.
    public var question: String! = nil {
        didSet {
            owner._sendSuccessInAskingMessageToAllObservers(device: self)
        }
    }

    /// The answer property to conform to the protocol.
    /// We use this opportunity to let everyone know that the question has been answered.
    public var answer: String! = nil {
        didSet {
            owner._sendQuestionAnsweredMessageToAllObservers(device: self)
        }
    }
    
    /// This is the Peripheral Core Bluetooth device associated with this instance.
    internal var peripheralDeviceInstance: CBPeripheral! {
        _peerInstance as? CBPeripheral
    }

    /* ################################################################## */
    /**
     In the base class, all we do is send the "success" message to any observers.
     
     This should be called AFTER successfully sending the message.

     - parameter inQuestion: The question to be asked.
     */
    public func sendQuestion(_ inQuestion: String) {
        self.question = inQuestion
        /* ########### */
        // TODO: Remove this code, after we get the Bluetooth working. This is just here to create mock behavior.
        DispatchQueue.global().async {  // We use the global thread to simulate true async operation.
            if 5 == Int.random(in: 0..<10) {
                // We randomly (one out of 10 times) send an error message, instead of the question. We choose an unknown error rejection
                self.owner._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(nil)))
            } else {
                self.answer = String(format: "SLUG-ANSWER-%02d", Int.random(in: 0..<20))
            }
        }
        // END TODO
        /* ########### */
    }
}
