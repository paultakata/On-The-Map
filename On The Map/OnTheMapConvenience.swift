//
//  OnTheMapConvenience.swift
//  On The Map
//
//  Created by Paul Miller on 29/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

extension OnTheMapClient {
    
    //MARK: - Convenience methods
    
    func authenticateWithUdacityUsername(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        //Get Udacity user ID and session ID...
        self.getUdacityUserIDsWithUsername(username, password: password) {
            (success, sessionID, userID, errorString) -> Void in
            
            if success {
                
                self.sessionID = sessionID
                self.userID    = userID
                
                //...then get the user's data...
                self.getUdacityPublicUserData({
                    success, userData, errorString in
                    
                    if success {
                        
                        if let userData = userData as? [String : AnyObject],
                            user      = userData[UdacityJSONResponseKeys.User] as? [String : AnyObject],
                            firstName = user[UdacityJSONResponseKeys.FirstName] as? String,
                            lastName  = user[UdacityJSONResponseKeys.LastName] as? String {
                                
                                //...and store them.
                                self.userFirstName = firstName
                                self.userLastName  = lastName
                        }
                    } else {
                        
                        completionHandler(success: false, errorString: errorString)
                    }
                })
                
                completionHandler(success: true, errorString: nil)
            } else {
                
                completionHandler(success: false, errorString: errorString)
            }
        }
    }
    
    func getUdacityUserIDsWithUsername(username: String, password: String, completionHandler: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        //Declare method, parameters and JSON body.
        let method = Methods.Session
        let parameters = [String : AnyObject]()
        let jsonBody = [UdacityHTTPBodyKeys.Udacity : [UdacityHTTPBodyKeys.Username : username, UdacityHTTPBodyKeys.Password : password]]
        
        //Create request.
        POSTMethodWithWebsite(Website.Udacity, method: method, parameters: parameters, jsonBody: jsonBody) {
            JSONResult, error in
            
            if let error = error {
                
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Udacity User IDs)")
            } else {
                
                //Check for server error codes.
                if let serverResponseErrorCode = JSONResult.valueForKey(UdacityJSONResponseKeys.Status) as? Int {
                    
                    if serverResponseErrorCode / 100 == 4 { //Client errors, e.g. wrong email input.
                        
                        completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Client error: wrong username or password.")
                    }
                    
                    if serverResponseErrorCode / 100 == 5 { //Server errors, e.g. server unavailable.
                        
                        completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Server error: please try again later.")
                    }
                }
                
                //Check if user account is registered.
                if let accountRegistered = JSONResult.valueForKey(OnTheMapClient.UdacityJSONResponseKeys.Account)?.valueForKey(OnTheMapClient.UdacityJSONResponseKeys.Registered) as? Bool {
                    
                    if accountRegistered == false {
                        
                        println("User not registered.")
                    } else {
                        
                        if let sessionID = JSONResult.valueForKey(OnTheMapClient.UdacityJSONResponseKeys.Session)?.valueForKey(OnTheMapClient.UdacityJSONResponseKeys.ID)  as? String,
                               userID    = JSONResult.valueForKey(OnTheMapClient.UdacityJSONResponseKeys.Account)?.valueForKey(OnTheMapClient.UdacityJSONResponseKeys.Key) as? String {
                                
                                completionHandler(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                        } else {
                            
                            completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Udacity User IDs).")
                        }
                    }
                } else {
                    completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Udacity User IDs)")
                }
            }
        }
    }
    
    func getUdacityPublicUserData(completionHandler: (success: Bool, userData: AnyObject?, errorString: String?) -> Void) {
        
        //Declare method and parameters.
        var method = Methods.UserData
        
        //Insert user ID in method.
        method = OnTheMapClient.substituteKeyInMethod(method, key: URLKeys.UserID, value: userID!)!
        let parameters = [String : AnyObject]()
        
        //Create request.
        GETMethodWithWebsite(Website.Udacity, method: method, parameters: parameters) {
            JSONResult, error in
            
            if let error = error {
                
                completionHandler(success: false, userData: nil, errorString: "Failed to retrieve Udacity user data.")
            } else {
                
                if let userData = JSONResult as? [String : AnyObject] {
                    completionHandler(success: true, userData: userData, errorString: nil)
                } else {
                    
                    completionHandler(success: false, userData: nil, errorString: "Failed to parse Udacity user data.")
                }
            }
        }
    }
    
    func logoutFromUdacity(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        //Declare method and (intentionally blank) parameters.
        var method = Methods.Session
        let parameters = [String : AnyObject]()
        
        //Create request.
        DELETEMethodWithWebsite(Website.Udacity, method: method, parameters: parameters) {
            JSONResult, error in
            
            if let error = error {
                
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    func getParseStudentLocationsWithPage(page: Int, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        //Declare parameters.
        //Check to see if page >= 1, default to 1 if not.
        let actualPage = page < 1 ? 1 : page
        let queryLimit = 100
        let queriesToSkip = (actualPage - 1) * 100
        
        //Only add "skip" parameter if page requested is not the first page.
        let parameters = actualPage == 1 ? [ParseHTTPBodyKeys.Limit : queryLimit] : [ParseHTTPBodyKeys.Limit : queryLimit, ParseHTTPBodyKeys.Skip : queriesToSkip]
        
        //Create request.
        GETMethodWithWebsite(Website.Parse, method: "", parameters: parameters) {
            JSONResult, error in
            
            if let error = error {
                
                completionHandler(result: nil, error: error)
            } else {
                
                if let results = JSONResult.valueForKey(ParseJSONResponseKeys.Results) as? [[String : AnyObject]] {
                    
                    //Create array of StudentInformation structs.
                    let studentLocations = StudentInformation.studentsFromResults(results)
                    completionHandler(result: studentLocations, error: nil)
                } else {
                    
                    completionHandler(result: nil, error: NSError(domain: "getParseStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getParseStudentLocations"]))
                }
            }
        }
    }
    
    func postParseStudentLocation(location: StudentInformation, completionHandler: (success: Bool, objectID: String?) -> Void) {
        
        //Declare parameters and JSON to be used in HTTP body.
        let parameters = [String : AnyObject]()
        let jsonBody = StudentInformation.dictionaryFromStudent(location)
        
        //Create request.
        POSTMethodWithWebsite(Website.Parse, method: "", parameters: parameters, jsonBody: jsonBody) {
            JSONResult, error in
            
            if let error = error {
                
                completionHandler(success: false, objectID: nil)
            } else {
                
                if let objectID = JSONResult.valueForKey(ParseJSONResponseKeys.ObjectID) as? String {
                    completionHandler(success: true, objectID: objectID)
                } else {
                    
                    completionHandler(success: false, objectID: nil)
                }
            }
        }
    }
    
    func putParseStudentLocation(location: StudentInformation, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        //Declare parameters and JSON to be used in HTTP body.
        let parameters = [String : AnyObject]()
        let jsonBody = StudentInformation.dictionaryFromStudent(location)
        
        //Not really a method, but easiest way to append objectID to the URL.
        let method = "/" + location.objectID
        
        //Create request.
        PUTMethodWithWebsite(Website.Parse, method: method, parameters: parameters, jsonBody: jsonBody) {
            JSONResult, error in
            
            if let error = error {
                
                completionHandler(success: false, error: error)
            } else {
                
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func getFacebookPublicUserData(completionHandler: (success: Bool, userData: AnyObject?, errorString: String?) -> Void) {
        
        //Create and make request to Facebook.
        let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        request.startWithCompletionHandler {
            connection, result, error in
            
            if let error = error {
                
                completionHandler(success: false, userData: nil, errorString: error.localizedDescription)
            } else {
                
                //Update local properties with received data.
                OnTheMapClient.sharedInstance().userFirstName = result.valueForKey(FacebookJSONResponseKeys.FirstName) as? String
                OnTheMapClient.sharedInstance().userLastName  = result.valueForKey(FacebookJSONResponseKeys.LastName)  as? String
                OnTheMapClient.sharedInstance().userID        = result.valueForKey(FacebookJSONResponseKeys.UserID)    as? String
                
                completionHandler(success: true, userData: result, errorString: nil)
            }
        }
    }
}