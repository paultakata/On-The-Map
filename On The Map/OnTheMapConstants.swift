//
//  OnTheMapConstants.swift
//  On The Map
//
//  Created by Paul Miller on 28/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import Foundation

extension OnTheMapClient {
    
    //MARK: - Constants
    
    struct Constants {
        
        //MARK: API Keys
        static let UdacityFacebookAppID = "365362206864879"
        static let ParseAppID           = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRESTAPIKey      = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //MARK: URLs
        static let BaseUdacityURL       = "https://www.udacity.com/api"
        static let BaseParseURL         = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    //MARK: - Methods
    
    struct Methods {
    
        //MARK: Udacity
        static let Session  = "/session"
        static let UserData = "/users/{id}"
        
        //MARK: Parse
        //None.
    }
    
    //MARK: - URL Keys
    
    struct URLKeys {
        
        static let UserID = "id"
    }
    
    //MARK: - HTTP Header Field Keys
    
    struct HTTPHeaderFieldKeys {
        
        static let Accept           = "Accept"
        static let ContentType      = "Content-Type"
        static let ParseAppID       = "X-Parse-Application-Id"
        static let ParseRESTAPIKey  = "X-Parse-REST-API-Key"
        static let UdacityXSRFToken = "X-XSRF-Token"
    }
    
    //MARK: - HTTP Body Keys
    
    struct UdacityHTTPBodyKeys {
    
        static let Udacity        = "udacity"
        static let Username       = "username"
        static let Password       = "password"
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken    = "access_token"
    }
    
    struct ParseHTTPBodyKeys {
    
        static let Limit    = "limit"
        static let Skip     = "skip"
        static let Where    = "where"
        static let ObjectID = "objectId"
    }
    
    //MARK: - JSON Response Keys
    
    struct UdacityJSONResponseKeys {
        
        static let Account    = "account"
        static let Registered = "registered"
        static let Key        = "key"
        static let Session    = "session"
        static let ID         = "id"
        static let Expiration = "expiration"
        static let LastName   = "last_name"
        static let FirstName  = "first_name"
        static let ImageURL   = "_image_url"
        static let Status     = "status"
        static let User       = "user"
    }
    
    
    struct ParseJSONResponseKeys {
    
        static let Results   = "results"
        static let FirstName = "firstName"
        static let LastName  = "lastName"
        static let Latitude  = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL  = "mediaURL"
        static let ObjectID  = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let CreatedAt = "createdAt"
        static let Code      = "code"
    }
    
    struct CommonJSONResponseKeys {
        
        static let Error = "error"
    }
    
    //MARK: - Website Enum
    
    enum Website {
        
        case Udacity
        case Parse
        
        //MARK: Helper functions
        
        //Return base URL by website.
        func baseURL() -> String {
            
            switch self {
            case .Udacity:
                return Constants.BaseUdacityURL
            case .Parse:
                return Constants.BaseParseURL
            }
        }
        
        //Add HTTP header field values by website for GET request.
        func addHTTPHeaderFieldKeysForGETRequest(request: NSMutableURLRequest) -> NSMutableURLRequest {
            
            switch self {
            case .Udacity:
                return request
            case .Parse:
                request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderFieldKeys.ParseAppID)
                request.addValue(Constants.ParseRESTAPIKey, forHTTPHeaderField: HTTPHeaderFieldKeys.ParseRESTAPIKey)
                return request
            }
        }
        
        //Add HTTP header field values by website for POST request.
        func addHTTPHeaderFieldKeysForPOSTRequest(request: NSMutableURLRequest) -> NSMutableURLRequest {
            
            switch self {
            case .Udacity:
                request.addValue("application/json", forHTTPHeaderField: HTTPHeaderFieldKeys.ContentType)
                request.addValue("application/json", forHTTPHeaderField: HTTPHeaderFieldKeys.Accept)
                return request
            case .Parse:
                request.addValue("application/json", forHTTPHeaderField: HTTPHeaderFieldKeys.ContentType)
                request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderFieldKeys.ParseAppID)
                request.addValue(Constants.ParseRESTAPIKey, forHTTPHeaderField: HTTPHeaderFieldKeys.ParseRESTAPIKey)
                return request
            }
        }
        
        //Add HTTP header field values by website for PUT request.
        func addHTTPHeaderFieldKeysForPUTRequest(request: NSMutableURLRequest) -> NSMutableURLRequest {
            
            switch self {
            case .Udacity:
                return request
            case .Parse:
                request.addValue("application/json", forHTTPHeaderField: HTTPHeaderFieldKeys.ContentType)
                request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderFieldKeys.ParseAppID)
                request.addValue(Constants.ParseRESTAPIKey, forHTTPHeaderField: HTTPHeaderFieldKeys.ParseRESTAPIKey)
                return request
            }
        }
        
        //Add HTTP header field values by website for DELETE request.
        func addHTTPHeaderFieldKeysForDELETERequest(request: NSMutableURLRequest) -> NSMutableURLRequest {
            
            switch self {
            case .Udacity:
                
                //Get the cookie info for Udacity...
                var xsrfCookie: NSHTTPCookie? = nil
                let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                
                for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
                    
                    if cookie.name == "XSRF-TOKEN" {
                        xsrfCookie = cookie
                    }
                }
                
                //...add it to the request to logout.
                if let xsrfCookie = xsrfCookie {
                    
                    request.addValue(xsrfCookie.value!, forHTTPHeaderField: HTTPHeaderFieldKeys.UdacityXSRFToken)
                }
                return request
            case .Parse:
                return request
            }
        }
        
        //Trim the received data if from Udacity.
        func getAppropriateDataToReturn(data: NSData) -> NSData {
            
            switch self {
            case .Udacity:
                return data.subdataWithRange(NSMakeRange(5, data.length - 5))
            case .Parse:
                return data
            }
        }
    }
}
