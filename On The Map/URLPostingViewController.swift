//
//  URLPostingViewController.swift
//  On The Map
//
//  Created by Paul Miller on 15/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit
import MapKit

//MARK: - URLPostingViewControllerDelegate Protocol

protocol URLPostingViewControllerDelegate {
    
    func controllerFinishedPostingNewData()
}

//MARK: - URLPostingViewController

class URLPostingViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var urlTextField:          UITextField!
    @IBOutlet weak var mapView:               MKMapView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var      swipeDownRecogniser:   UISwipeGestureRecognizer!
    
    var receivedLocation: CLPlacemark!
    var receivedStudent:  StudentInformation!
    var appDelegate:      AppDelegate!
    var delegate:         URLPostingViewControllerDelegate?
    
    //MARK: - Overrides
    //MARK: View methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Set delegates.
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        urlTextField.delegate = self
        
        //As the map is only used to show the proposed location to the user,
        //disable user interaction.
        mapView.userInteractionEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //UI preparation.
        removeDimBackground()
        activityIndicatorView.stopAnimating()
    }

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //Show the user the location they entered.
        updateAnnotation()
        centreMapOnLocation(receivedLocation)
    }
    
    //MARK: Memory management
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Touch responder
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        
        if touch.phase == .Began {
            
            urlTextField.resignFirstResponder()
        }
    }
    
    //MARK: - IB methods
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        //Prettify UI.
        dimBackground()
        activityIndicatorView.startAnimating()
        
        //If checkStudentInformation() is unsuccessful, it will prompt the user
        //to confirm, so there is no need to do so here.
        if checkStudentInformation() {
            
            checkWebsiteHeaderForURLString(urlTextField.text)
        }
    }

    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helper functions
    
    func centreMapOnLocation(location: CLPlacemark) {
        
        //Cast region to CLCircularRegion because many CLRegion methods are deprecated in iOS8.
        let region = location.region as! CLCircularRegion
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.location.coordinate, region.radius, region.radius)
        
        self.mapView.setRegion(coordinateRegion, animated: true)
    }

    func updateAnnotation() {
        
        let annotation = StudentInformationAnnotation(student: receivedStudent)
        
        self.mapView.addAnnotation(annotation)
    }
    
    func checkStudentInformation() -> Bool {
        
        //Check URL entered by user.
        var text = urlTextField.text as NSString
        
        //Check existence of url.
        if text.length == 0 {
            
            alertUserWithTitle("Are you sure?", message: "You haven't entered a web address.")
            return false
        }
        
        //Check if url includes "http", add it if not.
        if urlTextField.text.rangeOfString("http", options: .CaseInsensitiveSearch) == nil {
            
            text = "http://" + urlTextField.text
        }
        
        //Check if string can be an NSURL, and that Safari can open it.
        if let url = NSURL(string: text as String) {
            
            if UIApplication.sharedApplication().canOpenURL(url) {
                
                return true
            } else {
                
                alertUserWithTitle("Are you sure?", message: "This doesn't seem to be a valid web page.")
                return false
            }
        } else {
            
            alertUserWithTitle("Are you sure?", message: "This doesn't seem to be a valid web page.")
            return false
        }
    }
    
    func postStudentInformation() {
        
        //Some text is required for the mediaURL property,
        //this defaults to one whitespace if the user doesn't enter anything.
        receivedStudent.mediaURL = NSString(string: urlTextField.text).length != 0 ? urlTextField.text : " "
        
        //Check if user has already posted a location, if so, update existing location...
        if let currentUser = appDelegate.user {
            
            receivedStudent.objectID = currentUser.objectID
            
            OnTheMapClient.sharedInstance().putParseStudentLocation(receivedStudent, completionHandler: {
                success, error in
                
                if success {
                    
                    //Refresh local storage of user data.
                    self.appDelegate.user = self.receivedStudent
                    self.updateStudentLocations()
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.alertUserWithTitle("Network error", message: "Couldn't update your information. Please try again.")
                    })
                }
            })
            
            //...otherwise create and post a new location.
        } else {
            
            OnTheMapClient.sharedInstance().postParseStudentLocation(receivedStudent, completionHandler: {
                success, objectID in
                
                if success {
                    
                    //Refresh local storage of user data.
                    self.receivedStudent.objectID = objectID!
                    self.appDelegate.user = self.receivedStudent
                    
                    self.updateStudentLocations()
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.alertUserWithTitle("Network error", message: "Couldn't post your information. Please try again.")
                    })
                }
            })
        }
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

    func alertUserWithTitle(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Yes, submit it",
            style: .Destructive,
            handler: {
                action in
                self.postStudentInformation()
        })
        
        let noAction = UIAlertAction(title: "No, let me change it",
            style: .Cancel,
            handler: {
                action in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.removeDimBackground()
                    self.activityIndicatorView.stopAnimating()
                })
        })
        
        alert.addAction(okAction)
        alert.addAction(noAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkWebsiteHeaderForURLString(urlString: String) {
        
        var finalUrlString = urlString
        
        //Check if url includes "http", add it if not.
        if urlString.rangeOfString("http", options: .CaseInsensitiveSearch) == nil {
            
            finalUrlString = "http://" + urlString
        }
        
        let url = NSURL(string: finalUrlString)!

        OnTheMapClient.sharedInstance().HEADMethodForURL(url) {
            error in
            
            if let error = error {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.alertUserWithTitle("Are you sure?", message: "This doesn't seem to be a valid web page.")
                })
            } else {
                
                self.postStudentInformation()
            }
        }
    }
    
    func updateStudentLocations() {
        
        //Get the most current student locations from Parse.
        OnTheMapClient.sharedInstance().getParseStudentLocationsWithPage(1, completionHandler: {
            result, error in
            
            if let error = error {
                
                println("\(error.localizedDescription)")
            } else {
                
                if let students = result {
                    
                    //Store the results in shared storage.
                    self.appDelegate.students = students
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    //Use delegate method to update original view controller to show new data.
                    self.delegate?.controllerFinishedPostingNewData()
                    
                    //Return to original view controller.
                    self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        })
    }
}

//MARK: - MKMapViewDelegate

extension URLPostingViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        //Use dequeued view if available, otherwise create new MKPinAnnotationView.
        if let annotation = annotation {
            
            let identifier = "UserLocation"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
            }
            
            return view
        }
        return nil
    }
}

//MARK: - UITextFieldDelegate

extension URLPostingViewController: UITextFieldDelegate {
    
    //Enable return key on keyboard.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
