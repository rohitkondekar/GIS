//
//  Defaults.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/25/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import Foundation

class Defaults {
    
    static let category                     = "Restaurant"
    
    static let sortRestaurants_byRating     = "/api/ads/restaurant/sortrating"
    static let sortRestaurants_byDistance   = "/api/ads/restaurant/sortdistance"

    
    static let like                         = "Like Filled-50.png"
    static let unlike                       = "Like-50.png"
    static let numImages                    = 4
    
    static let latitude                     = 34.021697
    static let longitude                    = -118.283017
    
    static let meterToMile:Double           = 1609.344

    static let categoryRestaurant           = "Restaurant"
    static let dropPinIdentifier            = "DropPin"
    static let newAdPinIdentifier            = "NewAdPin"
    static let defaultDistance:Double       = 3218 //2miles
}
