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

import XCTest

/* ###################################################################################################################################### */
// MARK: - Setup of the SDK Tests -
/* ###################################################################################################################################### */
/**
 This defines the test class, the instance properties, and the setup() method.
 */
class ITCB_SDK_Tests: XCTestCase {
    /* ################################################################## */
    // MARK: - An Observer Struct for Central SDK Instances -
    /* ################################################################## */
    struct ITCB_Test_Central_Observer: ITCB_Observer_Central_Protocol {
        /// This is a UUID that is used by the SDK to track the Observer.
        var uuid: UUID
        
        /// This is an expectation that will be marked as fulfilled by a callback.
        var fulfillThisExpectation: XCTestExpectation!
        
        /// This is any question that needs to be compared.
        var questionToCompare: String!
        
        /// This is any answer that needs to be compared.
        var answerToCompare: String!
        
        /* ############################################################## */
        /**
         */
        func errorOccurred(_ inError: ITCB_Errors, sdk inSDK: ITCB_SDK_Protocol) {
            XCTFail("ERROR: \(String(describing: inError)), for Central SDK: \(String(describing: inSDK)).")
        }

        /* ############################################################## */
        /**
         */
        func questionAnsweredByDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
            print("Central Device questionAnsweredByDevice Called with \"\(inDevice.question ?? "ERROR")\" as an answer to \"\(inDevice.answer ?? "ERROR")\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inDevice.question, questionToCompare)
            } else {
                XCTFail("No Question to Compare!")
            }
            
            if let answerToCompare = answerToCompare {
                XCTAssertEqual(inDevice.answer, answerToCompare)
            } else {
                XCTFail("No Answer to Compare!")
            }
        }
        
        /* ############################################################## */
        /**
         */
        func questionAskedOfDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
            print("Central Device questionAskedOfDevice Called with \"\(inDevice.question ?? "ERROR")\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inDevice.question, questionToCompare)
            } else {
                XCTFail("No Question to Compare!")
            }
        }
    }
    
    /* ################################################################## */
    // MARK: - An Observer Class for Central SDK Instances -
    /* ################################################################## */
    class ITCB_Test_Central_Observer_Class: ITCB_Observer_Central_Protocol {
        /// This is a UUID that is used by the SDK to track the Observer.
        var uuid: UUID = UUID()
        
        /// This is an expectation that will be marked as fulfilled by a callback.
        var fulfillThisExpectation: XCTestExpectation!
        
        /// This is any question that needs to be compared.
        var questionToCompare: String!
        
        /// This is any answer that needs to be compared.
        var answerToCompare: String!
        
        /* ############################################################## */
        /**
         */
        func errorOccurred(_ inError: ITCB_Errors, sdk inSDK: ITCB_SDK_Protocol) {
            XCTFail("ERROR: \(String(describing: inError)), for Central SDK: \(String(describing: inSDK)).")
        }

        /* ############################################################## */
        /**
         */
        func questionAnsweredByDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
            print("Central Device questionAnsweredByDevice Called with \"\(inDevice.question ?? "ERROR")\" as an answer to \"\(inDevice.answer ?? "ERROR")\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inDevice.question, questionToCompare)
            } else {
                XCTFail("No Question to Compare!")
            }
            
            if let answerToCompare = answerToCompare {
                XCTAssertEqual(inDevice.answer, answerToCompare)
            } else {
                XCTFail("No Answer to Compare!")
            }
        }
        
        /* ############################################################## */
        /**
         */
        func questionAskedOfDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
            print("Central Device questionAskedOfDevice Called with \"\(inDevice.question ?? "ERROR")\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inDevice.question, questionToCompare)
            } else {
                XCTFail("No Question to Compare!")
            }
        }
    }
    
    /* ################################################################## */
    // MARK: - An Observer Struct for Peripheral SDK Instances -
    /* ################################################################## */
    struct ITCB_Test_Peripheral_Observer: ITCB_Observer_Peripheral_Protocol {
        /// This is a UUID that is used by the SDK to track the Observer.
        var uuid: UUID
        
        /// This is an expectation that will be marked as fulfilled by a callback.
        var fulfillThisExpectation: XCTestExpectation!
        
        /// This is any question that needs to be compared.
        var questionToCompare: String!
        
        /// This is any answer that needs to be compared.
        var answerToCompare: String!

        /// This allows us to associate with a particular device.
        var peripheralDeviceObject: ITCB_SDK_Device_Peripheral_Mock!
        
        /* ############################################################## */
        /**
         */
        func errorOccurred(_ inError: ITCB_Errors, sdk inSDK: ITCB_SDK_Protocol) {
            XCTFail("ERROR: \(String(describing: inError)), for Central SDK: \(String(describing: inSDK)).")
        }

        /* ############################################################## */
        /**
         */
        func questionAskedByDevice(_ inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
            print("Peripheral Device questionAskedByDevice Called with \"\(inQuestion)\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inQuestion, questionToCompare)
                
                // If we were supplied with an answer, then we assume that the Peripheral is to respond with an answer.
                if  let device = inDevice as? ITCB_SDK_Device_Central_Mock,
                    let answerToCompare = answerToCompare, !answerToCompare.isEmpty {
                    device.sendAnswer(answerToCompare, toQuestion: inQuestion, viaDevice: peripheralDeviceObject)
                }
            } else {
                XCTFail("No Question to Compare!")
            }
        }
        
        /* ############################################################## */
        /**
         */
        func answerSentToDevice(_ inDevice: ITCB_Device_Central_Protocol, answer inAnswer: String, toQuestion inToQuestion: String) {
            print("Peripheral Device answerSentToDevice Called with \"\(inAnswer)\" as an answer to \"\(inToQuestion)\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inToQuestion, questionToCompare)
            } else {
                XCTFail("No Question to Compare!")
            }
            
            if let answerToCompare = answerToCompare {
                XCTAssertEqual(inAnswer, answerToCompare)
            } else {
                XCTFail("No Answer to Compare!")
            }
        }
    }

    /* ################################################################## */
    // MARK: - An Observer Class for Peripheral SDK Instances -
    /* ################################################################## */
    class ITCB_Test_Peripheral_Observer_Class: ITCB_Observer_Peripheral_Protocol {
        /// This is a UUID that is used by the SDK to track the Observer.
        var uuid: UUID = UUID()
        
        /// This is an expectation that will be marked as fulfilled by a callback.
        var fulfillThisExpectation: XCTestExpectation!
        
        /// This is any question that needs to be compared.
        var questionToCompare: String!
        
        /// This is any answer that needs to be compared.
        var answerToCompare: String!
        
        /// This allows us to associate with a particular device.
        var peripheralDeviceObject: ITCB_SDK_Device_Peripheral_Mock!
        
        /* ############################################################## */
        /**
         */
        func errorOccurred(_ inError: ITCB_Errors, sdk inSDK: ITCB_SDK_Protocol) {
            XCTFail("ERROR: \(String(describing: inError)), for Central SDK: \(String(describing: inSDK)).")
        }

        /* ############################################################## */
        /**
         */
        func questionAskedByDevice(_ inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
            print("Peripheral Device questionAskedByDevice Called with \"\(inQuestion)\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inQuestion, questionToCompare)
                
                // If we were supplied with an answer, then we assume that the Peripheral is to respond with an answer.
                if  let device = inDevice as? ITCB_SDK_Device_Central_Mock,
                    let answerToCompare = answerToCompare, !answerToCompare.isEmpty {
                    device.sendAnswer(answerToCompare, toQuestion: inQuestion, viaDevice: peripheralDeviceObject)
                }
            } else {
                XCTFail("No Question to Compare!")
            }
        }
        
        /* ############################################################## */
        /**
         */
        func answerSentToDevice(_ inDevice: ITCB_Device_Central_Protocol, answer inAnswer: String, toQuestion inToQuestion: String) {
            print("Peripheral Device answerSentToDevice Called with \"\(inAnswer)\" as an answer to \"\(inToQuestion)\"")
            if nil != fulfillThisExpectation {
                fulfillThisExpectation.fulfill()
            }
            
            if let questionToCompare = questionToCompare {
                XCTAssertEqual(inToQuestion, questionToCompare)
            } else {
                XCTFail("No Question to Compare!")
            }
            
            if let answerToCompare = answerToCompare {
                XCTAssertEqual(inAnswer, answerToCompare)
            } else {
                XCTFail("No Answer to Compare!")
            }
        }
    }

    /// This is how many "8-balls" we'll create.
    static let numberOfPeripherals = 5
    
    /// This will contain a set of "question" slugs for testing.
    var questionList = [String]()
    /// This will contain a set of "answer" slugs for testing.
    var answerList = [String]()
    /// This will be a mock Central object
    var testCentral: ITCB_SDK_Central_Mock!
    /// This will be a set of mock peripheral objects.
    var testPeripherals: [ITCB_SDK_Peripheral_Mock] = []

    /* ################################################################## */
    /**
     We use this method to establish a new, repeatable set of instances to be tested.
     
     What we do, is create Mock SDK instances, and tie them together to simulate a connection between a Central and a few Peripherals.
     
     We also fill a couple of Arrays with "slug" strings, for testing.
     */
    override func setUp() {
        questionList = []
        answerList = []
        
        // We fill the two String Arrays with simple linear progressions of "slug" values.
        for index in 0..<20 {
            questionList.append(String(format: "SLUG-QUESTION-%02d", index))
            answerList.append(String(format: "SLUG-ANSWER-%02d", index))
        }

        testCentral = nil
        if let tempCentral = ITCB_SDK_Central_Mock.createInstance() as? ITCB_SDK_Central_Mock {
            tempCentral.mockCentralDeviceInstance.name = "MOCK CENTRAL"
            testCentral = tempCentral
        }
        
        testPeripherals = []
        for i in 0..<Self.numberOfPeripherals {
            if let tempPeripheral = ITCB_SDK_Peripheral_Mock.createInstance() as? ITCB_SDK_Peripheral_Mock {
                tempPeripheral.central = testCentral.mockCentralDeviceInstance
                tempPeripheral.mockPeripheralDeviceInstance.owner = testCentral
                tempPeripheral.mockPeripheralDeviceInstance.mockPeripheralSDKInstance = tempPeripheral
                tempPeripheral.mockPeripheralDeviceInstance.name = String(format: "MOCK DEVICE #%d", i)
                testPeripherals.append(tempPeripheral)
            }
        }
        
        var tempPeripheralDeviceList: [ITCB_SDK_Device_Peripheral_Mock] = []
        
        for peripheral in testPeripherals {
            tempPeripheralDeviceList.append(peripheral.mockPeripheralDeviceInstance)
        }
        
        testCentral.devices = tempPeripheralDeviceList
    }
}
