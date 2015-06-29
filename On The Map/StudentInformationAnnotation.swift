//
//  StudentInformationAnnotation.swift
//  On The Map
//
//  Created by Paul Miller on 7/05/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import Foundation
import MapKit

//This class is a bit of a kludge, because Swift doesn't let structs conform to protocols.
class StudentInformationAnnotation: NSObject, MKAnnotation {
    
    //MARK: - Properties
    
    var title:      String
    var subtitle:   String
    var URLString:  String
    var coordinate: CLLocationCoordinate2D
    
    //MARK: - Initialisers
    
    required init(title: String, subtitle: String, URLString: String, coordinate: CLLocationCoordinate2D) {
        
        self.title      = title
        self.subtitle   = subtitle
        self.URLString  = URLString
        self.coordinate = coordinate
        
        super.init()
    }
    
    convenience init(student: StudentInformation) {
        
        let title      = student.firstName + " " + student.lastName
        let subtitle   = student.mediaURL //Because the rubric asks for the URL rather than the mapString as the subtitle.
        let URLString  = student.mediaURL
        let coordinate = CLLocationCoordinate2DMake(Double(student.latitude), Double(student.longitude))
        
        self.init(title: title, subtitle: subtitle, URLString: URLString, coordinate: coordinate)
    }
}