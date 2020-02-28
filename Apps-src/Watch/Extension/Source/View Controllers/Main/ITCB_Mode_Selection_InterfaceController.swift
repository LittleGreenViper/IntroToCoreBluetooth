//
//  InterfaceController.swift
//  Watch WatchKit Extension
//
//  Created by Chris Marshall on 2/11/20.
//  Copyright © 2020 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation

/* ###################################################################################################################################### */
// MARK: - The Main Mode Selection Controller -
/* ###################################################################################################################################### */
/**
 This handles the initial mode selection screen.
 
 This screen shows two icons. The left one will run the extension as a Central, and the right one, as a Peripheral.
 */
class ITCB_Mode_Selection_InterfaceController: ITCB_Watch_Base_InterfaceController {
    /* ################################################################## */
    /**
     Called when the screen has loaded, and will start running.
     
     - parameter withContext: The extension context arguments.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        deviceSDKInstance = nil // This screen should always feature a nil device SDK. The user will select which one to create.
    }
    
    /* ################################################################## */
    /**
     Called when the screen appears.
     
     We use this to wipe the device SDK clean every time.
     */
    override func didAppear() {
        super.didAppear()
        deviceSDKInstance = nil // Whenever this screen appears, we wipe out the SDK instance.
    }
}
