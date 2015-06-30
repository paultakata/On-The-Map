//
//  MapViewController.swift
//  On The Map
//
//  Created by Paul Miller on 15/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var mapView:               MKMapView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var appDelegate:         AppDelegate!
    var annotations:         [StudentInformationAnnotation] = []
    var previousAnnotations: [StudentInformationAnnotation] = []
    var locationManager:     CLLocationManager!
    var lastLocation:        CLLocation?
    
    //var URLPostingVC: URLPostingViewController?
    
    //MARK: - Overrides
    //MARK: View methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        //Get app delegate.
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Set up location manager and delegates.
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        mapView.delegate = self
        
        //Set bar button items.
        setBarButtonItems()
        
        //Populate shared storage with initial 100 student locations, then show on map.
        updateStudentLocationsWithAnnotations(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //Update annotations when view appears, in case they have been changed elsewhere.
        //updateAnnotations()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.checkLocationAuthorizationStatus()
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "PinSegue" {
            
            let nextVC = segue.destinationViewController as! InformationPostingViewController
            
            nextVC.previousVC = segue.sourceViewController as! MapViewController
        }
    }

    //MARK: Memory management
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction methods
    
    @IBAction func pinBarButtonPressed(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier("PinSegue", sender: self)
    }
    
    @IBAction func refreshBarButtonPressed(sender: UIBarButtonItem) {
        
        //Refresh data set from remote server, then display.
        updateStudentLocationsWithAnnotations(true)
    }
    
    func logoutBarButtonPressed() {
        
        //Create alert to give user choice to continue or not.
        let alert = UIAlertController(title: "Do you really want to log out?",
            message: "",
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let okAction = UIAlertAction(title: "Log Out",
            style: UIAlertActionStyle.Destructive) {
            action in
            
            self.logout()
        }
        
        let noAction = UIAlertAction(title: "No",
            style: UIAlertActionStyle.Cancel,
            handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(noAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
        
    //MARK: - Helper functions

    //This is to display an alert view using either a NSError or a String, not both.
    func displayError(error: NSError?, string: String?) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            var alert: UIAlertController?
            
            //Create alert view with passed in error or string.
            if let error = error {
                
                alert = UIAlertController(title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .Alert)
                
            } else if let string = string {
                
                alert = UIAlertController(title: "Error",
                    message: string,
                    preferredStyle: .Alert)
            }
            
            let okAction = UIAlertAction(title: "OK",
                style: .Default,
                handler: nil)
            
            alert!.addAction(okAction)
            
            self.presentViewController(alert!, animated: true, completion: nil)
        })
    }
    
    func checkLocationAuthorizationStatus() {
        
        //Check to see if app is authorized to use the user's location, ask user if not.
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            
            self.mapView.showsUserLocation = true
        } else {
            
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centreMapOnLocation(location: CLLocation) {
        
        //Zoom map to show location.
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 10000, 10000)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }

    func alertUserWithTitle(title: String, message: String) {
        
        //Create alert and show it to user.
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK",
            style: .Default,
            handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func setBarButtonItems() {
        
        //Create bar button items and set them.
        let leftBarButtonItem = UIBarButtonItem(title: "Logout",
            style: .Plain,
            target: self,
            action: "logoutBarButtonPressed")

        let rightBarButtonItemOne = UIBarButtonItem(image: UIImage(named: "pin"),
            style: .Plain,
            target: self,
            action: "pinBarButtonPressed:")
        
        let rightBarButtonItemTwo = UIBarButtonItem(barButtonSystemItem: .Refresh,
            target: self,
            action: "refreshBarButtonPressed:")
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItems = [rightBarButtonItemOne, rightBarButtonItemTwo]
    }
    
    func updateStudentLocationsWithAnnotations(check: Bool) {
        
        //Retrieve last 100 student locations.
        OnTheMapClient.sharedInstance().getParseStudentLocationsWithPage(1, completionHandler: {
            result, error in
            
            if let error = error {
                
                self.displayError(error, string: nil)
            } else {
                
                if let students = result {
                    
                    //Store them in shared storage.
                    self.appDelegate.students = students
                    
                    //Updates map annotations if check is true.
                    if check {
                        
                        //Store a copy of the old annotation array...
                        self.previousAnnotations = self.annotations
                        self.annotations = []
                        
                        for student in self.appDelegate.students {
                            
                            let annotation = StudentInformationAnnotation(student: student)
                            self.annotations.append(annotation)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            //..so we can remove them here.
                            self.mapView.removeAnnotations(self.previousAnnotations)
                            self.mapView.addAnnotations(self.annotations)
                        })
                    }
                }
            }
        })
    }
    
    func updateAnnotations() {
        
        //Clear old local data, then repopulate.
        self.previousAnnotations = self.annotations
        self.annotations = []
        
        for student in self.appDelegate.students {
            
            let annotation = StudentInformationAnnotation(student: student)
            self.annotations.append(annotation)
        }
        
        //Show on mapView.
        self.mapView.removeAnnotations(self.previousAnnotations)
        self.mapView.addAnnotations(self.annotations)
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
    
    func logout() {
        
        //If logged in using Facebook, log out using Facebook...
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            FBSDKLoginManager().logOut()
            deleteLocalData()
            
            //Go back to login view.
            dispatch_async(dispatch_get_main_queue(), {
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            })
            
            //...or if logged in using Udacity, log out using Udacity.
        } else {
            
            OnTheMapClient.sharedInstance().logoutFromUdacity {
                success, errorString in
                
                if success {
                    
                    self.deleteLocalData()
                    
                    //Go back to login view.
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    })
                } else {
                    
                    self.displayError(nil, string: errorString)
                }
            }
        }
    }
    
    func deleteLocalData() {
        
        //Delete local copies of received data.
        self.appDelegate.students = []
        
        OnTheMapClient.sharedInstance().userID = nil
        OnTheMapClient.sharedInstance().sessionID = nil
        OnTheMapClient.sharedInstance().userFirstName = nil
        OnTheMapClient.sharedInstance().userLastName = nil
    }
}

//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        //Use dequeued pin annotation view, or if not available create a new one.
        if let annotation = annotation as? StudentInformationAnnotation {
            
            let identifier = "StudentLocation"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        //Get urlString from student annotation.
        if let student = view.annotation as? StudentInformationAnnotation {
            
            var urlString = student.URLString
            
            //Add "http://" to urlString if it isn't there already.
            //This hopefully catches urls like "www.google.com" which wouldn't be opened otherwise.
            if urlString.rangeOfString("http", options: .CaseInsensitiveSearch) == nil {
                urlString = "http://" + urlString
            }
            
            //Check to see if url is an NSURL, then check if Safari can open it.
            if let url = NSURL(string: urlString) {
                
                if UIApplication.sharedApplication().canOpenURL(url) {
                    
                    //Attempt to communicate with website. If successful, assume URL is valid and open it.
                    OnTheMapClient.sharedInstance().HEADMethodForURL(url) {
                        error in
                        
                        if let error = error {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.alertUserWithTitle("Unable to open web page.", message: error.localizedDescription)
                            })
                            
                            return
                        } else {
                            
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                } else {
                    
                    //Alert user why Safari hasn't opened.
                    alertUserWithTitle("Unable to open web page.", message: "Invalid URL.")
                }
            } else {
                
                alertUserWithTitle("Unable to open web page.", message: "Invalid URL.")
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        //Centre the map on the user initially, and if they move a reasonable distance.
        let currentLocation = userLocation.location
        let distance = self.lastLocation?.distanceFromLocation(currentLocation)
        
        if distance == nil || distance > 1000 {
            
            self.lastLocation = currentLocation
            self.centreMapOnLocation(currentLocation)
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        self.checkLocationAuthorizationStatus()
    }
}

//MARK: - URLPostingViewControllerDelegate

extension MapViewController: URLPostingViewControllerDelegate {
    
    func controllerFinishedPostingNewData() {
        
        updateAnnotations()
    }
}
