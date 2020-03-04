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
// MARK: - The Main Application Delegate Class -
/* ###################################################################################################################################### */
/**
 This handles making sure that the mode selector is always shown on startup or brining to the foreground.
 */
@UIApplicationMain
class ITCB_AppDelegate: UIResponder, UIApplicationDelegate {
    /* ################################################################## */
    /**
     This is a shortcut to get the app delegate instance as an instance of this class.
     */
    class var appDelegate: Self! {
        return UIApplication.shared.delegate as? Self
    }
    
    /* ################################################################## */
    /**
     This displays a simple alert, with an OK button.
     
     - parameter header: The header to display at the top.
     - parameter message: A String, containing whatever messge is to be displayed below the header.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(header inHeader: String, message inMessage: String = "", presentedBy inPresentingViewController: UIViewController! = nil) {
        // This ensures that we are on the main thread.
        DispatchQueue.main.async {
            var presentedBy = inPresentingViewController
            
            if nil == presentedBy {
                presentedBy = (UIApplication.shared.windows.filter { $0.isKeyWindow }.first)?.rootViewController
            }
            
            if nil != presentedBy {
                let alertController = UIAlertController(title: inHeader.localizedVariant, message: inMessage.localizedVariant, preferredStyle: .actionSheet)
                
                let okAction = UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: UIAlertAction.Style.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is required for UIApplicationDelegate conformance.
     */
    var window: UIWindow?
    
    /* ################################################################## */
    /**
     This will hold our loaded SDK.
     We have a didSet observer, so we will assign a name upon it being set.
     */
    var deviceSDKInstance: ITCB_SDK_Protocol! {
        didSet {
            if  nil != deviceSDKInstance {
                self.deviceSDKInstance.localName = UIDevice.current.name
            }
        }
    }

    /* ################################################################## */
    /**
     We use this to hang onto our main mode selection screen, so we can go back to it.
     */
    var modeSelectionViewController: ITCB_Mode_Selection_ViewController!
    
    /* ################################################################## */
    /**
     We use this to hang onto our main navigation controller.
     */
    var mainNavigationController: UINavigationController!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_AppDelegate {
    /* ################################################################## */
    /**
     Called after the application completes its launch setup.
     
     - parameter application: Ignored
     - parameter didFinishLaunchingWithOptions: Ignored
     
     -returns: true (always)
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     This is called just as the app is about to come up. We use it to make sure that we always start with the mode selector.
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        if  let navigationController = mainNavigationController,
            let mainController = modeSelectionViewController {
            navigationController.setViewControllers([mainController], animated: false)
        }
    }
}
