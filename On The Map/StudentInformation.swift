//
//  StudentInformation.swift
//  On The Map
//
//  Created by Paul Miller on 28/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

struct StudentInformation {
    
    //MARK: - Properties
    
    var objectID:  String
    var uniqueKey: String
    var firstName: String
    var lastName:  String
    var mapString: String
    var mediaURL:  String
    var latitude:  Float
    var longitude: Float
    
    //MARK: - Initialisers
    
    init(objectID: String, uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Float, longitude: Float) {
        
        self.objectID  = objectID
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName  = lastName
        self.mapString = mapString
        self.mediaURL  = mediaURL
        self.latitude  = latitude
        self.longitude = longitude
    }
    
    init(dictionary: [String : AnyObject]) {
        
        self.objectID  = dictionary[OnTheMapClient.ParseJSONResponseKeys.ObjectID]  as! String
        self.uniqueKey = dictionary[OnTheMapClient.ParseJSONResponseKeys.UniqueKey] as! String
        self.firstName = dictionary[OnTheMapClient.ParseJSONResponseKeys.FirstName] as! String
        self.lastName  = dictionary[OnTheMapClient.ParseJSONResponseKeys.LastName]  as! String
        self.mapString = dictionary[OnTheMapClient.ParseJSONResponseKeys.MapString] as! String
        self.mediaURL  = dictionary[OnTheMapClient.ParseJSONResponseKeys.MediaURL]  as! String
        self.latitude  = dictionary[OnTheMapClient.ParseJSONResponseKeys.Latitude]  as! Float
        self.longitude = dictionary[OnTheMapClient.ParseJSONResponseKeys.Longitude] as! Float
    }
    
    //MARK: - Helper functions
    
    //Return an array of StudentInformation structs given an array of dictionaries.
    static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
    
    //Return a dictionary given a StudentInformation struct.
    static func dictionaryFromStudent(student: StudentInformation) -> [String : AnyObject] {
        
        var dictionary = [String : AnyObject]()
        
        dictionary["uniqueKey"] = student.uniqueKey
        dictionary["firstName"] = student.firstName
        dictionary["lastName"]  = student.lastName
        dictionary["mapString"] = student.mapString
        dictionary["mediaURL"]  = student.mediaURL
        dictionary["latitude"]  = student.latitude
        dictionary["longitude"] = student.longitude
        
        return dictionary
    }
}
