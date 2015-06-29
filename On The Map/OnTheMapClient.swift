//
//  OnTheMapClient.swift
//  On The Map
//
//  Created by Paul Miller on 28/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import Foundation

class OnTheMapClient: NSObject {
   
    //MARK: - Properties
    
    //Shared session.
    var session: NSURLSession
    
    //MARK: Authentication state.
    var sessionID: String?
    var userID:    String?
    
    //MARK: User details.
    var userFirstName: String?
    var userLastName:  String?
    
    //MARK: - Initialiser
    
    override init() {
        
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK: - GET

    func GETMethodWithWebsite(website: Website,
        method: String,
        parameters: [String : AnyObject],
        completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            
            //Build the URL and URL request specific to the website required.
            let urlString = website.baseURL() + method + OnTheMapClient.escapedParameters(parameters)
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            
            //Add appropriate HTTP header field keys.
            request = website.addHTTPHeaderFieldKeysForGETRequest(request)
            
            //Make the request.
            let task = session.dataTaskWithRequest(request) {
                data, response, downloadError in
                
                //Parse the received data.
                if let error = downloadError {
                    
                    let newError = OnTheMapClient.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: newError)
                } else {
                    
                    //Get data trimmed if from Udacity, otherwise parse data as is.
                    let newData = website.getAppropriateDataToReturn(data)
                    OnTheMapClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
                }
            }
            
            //Start the request task.
            task.resume()
    }
    
    // MARK: - POST
    
    func POSTMethodWithWebsite(website: Website,
        method: String,
        parameters: [String : AnyObject],
        jsonBody: [String : AnyObject],
        completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            
            //Build the URL and request specific to the website required.
            let urlString = website.baseURL() + method + OnTheMapClient.escapedParameters(parameters)
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            var jsonError: NSError?
            
            request.HTTPMethod = "POST"
            
            //Add appropriate HTTP header field keys and HTTP body.
            request = website.addHTTPHeaderFieldKeysForPOSTRequest(request)
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonError)
            
            //Make the request.
            let task = session.dataTaskWithRequest(request) {
                data, response, downloadError in
                
                //Parse the received data.
                if let error = downloadError {
                    
                    let newError = OnTheMapClient.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: newError)
                } else {
                    
                    //Get data trimmed if from Udacity, otherwise parse data as is.
                    let newData = website.getAppropriateDataToReturn(data)
                    OnTheMapClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
                }
            }
            
            //Start the request task.
            task.resume()
    }
    
    //MARK: - PUT
    
    func PUTMethodWithWebsite(website: Website,
        method: String,
        parameters: [String : AnyObject],
        jsonBody: [String:AnyObject],
        completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            
            //Build the URL and request specific to the website required.
            let urlString = website.baseURL() + method + OnTheMapClient.escapedParameters(parameters)
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            var jsonError: NSError?
            
            request.HTTPMethod = "PUT"
            
            //Add appropriate HTTP header field keys and HTTP body.
            request = website.addHTTPHeaderFieldKeysForPUTRequest(request)
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonError)
            
            //Make the request.
            let task = session.dataTaskWithRequest(request) {
                data, response, downloadError in
                
                //Parse the received data.
                if let error = downloadError {
                    
                    let newError = OnTheMapClient.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: newError)
                } else {
                    
                    //Get data trimmed if from Udacity, otherwise parse data as is.
                    let newData = website.getAppropriateDataToReturn(data)
                    OnTheMapClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
                }
            }
            
            //Start the request task.
            task.resume()
    }
    
    //MARK: - HEAD
    
    func HEADMethodForURL(url: NSURL,
        completionHandler: (error: NSError?) -> Void) {
            
            //Create HEAD request and task.
            var request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "HEAD"
            
            let task = session.dataTaskWithRequest(request) {
                data, response, downloadError in
                
                //If there is an error, pass it to the completion handler.
                if let error = downloadError {
                    
                    let newError = OnTheMapClient.errorForData(data, response: response, error: error)
                    
                    completionHandler(error: newError)
                } else {
                    
                    //If not, pass nil.
                    completionHandler(error: nil)
                }
            }
            
            //Start the request task.
            task.resume()
    }
    
    //MARK: - DELETE
    
    func DELETEMethodWithWebsite(website: Website,
        method: String,
        parameters: [String : AnyObject],
        completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            
            //Create URL and DELETE request.
            let urlString = website.baseURL() + method + OnTheMapClient.escapedParameters(parameters)
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            
            request.HTTPMethod = "DELETE"
            
            //Add appropriate HTTP header fields keys.
            request = website.addHTTPHeaderFieldKeysForDELETERequest(request)
            
            //Make the request.
            let task = session.dataTaskWithRequest(request) {
                data, response, downloadError in
                
                if let error = downloadError {
                    
                    let newError = OnTheMapClient.errorForData(data, response: response, error: error)
                    
                    completionHandler(result: nil, error: newError)
                } else {
                    
                    let newData = website.getAppropriateDataToReturn(data)
                    OnTheMapClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
                }
            }
            
            //Start the request task.
            task.resume()
    }

    
    //MARK: - Helper functions.
    
    //I repurposed these from Jarrod's code in The Movie Manager, so they are similar.
    
    //Reformat parameters to be usable in URLs.
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

    //Check to see if there is a received error, if not, return the original local error.
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[OnTheMapClient.CommonJSONResponseKeys.Error] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "OnTheMap Error", code: 1, userInfo: userInfo)
            }
        }
        return error
    }

    //Parse the received JSON data and pass it to the completion handler.
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError?
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            
            completionHandler(result: nil, error: error)
        } else {
            
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    //Swap URL placeholder for actual value of e.g. user ID.
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        
        if method.rangeOfString("{\(key)}") != nil {
            
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    // MARK: - Shared Instance
    
    class func sharedInstance() -> OnTheMapClient {
        
        struct Singleton {
            static var sharedInstance = OnTheMapClient()
        }
        
        return Singleton.sharedInstance
    }
}
