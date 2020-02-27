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

/* ###################################################################################################################################### */
// MARK: - Mode Selection Screen View Controller -
/* ###################################################################################################################################### */
/**
 This class manages the view for the main mode selection screen.
 */
class ITCB_Mode_Selection_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     The left side "CENTRAL" text button.
     */
    @IBOutlet weak var centralTextButton: UIButton!
    
    /* ################################################################## */
    /**
     The right side "PERIPHERAL" text button.
     */
    @IBOutlet weak var peripheralTextButton: UIButton!
    
    /* ################################################################## */
    /**
     The info (About Screen) button, at the top, right.
     */
    @IBOutlet weak var aboutScreenButton: UIButton!
    
    /* ################################################################## */
    /**
     Focus guide, to allow selection of the Info button.
     */
    var topFocusGuide = UIFocusGuide()
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Mode_Selection_ViewController {
    /* ################################################################## */
    /**
     This sets up our focus.
     */
    func setupFocus() {
        view.addLayoutGuide(topFocusGuide)
        topFocusGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        topFocusGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        topFocusGuide.topAnchor.constraint(equalTo: aboutScreenButton.bottomAnchor).isActive = true
        topFocusGuide.bottomAnchor.constraint(equalTo: centralTextButton.topAnchor).isActive = true
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_Mode_Selection_ViewController {
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceSDKInstance = nil // Make sure we nuke any old instances
        setupFocus()
        centralTextButton?.setTitle(" " + (centralTextButton?.title(for: .normal)?.localizedVariant ?? "ERROR"), for: .normal)
        peripheralTextButton?.setTitle(" " + (peripheralTextButton?.title(for: .normal)?.localizedVariant ?? "ERROR"), for: .normal)
    }

    /* ################################################################## */
    /**
     This is called whenever the focus changes. We use this to bring the info button into our focus group.
     
     - parameter in: The Focus Update context.
     - parameter with: The animation coordinator used for the focus change.
     */
    override func didUpdateFocus(in inContext: UIFocusUpdateContext, with inCoordinator: UIFocusAnimationCoordinator) {
      super.didUpdateFocus(in: inContext, with: inCoordinator)
        
      guard let nextFocusedView = inContext.nextFocusedView else { return }

      switch nextFocusedView {
      case centralTextButton:
        topFocusGuide.preferredFocusEnvironments = [aboutScreenButton]
        
      case peripheralTextButton:
        topFocusGuide.preferredFocusEnvironments = [aboutScreenButton]

      case aboutScreenButton:
        if let previousFocusedView = inContext.previouslyFocusedView,
            previousFocusedView == peripheralTextButton {
            topFocusGuide.preferredFocusEnvironments = [peripheralTextButton]
        } else {
            topFocusGuide.preferredFocusEnvironments = [centralTextButton]
        }
        
      default:
        ()
      }
    }
}
