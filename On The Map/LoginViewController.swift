//
//  LoginViewController.swift
//  On The Map
//
//  Created by Paul Miller on 15/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var udacityImageView:      UIImageView!
    @IBOutlet weak var emailTextField:        UITextField!
    @IBOutlet weak var passwordTextField:     UITextField!
    @IBOutlet weak var debugLabel:            UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton:   FBSDKLoginButton!
    
    var appDelegate: AppDelegate!
    
    //MARK: - Overrides
    //MARK: View methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        //Assign delegates and Facebook permissions.
        appDelegate                         = UIApplication.sharedApplication().delegate as! AppDelegate
        emailTextField.delegate             = self
        passwordTextField.delegate          = self
        facebookLoginButton.delegate        = self
        facebookLoginButton.readPermissions = ["public_profile"]
        
        //Set up UI.
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        debugLabel.text = ""
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //If app is already logged in to Facebook, bypass login screen.
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            completeLogin()
        }
    }

    //MARK: Memory management
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Touch responder
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        //Use touch responder to dismiss keyboard.
        let touch = touches.first as! UITouch
        
        if touch.phase == .Began {
            
            dismissKeyboard()
        }
    }
    
    //MARK: - IBAction methods
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        
        //Check for text entry by user.
        if NSString(string: emailTextField.text).length == 0 {
            
            self.debugLabel.text = "Please enter your email."
            return
        }

        if NSString(string: passwordTextField.text).length == 0 {
            
            self.debugLabel.text = "Please enter your password."
            return
        }
        
        //Use regular expression to check validity of email entered.
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$" //Regular expression taken from www.regular-expressions.info.
        
        if let match = emailTextField.text.rangeOfString(emailRegex, options: .CaseInsensitiveSearch | .RegularExpressionSearch) {
            
            //Prettify the UI.
            dismissKeyboard()
            activityIndicatorView.startAnimating()
            dimBackground()
            
            //Attempt to authenticate with user's details.
            loginWithUdacity()
            
        } else {
            
            self.debugLabel.text = "Please enter a valid email."
        }
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        
        //Open Udacity sign in page in Safari.
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }
    
    //MARK: - Helper methods
    
    func loginWithUdacity() {
        
        //Attempt to login using Udacity email and password.
        OnTheMapClient.sharedInstance().authenticateWithUdacityUsername(emailTextField.text, password: passwordTextField.text) {
            success, errorString in
            
            if success {
                
                self.completeLogin()
            } else {
                
                self.displayError(errorString, withRetry: true)
            }
        }
    }
    
    func completeLogin() {
        
        //Prepare UI and segue to new view controller.
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
            
            //Remove dimming, activity indicator and password in preparation for a future user logout.
            self.removeDimBackground()
            self.activityIndicatorView.stopAnimating()
            self.passwordTextField.text = ""
            
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?, withRetry: Bool) {
        
        //Create alert view with passed in error string.
        dispatch_async(dispatch_get_main_queue(), {
            
            if let errorString = errorString {
                
                let alert = UIAlertController(title: "Error",
                    message: errorString,
                    preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK",
                    style: .Default,
                    handler: {
                    action in
                    
                    self.removeDimBackground()
                    self.activityIndicatorView.stopAnimating()
                })
                
                alert.addAction(okAction)
                
                //Add retry option if failed Udacity login.
                if withRetry {
                    
                    let retryAction = UIAlertAction(title: "Retry",
                        style: .Default,
                        handler: {
                        action in
                        
                        self.loginWithUdacity()
                    })
                    
                    alert.addAction(retryAction)
                }
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    func configureUI() {
        
        //Configure background gradient.
        self.view.backgroundColor = UIColor.clearColor()
        
        let colorTop = UIColor(red: 1.0, green: 0.6, blue: 0.043, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1.0, green: 0.435, blue: 0.0, alpha: 1.0).CGColor
        var backgroundGradient = CAGradientLayer()
        
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        //Add or initialise other view items.
        udacityImageView.image = UIImage(named: "udacity")
        activityIndicatorView.stopAnimating()
    }
    
    func dimBackground() {
        
        //Use a layer to create a dimmed background.
        var dimLayer = CALayer()
        
        dimLayer.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7).CGColor
        dimLayer.frame = view.frame
        self.view.layer.insertSublayer(dimLayer, below: activityIndicatorView.layer)
        
        //Keep a reference to the layer so it can be removed later.
        self.view.layer.setValue(dimLayer, forKey: "dimLayer")
    }
    
    func removeDimBackground() {
        
        if let layer = self.view.layer.valueForKey("dimLayer") as? CALayer {
            
            layer.removeFromSuperlayer()
            
            //Remember to remove the reference.
            self.view.layer.setValue(nil, forKey: "dimLayer")
        }
    }

    func dismissKeyboard() {
        
        if self.emailTextField.isFirstResponder() {
            
            self.emailTextField.resignFirstResponder()
        } else if self.passwordTextField.isFirstResponder() {
            
            self.passwordTextField.resignFirstResponder()
        }
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    //Logic to make the return key work as expected.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()
        }
        
        if textField == passwordTextField {
            
            passwordTextField.resignFirstResponder()
            loginButtonPressed(UIButton()) //I used "UIButton()" here because it isn't meaningful to try to pass a real button.
        }
        
        return true
    }
}

//MARK: - FBSDKLoginButtonDelegate

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        //Alert user if there is an error.
        if let error = error {
            
            displayError(error.localizedDescription, withRetry: false)
        } else if result.isCancelled {
            
            displayError("Please login to continue using this app.", withRetry: false)
        } else {
            
            //Check for public profile access before getting user data and completing login.
            if result.grantedPermissions.contains("public_profile") {
                
                OnTheMapClient.sharedInstance().getFacebookPublicUserData( {
                    success, userData, errorString in
                    
                    if success {
                        
                        self.completeLogin()
                    } else {
                        
                        self.displayError(errorString, withRetry: false)
                    }
                })
            } else {
                
                displayError("Public profile permission is required for this app to function.", withRetry: false)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        //Nothing required here.
    }
}
