//
//  ListTableViewController.swift
//  On The Map
//
//  Created by Paul Miller on 15/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var appDelegate: AppDelegate!

    //MARK: - Overrides
    //MARK: View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Set bar button items.
        setBarButtonItems()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    //MARK: Memory management
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.students.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentInfoTableViewCell", forIndexPath: indexPath) as! StudentInfoTableViewCell
        
        cell.studentNameLabel.text = appDelegate.students[indexPath.row].firstName + " " + appDelegate.students[indexPath.row].lastName
        cell.studentURLLabel.text = appDelegate.students[indexPath.row].mediaURL

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Get url string from StudentInformation.
        var urlString = appDelegate.students[indexPath.row].mediaURL
        
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
                
                alertUserWithTitle("Unable to open web page.", message: "Invalid URL.")
            }
        } else {
            
            //Alert user why nothing has happened.
            alertUserWithTitle("Unable to open web page.", message: "Invalid URL.")
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    //MARK: - IBAction methods
    
    @IBAction func refreshBarButtonPressed(sender: UIBarButtonItem) {
        
        updateStudentLocations()
    }
    
    func pinBarButtonPressed() {
        
        performSegueWithIdentifier("PinSegue", sender: self)
    }
    
    func logoutBarButtonPressed() {
        
        let alert = UIAlertController(title: "Logout?", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive) {
            action in
            
            self.logout()
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(noAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Helper functions
    
    func alertUserWithTitle(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
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
            action: "pinBarButtonPressed")
        
        let rightBarButtonItemTwo = UIBarButtonItem(barButtonSystemItem: .Refresh,
            target: self,
            action: "refreshBarButtonPressed:")
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItems = [rightBarButtonItemOne, rightBarButtonItemTwo]
    }

    func updateStudentLocations() {
        
        OnTheMapClient.sharedInstance().getParseStudentLocationsWithPage(1, completionHandler: {
            result, error in
            
            if let error = error {
                
                self.alertUserWithTitle("Error", message: error.localizedDescription)
            } else {
                
                if let students = result {
                    
                    self.appDelegate.students = students
                    self.tableView.reloadData()
                }
            }
        })
    }

    
    func logout() {
        
        OnTheMapClient.sharedInstance().logoutFromUdacity {
            success, errorString in
            
            if success {
                
                //If logout successful, remove locally stored data.
                self.appDelegate.students = []
                
                OnTheMapClient.sharedInstance().userID = nil
                OnTheMapClient.sharedInstance().sessionID = nil
                OnTheMapClient.sharedInstance().userFirstName = nil
                OnTheMapClient.sharedInstance().userLastName = nil
                
                //Go back to login screen.
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                
                self.alertUserWithTitle("Error", message: errorString!)
            }
        }
    }
}
