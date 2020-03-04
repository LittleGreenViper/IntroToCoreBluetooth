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
// MARK: - Main SDK Central Variant Interface Class -
/* ###################################################################################################################################### */
/**
 These are the observer notification message senders.
 */
internal extension ITCB_SDK_Central {
    /* ################################################################## */
    /**
     We override the typeless stored property with a computed one, and instantiate our manager, the first time through.
     */
    override var _managerInstance: Any! {
        get {
            if nil == super._managerInstance {
                super._managerInstance = CBCentralManager(delegate: self, queue: nil)
            }
            
            return super._managerInstance
        }
        
        set {
            super._managerInstance = newValue
        }
    }

    /* ################################################################## */
    /**
     This is a specific cast of the manager object that wil be attached to this instance.
     */
    var centralManagerInstance: CBCentralManager! {
        managerInstance as? CBCentralManager
    }

    /* ################################################################## */
    /**
     This sends the "A question was asked" message to all registered observers.
     
     - parameter device: The Peripheral device that contains the question.
     */
    func _sendSuccessInAskingMessageToAllObservers(device inDevice: ITCB_Device_Peripheral_Protocol) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Central_Protocol {
                observer.questionAskedOfDevice(inDevice)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sends the "A question was asked and answered" message to all registered observers.
     
     - parameter device: The Peripheral device that contains the question and the answer.
     */
    func _sendQuestionAnsweredMessageToAllObservers(device inDevice: ITCB_Device_Peripheral_Protocol) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Central_Protocol {
                observer.questionAnsweredByDevice(inDevice)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CBCentralManagerDelegate Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Central: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     This is called as the state changes for the Central manager object.
     
     - parameter inCentral: The Central instance that changed state.
     */
    public func centralManagerDidUpdateState(_ inCentral: CBCentralManager) {
        assert(inCentral === managerInstance)   // Make sure that we are who we say we are...
        // Once we are powered on, we can start scanning.
        if .poweredOn == inCentral.state {
            inCentral.scanForPeripherals(withServices: [_static_ITCB_SDK_8BallServiceUUID], options: [:])
        }
    }
    
    /* ################################################################## */
    /**
     This is called as the state changes for the Central manager object.
     
     - parameters:
        - inCentral: The Central instance that changed state.
        - didDiscover: This is the Core Bluetooth Peripheral instance that was discovered.
        - advertisementData: This is the adverstiement data that was sent by the discovered Peripheral.
        - rssi: This is the signal strength of the discovered Peripheral.
     */
    public func centralManager(_ inCentral: CBCentralManager, didDiscover inPeripheral: CBPeripheral, advertisementData inAdvertisementData: [String : Any], rssi inRSSI: NSNumber) {
        print("Device: \(String(describing: inPeripheral)) was discovered, at a signal strength of \(inRSSI), and with this advertisement Data: \(String(describing: inAdvertisementData)).")
    }
}

/* ###################################################################################################################################### */
// MARK: - Central Device Base Class -
/* ###################################################################################################################################### */
/**
 We need to keep in mind that Central objects are actually owned by Peripheral SDK instances.
 */
internal class ITCB_SDK_Device_Central: ITCB_SDK_Device, ITCB_Device_Central_Protocol {
    /// This is the Peripheral SDK that "owns" this device.
    internal var owner: ITCB_SDK_Peripheral!
    
    /// This is the Central Core Bluetooth device associated with this instance.
    internal var peripheralDeviceInstance: CBCentral! {
        _peerInstance as? CBCentral
    }
    
    /* ################################################################## */
    /**
     In the base class, all we do is send the "success" message to any observers.
     
     This should be called AFTER successfully sending the message.

     - parameter inAnswer: The answer.
     - parameter toQuestion: The question that was be asked.
     */
    public func sendAnswer(_ inAnswer: String, toQuestion inToQuestion: String) {
        /* ########### */
        // TODO: Put code in here to send the answer via Bluetooth, and remove the random error.
        if 5 == Int.random(in: 0..<10) {
            // We randomly (one out of 10 times) send an error message, instead of the question. We choose an unknown error rejection
            owner._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(nil)))
        } else {
            owner._sendSuccessInSendingAnswerToAllObservers(device: self, answer: inAnswer, toQuestion: inToQuestion)
        }
        // END TODO
        /* ########### */
    }
}
