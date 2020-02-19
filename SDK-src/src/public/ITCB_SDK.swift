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

import Foundation   // Needed for the debug test.

/* ###################################################################################################################################### */
// MARK: - Main SDK Interface Base Class -
/* ###################################################################################################################################### */
/**
 This is the implementation of the ITCB protocol contract. The base doesn't need to be bound to a protocol, as the specializations will be.
 
 It is a Swift class, and this is the "base" class, meant to be specialized for Central and Peripheral variants.
 */
public class ITCB_SDK {
    /* ################################################################## */
    /**
     Factory function for instantiating Peripherals.
     
     - parameter isCentral: This is true, if we want a Central instance, or false, for a Peripheral.
     
     - returns: An instance of the SDK for use by the user.
     */
    public class func createInstance(isCentral inIsCentral: Bool) -> ITCB_SDK_Protocol? {
        return inIsCentral ? ITCB_SDK_Central.createInstance() : ITCB_SDK_Peripheral.createInstance()
    }

    /* ################################################################## */
    /**
      Any error condition associated with this instance. It may be nil.
     */
    public var error: ITCB_Errors? { _error }

    /* ################################################################## */
    /**
     This is true, if Core Bluetooth reports that the device Bluetooth interface is powered on and available for use.
     */
    public var isCoreBluetoothPoweredOn: Bool { _isCoreBluetoothPoweredOn }
    
    /* ################################################################## */
    /**
     This is an Array of observer objects associated with this SDK instance.
     */
    public var observers: [ITCB_Observer_Protocol] = []
    
    /* ################################################################## */
    /**
      This adds the given observer to the list of observers for this SDK object. If the observer is already registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to add.
     */
    @discardableResult
    public func addObserver(_ inObserver: ITCB_Observer_Protocol) -> UUID! { _addObserver(inObserver)}
    
    /* ################################################################## */
    /**
     This removes the given observer from the list of observers for this SDK object. If the observer is not registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to remove.
     */
    public func removeObserver(_ inObserver: ITCB_Observer_Protocol) { _removeObserver(inObserver) }
    
    /* ################################################################## */
    /**
     This checks the given observer, to see if it is currently observing this SDK instance.
     
     - parameter inObserver: The Observer Instance to check.
    
     - returns: True, if the observer is currently in the list of SDK observers.
     */
    public func isObserving(_ inObserver: ITCB_Observer_Protocol) -> Bool { _isObserving(inObserver) }
}

/* ###################################################################################################################################### */
// MARK: - Main SDK Central Variant Interface Class -
/* ###################################################################################################################################### */
/**
 This is the Central specialization of the main SDK interface.
 */
public class ITCB_SDK_Central: ITCB_SDK, ITCB_SDK_Central_Protocol {
    /* ################################################################## */
    /**
     Factory function for instantiating Centrals.
     
     This is internal, but needs to be declared here. Awkward, I know.

     - returns: A new instance of a Central SDK.
     */
    public class func createInstance() -> ITCB_SDK_Protocol? { ITCB_SDK_Central() }

    /* ################################################################## */
    /**
     This is the list of discovered Peripheral devices.
     */
    public var devices: [ITCB_Device_Peripheral_Protocol] = []
}

/* ###################################################################################################################################### */
// MARK: - Main SDK Peripheral Variant Interface Class -
/* ###################################################################################################################################### */
/**
 This is the Peripheral specialization of the main SDK interface.
 */
public class ITCB_SDK_Peripheral: ITCB_SDK, ITCB_SDK_Peripheral_Protocol {
    /* ################################################################## */
    /**
     Factory function for instantiating Peripherals.
     
     This is internal, but needs to be declared here. Awkward, I know.

     - returns: A new instance of a Peripheral SDK.
     */
    public class func createInstance() -> ITCB_SDK_Protocol? { ITCB_SDK_Peripheral() }
}
