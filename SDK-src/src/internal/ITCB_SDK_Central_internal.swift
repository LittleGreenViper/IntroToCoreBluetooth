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
    
    /* ################################################################## */
    /**
     This sends a device discovery message to all registered observers.
     
     - parameter device: The Peripheral device that was discovered.
     */
    func _sendDeviceDiscoveredMessageToAllObservers(device inDevice: ITCB_Device_Peripheral_Protocol) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Central_Protocol {
                observer.deviceDiscovered(inDevice)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - ITCB_SDK_Device_PeripheralDelegate Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Central: ITCB_SDK_Device_PeripheralDelegate {
    func peripheralServicesUpdated(_ inPeripheral: ITCB_SDK_Device_Peripheral) {
        _sendDeviceDiscoveredMessageToAllObservers(device: inPeripheral)
    }
}

/* ###################################################################################################################################### */
// MARK: - CBCentralManagerDelegate Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Central: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     This is called as the state changes for the Central manager object.
     
     - parameter inCentralManager: The Central Manager instance that changed state.
     */
    public func centralManagerDidUpdateState(_ inCentralManager: CBCentralManager) {
        assert(inCentralManager === managerInstance)   // Make sure that we are who we say we are...
        // Once we are powered on, we can start scanning.
        if .poweredOn == inCentralManager.state {
            inCentralManager.scanForPeripherals(withServices: [_static_ITCB_SDK_8BallServiceUUID], options: [:])
        }
    }
    
    /* ################################################################## */
    /**
     This is called as the state changes for the Central manager object.
     
     - parameters:
        - inCentralManager: The Central Manager instance that changed state.
        - didDiscover: This is the Core Bluetooth Peripheral instance that was discovered.
        - advertisementData: This is the adverstiement data that was sent by the discovered Peripheral.
        - rssi: This is the signal strength of the discovered Peripheral.
     */
    public func centralManager(_ inCentralManager: CBCentralManager, didDiscover inPeripheral: CBPeripheral, advertisementData inAdvertisementData: [String : Any], rssi inRSSI: NSNumber) {
        assert(inCentralManager === managerInstance)    // Make sure that we are who we say we are...
        if  !devices.containsThisDevice(inPeripheral),  // Make sure that we don't already have this peripheral.
            let peripheralName = inPeripheral.name,     // And that it is a legit Peripheral (has a name).
            !peripheralName.isEmpty {
            devices.append(ITCB_SDK_Device_Peripheral(inPeripheral, owner: self))
            inCentralManager.connect(inPeripheral, options: nil)    // We initiate a connection, which starts the voyage of discovery.
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a peripheral was connected.
     
     Once the device is connected, we can start discovering services.
     
     - parameters:
        - inCentralManager: The Central Manager instance that changed state.
        - didConnect: This is the Core Bluetooth Peripheral instance that was discovered.
     */
    public func centralManager(_ inCentralManager: CBCentralManager, didConnect inPeripheral: CBPeripheral) {
        inPeripheral.discoverServices([_static_ITCB_SDK_8BallServiceUUID])
    }
}


/* ###################################################################################################################################### */
// MARK: - ITCB_SDK_Device_PeripheralDelegate Protocol (How we talk to the Central) -
/* ###################################################################################################################################### */
/**
 This protocol outlines the rules for talking back to the Central Manager that "owns" a Peripheral.
 */
internal protocol ITCB_SDK_Device_PeripheralDelegate {
    /* ################################################################## */
    /**
     This sends a "Peripheral Services Changed" message to the SDK.
     
     - parameter inPeripheral: The Peripheral instance that has a modified Service.
     */
    func peripheralServicesUpdated(_ inPeripheral: ITCB_SDK_Device_Peripheral)
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
    
    /// We use this to maintain strong references to discovered Characteristics.
    internal var _characteristicInstances: [CBCharacteristic] = []

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
    
    /// We override the uuid property in order to get the UUID from the peripheral.
    internal override var uuid: String? {
        get {
            if nil == super.uuid || (super.uuid?.isEmpty ?? false) {
                super.uuid = peripheralDeviceInstance?.identifier.uuidString
            }
            
            return super.uuid
        }
        
        set {
            super.uuid = newValue
        }
    }
    
    /// We override the name property in order to get the local name from the peripheral.
    internal override var name: String {
        get {
            if super.name.isEmpty {
                super.name = peripheralDeviceInstance?.name ?? ""
            }
            
            return super.name
        }
        
        set {
            super.name = newValue
        }
    }

    /* ################################################################## */
    /**
     This should be called AFTER successfully sending the message.

     - parameter inQuestion: The question to be asked.
     */
    public func sendQuestion(_ inQuestion: String) {
        self.question = inQuestion
    }
    
    /* ################################################################## */
    /**
     Standard init.
     
     - parameter inCBPeripheral: The Core Bluetooth discovered Peripheral instance that will be associated with this instance.
     - parameter owner: The Central instance that "owns" this Peripheral.
     */
    init(_ inCBPeripheral: CBPeripheral, owner inOwner: ITCB_SDK_Central) {
        super.init()
        inCBPeripheral.delegate = self
        owner = inOwner
        _peerInstance = inCBPeripheral
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralDelegate Conformance -
/* ###################################################################################################################################### */
extension ITCB_SDK_Device_Peripheral: CBPeripheralDelegate {
    /* ################################################################## */
    /**
     Called after the Peripheral has discovered Services.
     
     - parameter inPeripheral: The Peripheral object that discovered (and now contains) the Services.
     - parameter didDiscoverServices: Any errors that may have occurred. It may be nil.
     */
    public func peripheral(_ inPeripheral: CBPeripheral, didDiscoverServices inError: Error?) {
        // After discovering the Service, we ask it (even though we are using an Array visitor) to discover its three Characteristics.
        inPeripheral.services?.forEach {
            // Having all 3 Characteristic UUIDs in this call, means that we should get one callback, with all 3 Characteristics set at once.
            inPeripheral.discoverCharacteristics([_static_ITCB_SDK_8BallService_Question_UUID,
                                                  _static_ITCB_SDK_8BallService_Answer_UUID,
                                                  _static_ITCB_SDK_8BallService_Condition_UUID], for: $0)
        }
    }
    
    /* ################################################################## */
    /**
     Called after the Peripheral has discovered Services.
     
     - parameter inPeripheral: The Peripheral object that discovered (and now contains) the Services.
     - parameter didDiscoverCharacteristicsFor: The Service that had the Characteristics discovered.
     - parameter error: Any errors that may have occurred. It may be nil.
     */
    public func peripheral(_ inPeripheral: CBPeripheral, didDiscoverCharacteristicsFor inService: CBService, error inError: Error?) {
        if _characteristicInstances.isEmpty {   // Make sure that we didn't already pick up the Characteristics (This can be called multiple times).
            _characteristicInstances = inService.characteristics ?? []
            owner.peripheralServicesUpdated(self)
        }
    }
    
    /* ################################################################## */
    /**
     This is a required/not required conformance. Even though it isn't "required," per se...it's required.
     
     - parameter inPeripheral: The Peripheral object that has the invalidated Services.
     - parameter didModifyServices: The Services that were invalidated.
     */
    public func peripheral(_ inPeripheral: CBPeripheral, didModifyServices inInvalidatedServices: [CBService]) {
    }
}
