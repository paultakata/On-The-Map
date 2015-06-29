//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Paul Miller on 15/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var enterPlaceTextField:                 UITextField!
    @IBOutlet weak var centreView:                          UIView!
    @IBOutlet weak var centreViewHeightConstraint:          NSLayoutConstraint!
    @IBOutlet weak var findButtonVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var findButton:                          UIButton!
    @IBOutlet weak var activityIndicatorView:               UIActivityIndicatorView!
    @IBOutlet var      swipeDownRecogniser:                 UISwipeGestureRecognizer!
    
    var student: StudentInformation?
    
    //MARK: - Overrides
    //MARK: View methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Adjust certain constraints based on the device screen size.
        centreViewHeightConstraint.constant = (UIScreen.mainScreen().applicationFrame.size.height / 3.0)
        findButtonVerticalSpacingConstraint.constant = (UIScreen.mainScreen().applicationFrame.size.height / 7.5)
        
        enterPlaceTextField.delegate = self
        
        //Set swipe gesture direction.
        swipeDownRecogniser.direction = .Down
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //UI preparation.
        removeDimBackground()
        activityIndicatorView.stopAnimating()
    }
    
    //MARK: Memory management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Touch responder
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        
        if touch.phase == .Began {
            
            enterPlaceTextField.resignFirstResponder()
        }
    }
    
    //MARK: - IBAction methods
    
    @IBAction func findButtonPressed(sender: UIButton) {
        
        //Create geocoder.
        let geocoder = CLGeocoder()
        
        //Prettify the UI.
        dimBackground()
        activityIndicatorView.startAnimating()
        
        //Retrieve location from user input.
        geocoder.geocodeAddressString(enterPlaceTextField.text, inRegion: nil) {
            resultArray, error in //This completion handler executes on the main thread.
            
            if let error = error {
                
                self.alertUserWithTitle("Error", message: error.localizedDescription)
            } else {
                
                if let location = resultArray.first as? CLPlacemark { //Assume the first result is correct.
                    
                    //Send it to the URL posting view controller.
                    let nextVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostingViewController") as! URLPostingViewController
                    
                    nextVC.receivedLocation = location
                    
                    self.student = StudentInformation(objectID: "",
                        uniqueKey: OnTheMapClient.sharedInstance().userID!,
                        firstName: OnTheMapClient.sharedInstance().userFirstName!,
                        lastName:  OnTheMapClient.sharedInstance().userLastName!,
                        mapString: self.enterPlaceTextField.text,
                        mediaURL:  "",
                        latitude:  Float(location.location.coordinate.latitude),
                        longitude: Float(location.location.coordinate.longitude))
                    
                    nextVC.receivedStudent = self.student
                    
                    self.presentViewController(nextVC, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helper functions
    
    func alertUserWithTitle(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK",
            style: .Default,
            handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
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
}

//MARK: - UITextFieldDelegate

extension InformationPostingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
