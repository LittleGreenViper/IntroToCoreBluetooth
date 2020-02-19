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

/* ###################################################################################################################################### */
// MARK: - Main SDK Interface Base Class -
/* ###################################################################################################################################### */
/**
 This is an internal-scope extension of the public SDK class, containing the actual implementations that fulfill the protocol contract.
 
 Internal-scope methods and properties are indicated by a leading underscore (_) in the name.
 */
internal extension ITCB_SDK {
    /* ################################################################## */
    /**
      Any error condition associated with this instance. It may be nil.
     */
    var _error: ITCB_Errors? { nil }

    /* ################################################################## */
    /**
     This is true, if Core Bluetooth reports that the device Bluetooth interface is powered on and available for use.
     */
    var _isCoreBluetoothPoweredOn: Bool { false }
    
    /* ################################################################## */
    /**
      This adds the given observer to the list of observers for this SDK object. If the observer is already registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to add.
     - returns: The newly-assigned UUID. Nil, if the observer was not added.
     */
    func _addObserver(_ inObserver: ITCB_Observer_Protocol) -> UUID! {
        if !isObserving(inObserver) {
            observers.append(inObserver)
            observers[observers.count - 1].uuid = UUID()    // This assigns a concrete UUID for use in comparing for removal and testing.
            return observers[observers.count - 1].uuid
        }
        return nil
    }
    
    /* ################################################################## */
    /**
     This removes the given observer from the list of observers for this SDK object. If the observer is not registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to remove.
     */
    func _removeObserver(_ inObserver: ITCB_Observer_Protocol) {
        // There's a number of ways to do this. This way works fine.
        for index in 0..<observers.count where inObserver.uuid == observers[index].uuid {
            observers.remove(at: index)
            return
        }
    }
    
    /* ################################################################## */
    /**
     This checks the given observer, to see if it is currently observing this SDK instance.
     
     - parameter inObserver: The Observer Instance to check.
    
     - returns: True, if the observer is currently in the list of SDK observers.
     */
    func _isObserving(_ inObserver: ITCB_Observer_Protocol) -> Bool {
        for observer in observers where inObserver.uuid == observer.uuid {
            return true
        }
        
        return false
    }
}

/* ###################################################################################################################################### */
// MARK: - Main SDK Central Variant Interface Class -
/* ###################################################################################################################################### */
/**
 These are the observer notification message senders.
 */
internal extension ITCB_SDK_Central {
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
// MARK: - Main SDK Peripheral Variant Interface Class -
/* ###################################################################################################################################### */
/**
 These are the observer notification message senders.
 */
internal extension ITCB_SDK_Peripheral {
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
// MARK: - General Device Base Class -
/* ###################################################################################################################################### */
/**
 */
internal class ITCB_SDK_Device {
    /// The name property to conform to the protocol.
    var name: String = ""
    
    /// The error property to conform to the protocol.
    var error: ITCB_Errors!
}

/* ###################################################################################################################################### */
// MARK: - Central Device Base Class -
/* ###################################################################################################################################### */
/**
 */
internal class ITCB_SDK_Device_Central: ITCB_SDK_Device, ITCB_Device_Central_Protocol {
    /// This is the Peripheral SDK that "owns" this device.
    var owner: ITCB_SDK_Peripheral!
    
    /* ################################################################## */
    /**
     In the base class, all we do is send the "success" message to any observers.
     
     This should be called AFTER successfully sending the message.

     - parameter inAnswer: The answer.
     - parameter toQuestion: The question that was be asked.
     */
    func sendAnswer(_ inAnswer: String, toQuestion inToQuestion: String) {
        owner._sendSuccessInSendingAnswerToAllObservers(device: self, answer: inAnswer, toQuestion: inToQuestion)
    }
}

/* ###################################################################################################################################### */
// MARK: - Peripheral Device Base Class -
/* ###################################################################################################################################### */
/**
 */
internal class ITCB_SDK_Device_Peripheral: ITCB_SDK_Device, ITCB_Device_Peripheral_Protocol {
    /// This is the Central SDK that "owns" this device.
    var owner: ITCB_SDK_Central!

    /// The question property to conform to the protocol.
    var question: String! = nil

    /// The answer property to conform to the protocol.
    /// We use this opportunity to let everyone know that the question has been answered.
    var answer: String! = nil {
        didSet {
            owner._sendQuestionAnsweredMessageToAllObservers(device: self)
        }
    }
    
    /* ################################################################## */
    /**
     In the base class, all we do is send the "success" message to any observers.
     
     This should be called AFTER successfully sending the message.

     - parameter inQuestion: The question to be asked.
     */
    func sendQuestion(_ inQuestion: String) {
        owner._sendSuccessInAskingMessageToAllObservers(device: self)
    }
}
