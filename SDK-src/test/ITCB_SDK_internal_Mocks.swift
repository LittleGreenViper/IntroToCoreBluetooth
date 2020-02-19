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

import Foundation // For the UUID stuff.

/* ###################################################################################################################################### */
// MARK: - Central Mock Device Class -
/* ###################################################################################################################################### */
/**
 This is a special "mock" Central Device class that we use for XCTesting.
 This may look a bit wierd, but we need to remember that this class is instantiated and managed by a Peripheral SDK instance, and is a local model of a remote Central.
 */
internal class ITCB_SDK_Device_Central_Mock: ITCB_SDK_Device_Central {
    /* ################################################################## */
    /**
      This is a unique UUID that will allow us to identify this instance.
     */
    let uuid = UUID()
    
    /* ################################################################## */
    /**
     This sends a mock "answer," to an equally mock "question."
     
     - parameter inAnswer: The answer.
     - parameter toQuestion: The question that was asked.
     - parameter viaDevice: A Peripheral mock device to "send" the answer to.
     */
    func sendAnswer(_ inAnswer: String, toQuestion inToQuestion: String, viaDevice inViaDevice: ITCB_SDK_Device_Peripheral_Mock) {
        inViaDevice.answer = inAnswer
        owner = inViaDevice.mockPeripheralSDKInstance
        super.sendAnswer(inAnswer, toQuestion: inToQuestion)
    }
}

/* ###################################################################################################################################### */
// MARK: - Peripheral Mock Device Class -
/* ###################################################################################################################################### */
/**
 This is a special "mock" Peripheral Device class that we use for XCTesting.
 This may look a bit wierd, but we need to remember that this class is instantiated and managed by a Central SDK instance, and is a local model of a remote Peripheral.
 */
internal class ITCB_SDK_Device_Peripheral_Mock: ITCB_SDK_Device_Peripheral {
    /* ################################################################## */
    /**
      This is a unique UUID that will allow us to identify this instance.
     */
    let uuid = UUID()
    
    /// This is an SDK instance that we associate with this, because we are running a "direct" connection.
    var mockPeripheralSDKInstance: ITCB_SDK_Peripheral_Mock!
    
    /// We override this in order to send the "Question Asked" message to observers.
    override var question: String! {
        get {
            super.question
        }
        
        set {
            super.question = newValue
            if let owner = owner as? ITCB_SDK_Central_Mock {
                mockPeripheralSDKInstance._sendQuestionAskedToAllObservers(device: owner.mockCentralDeviceInstance, question: newValue)
            }
        }
    }

    /* ################################################################## */
    /**
     This sends a mock "question".
     
     - parameter inQuestion: The question to be asked.
     */
    override func sendQuestion(_ inQuestion: String) {
        question = inQuestion
        // We do this, to test non-main thread handling in the system.
        super.sendQuestion(inQuestion)
    }
    
    /* ################################################################## */
    /**
     This sends a mock "question," but also allows us to specify a temporary "owner" for the device.
     
     - parameter inQuestion: The question to be asked.
     - parameter fromCentral: This is a temporary setting for the "owner" property, to make sure the callbacks are done correctly.
     */
    func sendQuestion(_ inQuestion: String, fromCentral inFromCentral: ITCB_SDK_Central) {
        owner = inFromCentral
        sendQuestion(inQuestion)
        question = inQuestion
        owner = nil // Clean up after ourselves.
    }
}

/* ###################################################################################################################################### */
// MARK: - Central SDK Mock Class -
/* ###################################################################################################################################### */
/**
 This class will supply some "mock" behavior for the SDK, so we have some consistent testing material.
 */
internal class ITCB_SDK_Central_Mock: ITCB_SDK_Central {
    /* ################################################################## */
    /**
      This is a unique UUID that will allow us to identify this instance.
     */
    let uuid = UUID()
    
    /// This will be an instance of a mock Central device, associated with this. We will create it, so this is not a weak reference.
    let mockCentralDeviceInstance: ITCB_SDK_Device_Central_Mock

    /* ################################################################## */
    /**
     Factory function for instantiating Central Mocks.
     
     - returns: A new instance of a Central Mock SDK.
     */
    public override class func createInstance() -> ITCB_SDK_Protocol? { ITCB_SDK_Central_Mock() }
    
    /* ################################################################## */
    /**
     Default init.
     
     We create an instance of a Central device, here.
     */
    public override init() {
        mockCentralDeviceInstance = ITCB_SDK_Device_Central_Mock()
        super.init()
    }
}

/* ###################################################################################################################################### */
// MARK: - Peripheral SDK Mock Class -
/* ###################################################################################################################################### */
/**
This class will supply some "mock" behavior for the SDK, so we have some consistent testing material.
*/
internal class ITCB_SDK_Peripheral_Mock: ITCB_SDK_Peripheral {
    /* ################################################################## */
    /**
      This is a unique UUID that will allow us to identify this instance.
     */
    let uuid = UUID()
    
    /// We will use this to mock a Peripheral. We will create it, so this is not a weak reference.
    let mockPeripheralDeviceInstance: ITCB_SDK_Device_Peripheral_Mock

    /* ################################################################## */
    /**
     Factory function for instantiating Peripheral Mocks.
     
     - returns: A new instance of a Peripheral Mock SDK.
     */
    public override class func createInstance() -> ITCB_SDK_Protocol? { ITCB_SDK_Peripheral_Mock() }
    
    /* ################################################################## */
    /**
     Default init.
     
     We create an instance of a Peripheral device, here.
     */
    public override init() {
        mockPeripheralDeviceInstance = ITCB_SDK_Device_Peripheral_Mock()
        super.init()
    }
}
