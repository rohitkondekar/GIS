//
//  NewAdMapViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/30/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import MapKit

class NewAdMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addressLabel: UILabel!
    
    var locationManager: CLLocationManager?
    var resultCoordinate: CLLocationCoordinate2D?
    var resultLocation: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate    = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways{
            self.locationManager?.requestAlwaysAuthorization()
        }
        
        mapView.showsCompass        = true
        mapView.showsBuildings      = true
        
        self.adjustZoomLevelOnMapDefault()
        
        let annotation          = MKPointAnnotation()
        annotation.coordinate   = self.getUserLocation(self.mapView)
        self.mapView.addAnnotation(annotation)
        self.resultCoordinate   = annotation.coordinate
        
        let gestureLP:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        gestureLP.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(gestureLP)
        
        self.updateReverseGeoCode()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = Defaults.categoryRestaurant
        
        let image           = UIImage(named: "newadd.png")
        let view            = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.image          = image
        
        view.canShowCallout = true
        view.calloutOffset  = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        
        return view
    }
    
    //MARK: Gestures
    
    func handleLongPress(gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        let touchPoint      = gestureRecognizer.locationInView(self.mapView)
        let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        let annotation          = MKPointAnnotation()
        annotation.coordinate   = touchCoordinate
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        self.resultCoordinate = touchCoordinate
        
        updateReverseGeoCode()
    }
    
    
    //MARK: Button Methods
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonClicked(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: MAP Methods
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == MKAnnotationViewDragState.Ending {
            resultCoordinate = view.annotation?.coordinate
            self.updateReverseGeoCode()
        }
    }

    
    
    
    //MARK: Custom Methods
    
    func adjustZoomLevelOnMapDefault(){
        let region = MKCoordinateRegionMakeWithDistance(self.getUserLocation(self.mapView), 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func getUserLocation(mapview: MKMapView) -> CLLocationCoordinate2D{
        if mapview.userLocation.location == nil || (mapview.userLocation.coordinate.longitude == 0 &&  mapview.userLocation.coordinate.latitude == 0) {
            return CLLocationCoordinate2D(latitude: Defaults.latitude, longitude: Defaults.longitude)
        }
        
        return mapview.userLocation.coordinate
    }
    
    func updateReverseGeoCode(){
        let location:CLLocation = CLLocation(latitude: (self.resultCoordinate?.latitude)!, longitude: (self.resultCoordinate?.longitude)!)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
           
            if placemarks != nil && placemarks!.count > 0{
                self.addressLabel.text = (placemarks![0].subThoroughfare?.capitalizedString)! + " " + (placemarks![0].thoroughfare?.capitalizedString)!
                self.resultLocation = self.addressLabel.text! + " " + placemarks![0].locality!
            }
        })
    }
}
