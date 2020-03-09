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

import Cocoa
import ITCB_SDK_Mac

/* ###################################################################################################################################### */
// MARK: - The View Controller for a Peripheral Mode app -
/* ###################################################################################################################################### */
/**
 This view controller is loaded over the mode selection, as we have decided to be a Peripheral.
 */
class ITCB_PERIPHERAL_Initial_ViewController: ITCB_Base_ViewController {
    /// The stroryboard ID, for instantiating the class.
    static let storyboardID = "peripheral-initial-view-controller"
    
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
     This is the Central Device name label
     */
    @IBOutlet weak var deviceNameLabel: NSTextField!
    
    /* ################################################################## */
    /**
     This displays the question from the Central.
     */
    @IBOutlet weak var questionAskedLabel: NSTextField!
    
    /* ################################################################## */
    /**
     If the user hits this button, a random answer will be selected and sent.
     */
    @IBOutlet weak var sendRandomButton: NSButton!
    
    /* ################################################################## */
    /**
     The question picker table view.
     */
    @IBOutlet var tableView: NSTableView!
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension ITCB_PERIPHERAL_Initial_ViewController {
    /* ################################################################## */
    /**
     Called when the user clicks the "Send Random" button.
     
     - parameter inButton: The button instance.
     */
    @IBAction func sendRandomButtonHit(_ inButton: NSButton) {
        let answer = String(format: "SLUG-ANSWER-%02d", Int.random(in: 0..<20)).localizedVariant
        getDeviceSDKInstanceAsPeripheral?.central.sendAnswer(answer, toQuestion: questionAskedLabel?.stringValue ?? "ERROR")
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_PERIPHERAL_Initial_ViewController {
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceSDKInstance = ITCB_SDK.createInstance(isCentral: false)
        sendRandomButton?.title = sendRandomButton?.title.localizedVariant ?? "ERROR"
        deviceNameLabel?.stringValue = getDeviceSDKInstanceAsPeripheral?.central?.name ?? "ERROR"
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use this to register as an observer.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        getDeviceSDKInstanceAsPeripheral?.addObserver(self)
    }

    /* ################################################################## */
    /**
     Called just before the view disappears. We use this to un-register as an observer.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        getDeviceSDKInstanceAsPeripheral?.removeObserver(self)
    }
}

/* ################################################################################################################################## */
// MARK: - NSTableViewDelegate/DataSource Methods
/* ################################################################################################################################## */
extension ITCB_PERIPHERAL_Initial_ViewController: NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     Called to supply the number of rows in the table.
     
     - parameters:
        - inTableView: The table instance.
     
     - returns: A 1-based Int, with 0 being no rows.
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return Int("SLUG-NUMBER-MAX".localizedVariant) ?? 0
    }

    /* ################################################################## */
    /**
     This is called to supply the string display for one row that corresponds to a device.
     
     - parameters:
        - inTableView: The table instance.
        - objectValueFor: Container object for the column that holds the row.
        - row: 0-based Int, with the index of the row, within the column.
     
     - returns: A String, with the device name.
     */
    func tableView(_ inTableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row inRow: Int) -> Any? {
        return String(format: "SLUG-ANSWER-%02d", inRow).localizedVariant
    }
    
    /* ################################################################## */
    /**
     Called after a table row was selected by the user.
     
     We open a modal sheet, with the device info.
     
     - parameter: Ignored
     */
    func tableViewSelectionDidChange(_: Notification) {
        // Make sure that we have a selected row, and that the selection is valid.
        if  let selectedRow = tableView?.selectedRow,
            (0..<tableView.numberOfRows).contains(selectedRow) {
            let answer = String(format: "SLUG-ANSWER-%02d", selectedRow).localizedVariant
            getDeviceSDKInstanceAsPeripheral?.central.sendAnswer(answer, toQuestion: questionAskedLabel?.stringValue ?? "ERROR")
            tableView.deselectRow(selectedRow)  // Make sure that we clean up after ourselves.
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods
/* ################################################################################################################################## */
extension ITCB_PERIPHERAL_Initial_ViewController: ITCB_Observer_Peripheral_Protocol {
    /* ################################################################## */
    /**
     This is called when a Central asks a Peripheral a question.
     
     This may not be called in the main thread.

     - parameter inDevice: The Central device that provided the question.
     - parameter question: The question that was asked by the Central.
     */
    func questionAskedByDevice(_ inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
        if  !workingWithQuestion,
            let sdk = getDeviceSDKInstanceAsPeripheral,
            sdk.central.amIThisDevice(inDevice) {
            workingWithQuestion = true
            DispatchQueue.main.async {
                self.questionAskedLabel?.stringValue = inQuestion.localizedVariant
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
        if  let sdk = getDeviceSDKInstanceAsPeripheral,
            sdk.central.amIThisDevice(inDevice) {
            workingWithQuestion = false
            // TODO: Remove this code, after we get the Bluetooth working.
            displayAlert(header: inToQuestion, message: inAnswer)
            // END TODO
        }
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
