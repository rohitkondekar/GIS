//
//  MapViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 10/18/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView : MKMapView!
    var locationManager: CLLocationManager?
    @IBOutlet weak var gpsButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    var actionButton: ActionButton!
    
    var circleOverlay:MKCircle?
    var jsonData:JSON?
    
    //MARK: ViewRelated
    
    override func viewDidLoad() {
        
        mapView.delegate = self
        
        // Fetch data as soon as possible
        fetchReloadData()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways{
                self.locationManager?.requestAlwaysAuthorization()
        }

        mapView.showsCompass        = true
        mapView.showsUserLocation   = true
        mapView.showsBuildings      = true
        
        let userLocationCordinates  = getUserLocation(mapView)
        
        let region = MKCoordinateRegionMakeWithDistance(userLocationCordinates, 2000, 2000)

        mapView.setRegion(region, animated: true)
        
        
        let rangeImage  = UIImage(named: "range query.png")
        let range       = ActionButtonItem(title: "Radius", image: rangeImage)
        range.action    = {item in self.actionButton.toggleMenu()}
        
        actionButton    = ActionButton(attachedToView: self.view, items: [range], verticalConstrain: 119, horizontalConstraint: 14)
    
        actionButton.action = { button in
            button.toggleMenu()
        }
        actionButton.setTitle("+",forState: .Normal)
        
        
        addCircleOverlay(userLocationCordinates)
    }
    
    //MARK: Circle Realted
    
    func addCircleOverlay(userLocationCordinates: CLLocationCoordinate2D){
        
        if circleOverlay != nil {
            mapView.removeOverlay(circleOverlay!)
        }
        
        // Or remove all
        // mapView.removeOverlays(mapView.overlays)
        
        circleOverlay = MKCircle(centerCoordinate: userLocationCordinates, radius: milesToMeters(Double(slider.value)))
        
        mapView.addOverlay(circleOverlay!)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isKindOfClass(MKCircle) {
            let circleRenderer          = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor    = UIColor(colorLiteralRed: 1, green: 1, blue: 0, alpha: 0.05)
            
            
            circleRenderer.strokeColor  = UIColor.redColor()
            circleRenderer.lineWidth    = 1
            return circleRenderer
        }
        
        
        return MKOverlayRenderer()
        
    }
    
    
    //MARK: Slider Related
    
    @IBAction func sliderChange(sender: UISlider) {
        addCircleOverlay(self.getUserLocation(self.mapView))
    }
    
    @IBAction func sliderChangeFinished(sender: UISlider) {
        fetchReloadData()
    }

    //MARK: Custom Methods
    
    func milesToMeters(value:Double) -> Double{
            return Defaults.meterToMile*value
    }
    
    func getUserLocation(mapview: MKMapView) -> CLLocationCoordinate2D{
        if mapview.userLocation.location == nil || (mapview.userLocation.coordinate.longitude == 0 &&  mapview.userLocation.coordinate.latitude == 0) {
            return CLLocationCoordinate2D(latitude: Defaults.latitude, longitude: Defaults.longitude)
        }
        
        return mapview.userLocation.coordinate
    }
    
    //MARK: REST Calls
    func fetchReloadData() {
        
        let userCoordinates = self.getUserLocation(self.mapView)
        let distance        = self.milesToMeters(Double(self.slider.value))
        let email           = NSUserDefaults.standardUserDefaults().valueForKey("email")!
        
        RestApiManager.sharedInstance.makeHTTPPostRequest("/api/ads/within", body: ["email" : email, "latitude" : userCoordinates.latitude, "longitude": userCoordinates.longitude, "distance" : distance, "category": Defaults.categoryRestaurant], onCompletion: handleRESTCall)
    }
    
    func handleRESTCall(json:JSON,error:NSError?) {
        
        var annotations: [JSONAnnotationModel] = []
        
        for index in 0..<json.count {
            annotations.append(JSONAnnotationModel(json: json, index:index))
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        })
            
        print("annotations updated")
        print(json.count)
    }
    
    
    
    
    // Mark: - Map Methods
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("annotations relayed")
        
        let identifier = Defaults.categoryRestaurant
        var view: MKPinAnnotationView
        
        if let annotation = annotation as? JSONAnnotationModel {

            if let dequedView           = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequedView.annotation   = annotation
                view                    = dequedView
            }
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            
            return view
        }
        
        return nil
        
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
}
