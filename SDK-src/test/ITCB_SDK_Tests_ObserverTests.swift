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
// MARK: - Observer Tests of the SDK Mocks -
/* ###################################################################################################################################### */
/**
 These are some tests of the SDK that check the observers.
 */
extension ITCB_SDK_Tests {
    /* ################################################################## */
    /**
     This tests the observer callbacks for a simple "send question" operation, using a struct observer.
     */
    func testSimpleCentralSendQuestionObserverStructs() {
        let question = questionList[Int.random(in: 0..<questionList.count)]
        let testExpectation = XCTestExpectation()
        testExpectation.expectedFulfillmentCount = 2 * testPeripherals.count
        
        var testCentralObserver = ITCB_Test_Central_Observer(uuid: UUID(), fulfillThisExpectation: testExpectation, questionToCompare: nil, answerToCompare: nil)
        var testPeripheralObserver = ITCB_Test_Peripheral_Observer(uuid: UUID(), fulfillThisExpectation: testExpectation, questionToCompare: nil, answerToCompare: nil)

        for index in 0..<testPeripherals.count {
            let deviceFromCentral = testCentral.devices[index]
            let peripheralSDKInstance = testPeripherals[index]
            
            testCentralObserver.questionToCompare = question
            testPeripheralObserver.questionToCompare = question
            
            XCTAssertEqual(0, testCentral.observers.count)
            // Since the observer is a struct, we need to explicitly assign the new UUID.
            testCentralObserver.uuid = testCentral.addObserver(testCentralObserver)
            XCTAssertEqual(1, testCentral.observers.count)

            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            // Since the observer is a struct, we need to explicitly assign the new UUID.
            testPeripheralObserver.uuid = peripheralSDKInstance.addObserver(testPeripheralObserver)
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)

            deviceFromCentral.sendQuestion(question)
            
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)
            peripheralSDKInstance.removeObserver(testPeripheralObserver)
            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            
            XCTAssertEqual(1, testCentral.observers.count)
            testCentral.removeObserver(testCentralObserver)
            XCTAssertEqual(0, testCentral.observers.count)
        }
        
        wait(for: [testExpectation], timeout: 0.25)
    }
    
    /* ################################################################## */
    /**
     This tests the observer callbacks for a simple "send question" operation, using a class observer.
     */
    func testSimpleCentralSendQuestionObserverClasses() {
        let question = questionList[Int.random(in: 0..<questionList.count)]
        let testExpectation = XCTestExpectation()
        testExpectation.expectedFulfillmentCount = 2 * testPeripherals.count
        
        let testCentralObserver = ITCB_Test_Central_Observer_Class()
        testCentralObserver.fulfillThisExpectation = testExpectation
        let testPeripheralObserver = ITCB_Test_Peripheral_Observer_Class()
        testPeripheralObserver.fulfillThisExpectation = testExpectation

        for index in 0..<testPeripherals.count {
            let deviceFromCentral = testCentral.devices[index]
            let peripheralSDKInstance = testPeripherals[index]
            
            testCentralObserver.questionToCompare = question
            testPeripheralObserver.questionToCompare = question
            
            XCTAssertEqual(0, testCentral.observers.count)
            testCentral.addObserver(testCentralObserver)
            XCTAssertEqual(1, testCentral.observers.count)

            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            peripheralSDKInstance.addObserver(testPeripheralObserver)
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)

            deviceFromCentral.sendQuestion(question)
            
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)
            peripheralSDKInstance.removeObserver(testPeripheralObserver)
            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            
            XCTAssertEqual(1, testCentral.observers.count)
            testCentral.removeObserver(testCentralObserver)
            XCTAssertEqual(0, testCentral.observers.count)
        }
        
        wait(for: [testExpectation], timeout: 0.25)
    }
    
    /* ################################################################## */
    /**
     This tests the observer callbacks for a question and answer sequence, using structs.
     */
    func testSendQuestionAndGetAnswerObserverStructs() {
        let testExpectation = XCTestExpectation()
        testExpectation.expectedFulfillmentCount = 4 * testPeripherals.count
        
        var testCentralObserver = ITCB_Test_Central_Observer(uuid: UUID(), fulfillThisExpectation: testExpectation, questionToCompare: nil, answerToCompare: nil)
        var testPeripheralObserver = ITCB_Test_Peripheral_Observer(uuid: UUID(), fulfillThisExpectation: testExpectation, questionToCompare: nil, answerToCompare: nil, peripheralDeviceObject: nil)

        for index in 0..<testPeripherals.count {
            let question = questionList[Int.random(in: 0..<questionList.count)]
            let answer = answerList[Int.random(in: 0..<answerList.count)]
            let deviceFromCentral = testCentral.devices[index]
            let peripheralSDKInstance = testPeripherals[index]
            
            testCentralObserver.questionToCompare = question
            testPeripheralObserver.questionToCompare = question
            testPeripheralObserver.peripheralDeviceObject = peripheralSDKInstance.mockPeripheralDeviceInstance
            testCentralObserver.answerToCompare = answer
            // By setting this in the Peripheral observer, we tell it to answer a question.
            testPeripheralObserver.answerToCompare = answer

            XCTAssertEqual(0, testCentral.observers.count)
            // Since the observer is a struct, we need to explicitly assign the new UUID.
            testCentralObserver.uuid = testCentral.addObserver(testCentralObserver)
            XCTAssertEqual(1, testCentral.observers.count)

            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            // Since the observer is a struct, we need to explicitly assign the new UUID.
            testPeripheralObserver.uuid = peripheralSDKInstance.addObserver(testPeripheralObserver)
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)

            deviceFromCentral.sendQuestion(question)
            
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)
            peripheralSDKInstance.removeObserver(testPeripheralObserver)
            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            
            XCTAssertEqual(1, testCentral.observers.count)
            testCentral.removeObserver(testCentralObserver)
            XCTAssertEqual(0, testCentral.observers.count)
        }
        
        wait(for: [testExpectation], timeout: 0.25)
    }
    
    /* ################################################################## */
    /**
     This tests the observer callbacks for a question and answer sequence, using classes.
     */
    func testSendQuestionAndGetAnswerObserverClasses() {
        let testExpectation = XCTestExpectation()
        testExpectation.expectedFulfillmentCount = 4 * testPeripherals.count
        
        let testCentralObserver = ITCB_Test_Central_Observer_Class()
        testCentralObserver.fulfillThisExpectation = testExpectation
        let testPeripheralObserver = ITCB_Test_Peripheral_Observer_Class()
        testPeripheralObserver.fulfillThisExpectation = testExpectation

        for index in 0..<testPeripherals.count {
            let question = questionList[Int.random(in: 0..<questionList.count)]
            let answer = answerList[Int.random(in: 0..<answerList.count)]
            let deviceFromCentral = testCentral.devices[index]
            let peripheralSDKInstance = testPeripherals[index]
            
            testCentralObserver.questionToCompare = question
            testPeripheralObserver.questionToCompare = question
            testPeripheralObserver.peripheralDeviceObject = peripheralSDKInstance.mockPeripheralDeviceInstance
            testCentralObserver.answerToCompare = answer
            // By setting this in the Peripheral observer, we tell it to answer a question.
            testPeripheralObserver.answerToCompare = answer

            XCTAssertEqual(0, testCentral.observers.count)
            testCentral.addObserver(testCentralObserver)
            XCTAssertEqual(1, testCentral.observers.count)

            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            peripheralSDKInstance.addObserver(testPeripheralObserver)
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)

            deviceFromCentral.sendQuestion(question)
            
            XCTAssertEqual(1, peripheralSDKInstance.observers.count)
            peripheralSDKInstance.removeObserver(testPeripheralObserver)
            XCTAssertEqual(0, peripheralSDKInstance.observers.count)
            
            XCTAssertEqual(1, testCentral.observers.count)
            testCentral.removeObserver(testCentralObserver)
            XCTAssertEqual(0, testCentral.observers.count)
        }
        
        wait(for: [testExpectation], timeout: 0.25)
    }
}
