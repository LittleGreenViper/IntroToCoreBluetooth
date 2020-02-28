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

import UIKit
import ITCB_SDK_IOS

/* ###################################################################################################################################### */
// MARK: - The Peripheral Mode Initial Screen -
/* ###################################################################################################################################### */
/**
 This is the base view controller for the Peripheral Mode.
 */
class ITCB_Peripheral_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     This is the reuse ID for the prototype cell we'll use in our table.
     */
    static let cellReuseID = "selected-answer-cell"
    
    /* ################################################################## */
    /**
     This is here to satisfy the SDK Peripheral Observer requirement.
     */
    var uuid: UUID = UUID()

    /* ################################################################## */
    /**
     This is a semaphore that prevents questions from "piling up." If a question has not yet been answered, this is true.
     */
    var workingWithQuestion: Bool = false
    
    /* ################################################################## */
    /**
     This is the label that displays the Central device name.
     */
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    /* ################################################################## */
    /**
     This label displays the question sent from the Central device.
     */
    @IBOutlet weak var questionAskedLabel: UILabel!
    
    /* ################################################################## */
    /**
     This button allows a randomly-selected answer to be returned.
     */
    @IBOutlet weak var sendRandomAnswerButton: UIButton!
    
    /* ################################################################## */
    /**
     This makes sure that we don't leave a dead link in the SDK observer pool.
     */
    deinit {
        deviceSDKInstance.removeObserver(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Peripheral_ViewController {
    /* ################################################################## */
    /**
     This sends the answer, getting the question from our question label.
     
     - parameter inAnswer: The answer to be sent to the Central.
     */
    func sendAnswer(_ inAnswer: String) {
        if  let sdk = getDeviceSDKInstanceAsPeripheral,
            let question = self.questionAskedLabel?.text,
            !question.isEmpty {
            sdk.central.sendAnswer(inAnswer, toQuestion: question)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension ITCB_Peripheral_ViewController {
    /* ################################################################## */
    /**
     Called when the random button is hit. It selects an aswer at random, and sends it.
     
     - parameter: ignored.
     */
    @IBAction func sendRandomAnswerButtonHit(_: Any) {
        sendAnswer(String(format: "SLUG-ANSWER-%02d", Int.random(in: 0..<(Int("SLUG-NUMBER-MAX".localizedVariant) ?? 0))).localizedVariant)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_Peripheral_ViewController {
    /* ################################################################## */
    /**
     Called after the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceSDKInstance = ITCB_SDK.createInstance(isCentral: false)
        if let sdk = getDeviceSDKInstanceAsPeripheral {
            deviceNameLabel?.text = sdk.central?.name
            uuid = sdk.addObserver(self)
        }
        
        sendRandomAnswerButton?.setTitle(sendRandomAnswerButton?.title(for: .normal)?.localizedVariant, for: .normal)
    }
}

/* ###################################################################################################################################### */
// MARK: - Table Delegate and Data Source Methods -
/* ###################################################################################################################################### */
extension ITCB_Peripheral_ViewController: UITableViewDelegate, UITableViewDataSource {
    /* ################################################################## */
    /**
     Called to supply the number of rows in the table.
     
     - parameters:
        - inTableView: The table instance.
        - numberOfRowsInSection: The 0-based index of the section we're checking.
     
     - returns: A 1-based Int, with 0 being no rows.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return Int("SLUG-NUMBER-MAX".localizedVariant) ?? 0
    }
    
    /* ################################################################## */
    /**
     Called to get the cell to display for a device.
     
     - parameter inTableView: The table view that is calling this.
     - parameter cellForRowAt: The index path to the cell we are getting.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if  let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self.cellReuseID) {
            tableCell.textLabel?.text = String(format: "SLUG-ANSWER-%02d", inIndexPath.row).localizedVariant
            return tableCell
        }
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     This is called when someone taps on a row.
     
     We bring in the inspector for that device, and deselect the row.
     
     - parameter inTableView: The table view that called this.
     - parameter willSelectRowAt: An IndexPath to the selected row.
     - returns: An IndexPath, if the row is to remain selected and highlighted. It is always false, and we immediately deselect the row, anyway.
     */
    func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? {
        if  (0..<inTableView.numberOfRows(inSection: 0)).contains(inIndexPath.row) {
            let answer = String(format: "SLUG-ANSWER-%02d", inIndexPath.row).localizedVariant
            sendAnswer(answer)
        }
        return nil
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods -
/* ################################################################################################################################## */
extension ITCB_Peripheral_ViewController: ITCB_Observer_Peripheral_Protocol {
    /* ################################################################## */
    /**
     This is called when a Central asks a Peripheral a question.
     
     This may not be called in the main thread.

     - parameter inDevice: The Central device that provided the question.
     - parameter question: The question that was asked by the Central.
     */
    func questionAskedByDevice(_ inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
        if !workingWithQuestion {
            workingWithQuestion = true
            DispatchQueue.main.async {
                self.questionAskedLabel?.text = inQuestion.localizedVariant
            }
        } else if workingWithQuestion { // If we are busy with a previous question, we reject the connection.
            inDevice.rejectConnectionBecause(.deviceBusy)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Peripheral successfully answers a Central's question.
     
     This may not be called in the main thread.
     
     - parameter inDevice: The Central device that provided the question.
     - parameter answer: The answer that was sent to the Central.
     - parameter toQuestion: The question that was asked by the Central.
     */
    func answerSentToDevice(_ inDevice: ITCB_Device_Central_Protocol, answer inAnswer: String, toQuestion inToQuestion: String) {
        workingWithQuestion = false
        // TODO: Remove this code, after we get the Bluetooth working.
        displayAlert(header: inToQuestion, message: inAnswer)
        // END TODO
    }

    /* ################################################################## */
    /**
     Called when an error condition is encountered by the SDK.
     
     - parameter inError: The error code that occurred.
     - parameter sdk: The SDK instance that experienced the error.
     */
    func errorOccurred(_ inError: ITCB_Errors, sdk inSDKInstance: ITCB_SDK_Protocol) {
        displayAlert(header: "SLUG-ERROR", message: inError.localizedDescription)
    }
}
