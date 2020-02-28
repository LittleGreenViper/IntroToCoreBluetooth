//
//  InterfaceController.swift
//  Watch WatchKit Extension
//
//  Created by Chris Marshall on 2/11/20.
//  Copyright © 2020 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation
import ITCB_SDK_Watch

/* ###################################################################################################################################### */
// MARK: - The Controller For A Single Device Row
/* ###################################################################################################################################### */
/**
 This describes one row of the table that displays devices.
 */
class ITCB_Main_Central_InterfaceController_TableRowController: NSObject {
    /* ################################################################## */
    /**
     The only item is a device name label.
     */
    @IBOutlet weak var displayLabel: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - The main Central controller -
/* ###################################################################################################################################### */
/**
 This handles the Central screen, where the user can select from a list of devices.
 */
class ITCB_Main_Central_InterfaceController: ITCB_Watch_Base_InterfaceController {
    /* ################################################################## */
    /**
     The string used to instantiate our table rows.
     */
    let rowIDString = "ITCB_Main_Central_InterfaceController_TableRowController"
    
    /* ################################################################## */
    /**
     The main label, at the top.
     */
    @IBOutlet weak var mainLabel: WKInterfaceLabel!
    
    /* ################################################################## */
    /**
     The table that displays the list of discovered devices.
     */
    @IBOutlet weak var deviceDisplayTable: WKInterfaceTable!
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension ITCB_Main_Central_InterfaceController {
    /* ################################################################## */
    /**
     Called when the screen has loaded, and will start running.
     
     - parameter withContext: The extension context arguments.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        setUpUI()
    }
    
    /* ################################################################## */
    /**
     Called just before we are displayed.
     
     We use this to update the UI, and reset things, if we need to do so (after settings).
     If the device has not been created yet, we do so.
     */
    override func willActivate() {
        super.willActivate()
        
        if nil == ITCB_ExtensionDelegate.extensionDelegate?.deviceSDKInstance {
            ITCB_ExtensionDelegate.extensionDelegate?.deviceSDKInstance = ITCB_SDK.createInstance(isCentral: true)
        }

        setUpUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Main_Central_InterfaceController {
    /* ################################################################## */
    /**
     Set Up any UI elements as necessary.
     */
    func setUpUI() {
        DispatchQueue.main.async {
            self.mainLabel.setText("SLUG-CENTRAL".localizedVariant)
            self.populateTable()
        }
    }

    /* ################################################################## */
    /**
     This adds devices to the table for display.
     */
    func populateTable() {
        if  let deviceSDKInstance = deviceSDKInstance as? ITCB_SDK_Central,
            0 < deviceSDKInstance.devices.count {
            let numberOfDevices = deviceSDKInstance.devices.count
            
            deviceDisplayTable.setNumberOfRows(numberOfDevices, withRowType: rowIDString)
            
            let rowControllerKludgeArray = [String](repeatElement("ITCB_Main_Central_InterfaceController_TableRowController", count: numberOfDevices))
            
            deviceDisplayTable.setRowTypes(rowControllerKludgeArray)
            
            for index in 0..<numberOfDevices {
                if  let deviceRowRaw = deviceDisplayTable.rowController(at: index),
                    let deviceRow = deviceRowRaw as? ITCB_Main_Central_InterfaceController_TableRowController {
                    let driverInst = deviceSDKInstance.devices[index]
                    deviceRow.displayLabel.setText(driverInst.name)
                }
            }
        } else {
            deviceDisplayTable.setNumberOfRows(0, withRowType: "")
        }
    }
}
