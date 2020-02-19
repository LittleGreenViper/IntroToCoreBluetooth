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
// MARK: - Initial Tests of the SDK Mocks -
/* ###################################################################################################################################### */
/**
 These are some simple "initial" tests of the SDK mock classes. These are "sanity checks," and not much more.
 */
extension ITCB_SDK_Tests {
    /* ################################################################## */
    /**
     Test to make sure that we instantiate the correct types and in the right places. Not much more. This is really just a structural verification of the mocks.
     */
    func testSimpleInstantiations() {
        XCTAssertNotNil(testCentral)
        XCTAssertEqual(Self.numberOfPeripherals, testPeripherals.count)
        XCTAssertEqual(testCentral.devices.count, testPeripherals.count)
        var index = 0
        for device in testCentral.devices {
            if let device = device as? ITCB_SDK_Device_Peripheral_Mock {
                if let owner = device.owner as? ITCB_SDK_Central_Mock {
                    XCTAssertEqual(owner.uuid, testCentral.uuid)
                } else {
                    XCTFail("Wrong kind of owner!")
                }
                
                XCTAssertEqual(device.mockPeripheralSDKInstance.uuid, testPeripherals[index].uuid)
                XCTAssertEqual(device.uuid, testPeripherals[index].mockPeripheralDeviceInstance.uuid)
                index += 1
            } else {
                XCTFail("Wrong kind of device!")
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is a "no-brainer" test to make sure that we can call the send question/answer method of the Central to each of its devices.
     This won't really mean much, until we add observers. This is really just a structural verification of the mocks.
     */
    func testSendQuestionsAndAnswers() {
        var index = 0
        for dev in testCentral.devices {
            if let device = dev as? ITCB_SDK_Device_Peripheral_Mock {
                let question = questionList[Int.random(in: 0..<questionList.count)]
                let answer = answerList[Int.random(in: 0..<answerList.count)]
                device.sendQuestion(question)
                XCTAssertEqual(question, device.question)
                testCentral.mockCentralDeviceInstance.sendAnswer(answer, toQuestion: question, viaDevice: device)
                let testAnswer = device.answer
                XCTAssertEqual(answer, testAnswer)
                index += 1
            } else {
                XCTFail("Wrong kind of device!")
            }
        }
    }
}
