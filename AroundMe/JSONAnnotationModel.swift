//
//  JSONAnnotationModel.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/28/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Contacts

class JSONAnnotationModel: NSObject, MKAnnotation {
    
    let id: String
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let category: String?
    
    init(json:JSON, index:Int) {
        
        self.id         = json[index]["_id"].stringValue
        self.title      = json[index]["title"].stringValue
        self.subtitle   = json[index]["posted_by"]["name"].stringValue
        self.category   = json[index]["category"].stringValue
        
        let coord    = json[index]["location"]["coordinates"].arrayObject as! [Double]
        self.coordinate = CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
        
        super.init()
        
    }
    
    // annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): self.subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}
