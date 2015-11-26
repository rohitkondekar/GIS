//
//  MapViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 10/18/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    @IBOutlet weak var gpsButton: UIButton!
    
    
    
    override func viewDidLoad() {
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways{
                self.locationManager?.requestAlwaysAuthorization()
        }

        mapView.showsCompass = true
        mapView.showsUserLocation = true

        let userLocation = mapView.userLocation
        print(userLocation.coordinate)
        
        //let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 2000, 2000)
//        mapView.setRegion(region, animated: true)


    }
    
    
    
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
    }
    
    
    // Mark: - Map Methods
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
    
    // Mark: - Buttons
    @IBAction func gpsButton(sender: UIButton) {
        let userLocation = mapView.userLocation
        if userLocation.location != nil {
            
            let region = MKCoordinateRegionMakeWithDistance(
                userLocation.location!.coordinate, 2000, 2000)
            
            mapView.setRegion(region, animated: true)
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
