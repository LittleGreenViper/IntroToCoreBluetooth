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
     This is here to satisfy the SDK Peripheral Observer requirement.
     */
    var uuid: UUID = UUID()

    /* ################################################################## */
    /**
     Assuming that a question was asked, this will contain it.
     */
    var questionThatWasAsked: String!
    
    /* ################################################################## */
    /**
     The main label, at the top.
     */
    @IBOutlet weak var mainLabel: WKInterfaceLabel!

    /* ################################################################## */
    /**
     The label displaying the received question.
     */
    @IBOutlet weak var questionAskedLabel: WKInterfaceLabel!
    
    /* ################################################################## */
    /**
     This button sends a randomly-selected answer out.
     */
    @IBOutlet weak var sendRandomAnswerButton: WKInterfaceButton!
    
    /* ################################################################## */
    /**
     Called when the random answer button is hit.
     */
    @IBAction func sendRandomAnswerButtonHit() {
        sendAnswer(String(format: "SLUG-ANSWER-%02d", Int.random(in: 0..<(Int("SLUG-NUMBER-MAX".localizedVariant) ?? 0))).localizedVariant)
    }
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
            ITCB_ExtensionDelegate.extensionDelegate?.deviceSDKInstance = ITCB_SDK.createInstance(isCentral: false)
        }
        
        setUpUI()
        questionThatWasAsked = nil
        uuid = deviceSDKInstance.addObserver(self)
    }
    
    /* ################################################################## */
    /**
     We remove ourselves as an observer.
     */
    override func willDisappear() {
        super.willDisappear()
        deviceSDKInstance?.removeObserver(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Main_Peripheral_InterfaceController {
    /* ################################################################## */
    /**
     This sends the answer, getting the question from our question label.
     
     - parameter inAnswer: The answer to be sent to the Central.
     */
    func sendAnswer(_ inAnswer: String) {
        if  let sdk = deviceSDKInstance as? ITCB_SDK_Peripheral,
            let question = questionThatWasAsked,
            !question.isEmpty {
            sdk.central.sendAnswer(inAnswer, toQuestion: question)
        }
    }

    /* ################################################################## */
    /**
     Set Up any UI elements as necessary.
     */
    func setUpUI() {
        DispatchQueue.main.async {
            self.mainLabel.setText("SLUG-PERIPHERAL".localizedVariant)
            self.sendRandomAnswerButton.setTitle("SLUG-SEND-RANDOM-ANSWER-WATCH".localizedVariant)
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods
/* ################################################################################################################################## */
extension ITCB_Main_Peripheral_InterfaceController: ITCB_Observer_Peripheral_Protocol {
    /* ################################################################## */
    /**
     This is called when a Central asks a Peripheral a question.
     
     This may not be called in the main thread.

     - parameter inDevice: The Central device that provided the question.
     - parameter question: The question that was asked by the Central.
     */
    func questionAskedByDevice(_ inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
        if  nil == questionThatWasAsked,
            let sdk = deviceSDKInstance as? ITCB_SDK_Peripheral,
            sdk.central.amIThisDevice(inDevice) {
            questionThatWasAsked = inQuestion
            DispatchQueue.main.async {
                self.questionAskedLabel?.setText(inQuestion.localizedVariant)
            }
        } else if nil != questionThatWasAsked { // If we are busy with a previous question, we reject the connection.
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
        questionThatWasAsked = nil
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
