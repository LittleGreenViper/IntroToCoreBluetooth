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
// MARK: - The Central Mode Initial Screen -
/* ###################################################################################################################################### */
/**
 This is the base view controller for the Central Mode.
 */
class ITCB_Central_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     The segue that will display the device detail screen.
     */
    static let deviceDetailSegueID = "show-device-detail"
    
    /* ################################################################## */
    /**
     The reuse ID for the cell prototype.
     */
    static let deviceReuseID = "basic-peripheral-device-cell"
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_Central_ViewController {
    /* ################################################################## */
    /**
     Called after the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceSDKInstance = ITCB_SDK.createInstance(isCentral: true)
    }
    
    /* ################################################################## */
    /**
     This is called just prior to diplaying the device screen. We use it to associate the device record with the screen.
     
     - parameter for: The segue that is being exercised.
     - parameter sender: The device to be associated with the device details screen.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inDevice: Any?) {
        if  let destination = inSegue.destination as? ITCB_Central_Device_ViewController,
            let device = inDevice as? ITCB_Device_Peripheral_Protocol {
            destination.device = device
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Table Delegate and Data Source Methods -
/* ###################################################################################################################################### */
extension ITCB_Central_ViewController: UITableViewDelegate, UITableViewDataSource {
    /* ################################################################## */
    /**
     Called to get the number of rows to display (number of devices).
     
     - parameter inTableView: The table view that is calling this.
     - parameter numberOfRowsInSection: The 0-base sectio index.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        if let sdk = deviceSDKInstance as? ITCB_SDK_Central_Protocol {
            return sdk.devices.count
        }
        return 0
    }
    
    /* ################################################################## */
    /**
     Called to get the cell to display for a device.
     
     - parameter inTableView: The table view that is calling this.
     - parameter cellForRowAt: The index path to the cell we are getting.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if  let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self.deviceReuseID),
            let sdk = deviceSDKInstance as? ITCB_SDK_Central_Protocol {
            let name = sdk.devices[inIndexPath.row].name
            tableCell.textLabel?.text = name
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
        if let sdk = deviceSDKInstance as? ITCB_SDK_Central_Protocol {
            let device = sdk.devices[inIndexPath.row]
            performSegue(withIdentifier: Self.deviceDetailSegueID, sender: device)
        }
        return nil
    }
}
