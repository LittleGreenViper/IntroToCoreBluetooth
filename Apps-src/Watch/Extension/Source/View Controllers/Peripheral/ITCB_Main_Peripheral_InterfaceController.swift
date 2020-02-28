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
// MARK: 
/* ###################################################################################################################################### */
/**
 This handles the peripheral screen, where the user gets a question, and can send back a random answer.
 */
class ITCB_Main_Peripheral_InterfaceController: ITCB_Watch_Base_InterfaceController {
    /* ################################################################## */
    /**
     The main label, at the top.
     */
    @IBOutlet weak var mainLabel: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension ITCB_Main_Peripheral_InterfaceController {
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
extension ITCB_Main_Peripheral_InterfaceController {
    /* ################################################################## */
    /**
     Set Up any UI elements as necessary.
     */
    func setUpUI() {
        DispatchQueue.main.async {
            self.mainLabel.setText("SLUG-PERIPHERAL".localizedVariant)
        }
    }
}
