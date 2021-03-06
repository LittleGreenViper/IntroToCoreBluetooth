//
//  ExtensionDelegate.swift
//  Watch WatchKit Extension
//
//  Created by Chris Marshall on 2/11/20.
//  Copyright © 2020 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import ITCB_SDK_Watch

/* ###################################################################################################################################### */
// MARK: 
/* ###################################################################################################################################### */
/**
 */
class ITCB_ExtensionDelegate: NSObject, WKExtensionDelegate {
    /* ################################################################## */
    /**
     This is a shortcut to get the extension delegate instance as an instance of this class.
     */
    class var extensionDelegate: Self! {
        return WKExtension.shared().delegate as? Self
    }
    
    /* ################################################################## */
    /**
     This will hold our loaded SDK.
     We have a didSet observer, so we will assign a name upon it being set.
     */
    var deviceSDKInstance: ITCB_SDK_Protocol! {
        didSet {
            if  nil != deviceSDKInstance {
                self.deviceSDKInstance.localName = WKInterfaceDevice.current().name
            }
        }
    }

    /* ################################################################## */
    /**
     The dispatcher for the various app extension states.
     
     - parameter inBackgroundTasks: The extension's current background tasks. We iterate this.
     */
    func handle(_ inBackgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in inBackgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
