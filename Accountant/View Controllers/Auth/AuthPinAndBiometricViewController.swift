//
//  ViewController.swift
//  Passcode
//
//  Created by Roman Topchii on 11.09.2020.
//

import UIKit
import LocalAuthentication

class AuthPinAndBiometricViewController: UIViewController {
    @IBOutlet weak var oneButton : UIButton!
    @IBOutlet weak var twoButton : UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton : UIButton!
    @IBOutlet weak var fiveButton : UIButton!
    @IBOutlet weak var sixButton : UIButton!
    @IBOutlet weak var sevenButton : UIButton!
    @IBOutlet weak var eightButton : UIButton!
    @IBOutlet weak var nineButton : UIButton!
    @IBOutlet weak var zeroButton : UIButton!
    @IBOutlet weak var biometryAuthButton : UIButton!
    @IBOutlet weak var deleteButton : UIButton!
    
    @IBOutlet weak var firstNumberView: UIView!
    @IBOutlet weak var secondNumberView: UIView!
    @IBOutlet weak var thirdNumberView: UIView!
    @IBOutlet weak var fourthNumberView: UIView!
    
    var previousNavigationStack : UIViewController?
    
    var password : Int = 0
    var passwordArray : [Int] = [] {
        didSet {
//            password = passwordArray[0]*1000+passwordArray[1]*100+passwordArray[2]*10+passwordArray[3]
        }
    }
    
    /// An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()


    /// The current authentication state.
    var state = AuthenticationState.loggedout {
        didSet {
            if state == .loggedin {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                if let previousNavigationStack = previousNavigationStack {
                    appDelegate.window?.rootViewController = previousNavigationStack
                }
                else {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: "TabBarController_ID")
                    self.navigationController?.popToRootViewController(animated: false)
                    appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            
            if context.biometryType == .faceID {
                biometryAuthButton.setImage(UIImage(systemName: "faceid"), for: .normal)
            }
            else if context.biometryType == .touchID {
                biometryAuthButton.setImage(UIImage(systemName: "touchid"), for: .normal)
            }
            else if context.biometryType == .none{
                print(".none")
            }
        }
        
        let radius = oneButton.frame.size.width/2
        oneButton.layer.cornerRadius = radius
        twoButton.layer.cornerRadius = radius
        threeButton.layer.cornerRadius = radius
        fourButton.layer.cornerRadius = radius
        fiveButton.layer.cornerRadius = radius
        sixButton.layer.cornerRadius = radius
        sevenButton.layer.cornerRadius = radius
        eightButton.layer.cornerRadius = radius
        nineButton.layer.cornerRadius = radius
        zeroButton.layer.cornerRadius = radius
        deleteButton.layer.cornerRadius = radius
        biometryAuthButton.layer.cornerRadius = radius
        
        
        let borderColor = CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        firstNumberView.layer.borderColor = borderColor
        secondNumberView.layer.borderColor = borderColor
        thirdNumberView.layer.borderColor = borderColor
        fourthNumberView.layer.borderColor = borderColor
        oneButton.layer.borderColor = borderColor
        twoButton.layer.borderColor = borderColor
        threeButton.layer.borderColor = borderColor
        fourButton.layer.borderColor = borderColor
        fiveButton.layer.borderColor = borderColor
        sixButton.layer.borderColor = borderColor
        sevenButton.layer.borderColor = borderColor
        eightButton.layer.borderColor = borderColor
        nineButton.layer.borderColor = borderColor
        zeroButton.layer.borderColor = borderColor
//        deleteButton.layer.borderColor = borderColor
//        touchIdButton.layer.borderColor = borderColor
        
        let borderWidth : CGFloat = 2
        firstNumberView.layer.borderWidth = borderWidth
        secondNumberView.layer.borderWidth = borderWidth
        thirdNumberView.layer.borderWidth = borderWidth
        fourthNumberView.layer.borderWidth = borderWidth
        oneButton.layer.borderWidth = borderWidth
        twoButton.layer.borderWidth = borderWidth
        threeButton.layer.borderWidth = borderWidth
        fourButton.layer.borderWidth = borderWidth
        fiveButton.layer.borderWidth = borderWidth
        sixButton.layer.borderWidth = borderWidth
        sevenButton.layer.borderWidth = borderWidth
        eightButton.layer.borderWidth = borderWidth
        nineButton.layer.borderWidth = borderWidth
        zeroButton.layer.borderWidth = borderWidth
//        deleteButton.layer.borderWidth = borderWidth
//        touchIdButton.layer.borderWidth = borderWidth
        
        
      
        
    }
    
    
    @IBAction func numberedButtonPressed(_ sender: UIButton) {
        if passwordArray.count <= 3 {
            passwordArray.append(sender.tag)
        }
        print("passwordArray", passwordArray)
        switch passwordArray.count {
        case 1:
            firstNumberView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        case 2:
            secondNumberView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        case 3:
            thirdNumberView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        case 4:
            fourthNumberView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        default:
            break
        }
    }
    
    @IBAction func deleteLastOneNumber(_ sender: UIButton) {
        if passwordArray.count >= 1{
            passwordArray.remove(at: passwordArray.count-1)
        }
        print("passwordArray", passwordArray)
        switch passwordArray.count {
        case 0:
            firstNumberView.backgroundColor = .white
        case 1:
            secondNumberView.backgroundColor = .white
        case 2:
            thirdNumberView.backgroundColor = .white
        case 3:
            fourthNumberView.backgroundColor = .white
        default:
            break
        }
    }
    
    @IBAction func biometryAuthentication(){
        // Get a fresh context for each login. If you use the same context on multiple attempts
        //  (by commenting out the next line), then a previously successful authentication
        //  causes the next policy evaluation to succeed without testing biometry again.
        //  That's usually not what you want.
        
        context.localizedCancelTitle = NSLocalizedString("Cancel", comment: "")

        // First check if we have the needed hardware support.
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

            let reason = NSLocalizedString("to activate", comment: "")
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                if success {

                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async { [unowned self] in
                        self.state = .loggedin
                    }

                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")

                    // Fall back to a asking for username and password.
                    // ...
                }
            }
        } else {
            print(error?.localizedDescription ?? "Can't evaluate policy")

            // Fall back to a asking for username and password.
            // ...
        }
    }
}

