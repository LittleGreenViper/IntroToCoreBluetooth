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
// MARK: 
/* ###################################################################################################################################### */
/**
 */
@NSApplicationMain
class ITCB_AppDelegate: NSObject, NSApplicationDelegate {
    /* ################################################################## */
    /**
     This is a shortcut to get the app delegate instance as an instance of this class.
     */
    class var appDelegate: Self! {
        return NSApplication.shared.delegate as? Self
    }
    
    /* ################################################################## */
    /**
     This displays a simple alert, with an OK button.
     
     - parameter header: The header to display at the top.
     - parameter message: A String, containing whatever messge is to be displayed below the header.
     */
    class func displayAlert(header inHeader: String, message inMessage: String = "") {
        // This ensures that we are on the main thread.
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = inHeader.localizedVariant
            alert.informativeText = inMessage.localizedVariant
            alert.addButton(withTitle: "SLUG-OK-BUTTON-TEXT".localizedVariant)
            alert.runModal()
        }
    }

    /* ################################################################## */
    /**
     This will hold our loaded SDK.
     We have a didSet observer, so we will assign a name upon it being set.
     */
    var deviceSDKInstance: ITCB_SDK_Protocol! {
        didSet {
            if  nil != deviceSDKInstance,
                let deviceName = Host.current().localizedName {
                self.deviceSDKInstance.localName = deviceName
            }
        }
    }
}
