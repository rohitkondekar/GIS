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
    var isWindowEnabled:Bool = false
    
    
    //MARK: ViewRelated
    
    override func viewDidLoad() {
        
        mapView.delegate = self
        
        // Fetch data as soon as possible
        fetchReloadData(Defaults.defaultDistance)
        
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways{
                self.locationManager?.requestAlwaysAuthorization()
        }

        mapView.showsCompass        = true
        mapView.showsUserLocation   = true
        mapView.showsBuildings      = true
    
        
        self.adjustZoomLevelOnMapDefault()
        
        let rangeImage  = UIImage(named: "range query.png")
        let range       = ActionButtonItem(title: "Radius", image: rangeImage)
        range.action    = {item in self.rangeButtonActive()}
        
        let nearByImage  = UIImage(named: "nearby.png")
        let nearBy       = ActionButtonItem(title: "Nearby", image: nearByImage)
        nearBy.action   = {item in self.nearByButtonActive()}
        
        let windowImage = UIImage(named: "polygon.png")
        let window      = ActionButtonItem(title: "Window", image: windowImage)
        window.action   = {item in self.windowButtonActive()}
    
        actionButton    = ActionButton(attachedToView: self.view, items: [nearBy,range, window], verticalConstrain: 119, horizontalConstraint: 14)
    
        actionButton.action = { button in
            button.toggleMenu()
        }
        actionButton.setTitle("+",forState: .Normal)
        
        
        // Default remove everything just enable nearby query
        rangeButtonDisable()
        
        let gestureLP:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        gestureLP.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(gestureLP)
    }
    
    
    //MARK: Gestures
    
    func handleLongPress(gestureRecognizer:UIGestureRecognizer){
        
        if !self.isWindowEnabled {
            return
        }
        
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        let touchPoint      = gestureRecognizer.locationInView(self.mapView)
        let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        let annotation          = MKPointAnnotation()
        annotation.coordinate   = touchCoordinate
        self.mapView.addAnnotation(annotation)
    }
    
    
    
    //MARK: Filter Buttons
    
    func rangeButtonActive(){
        
        // Remove Everything
        self.windowButtonDisable()
        
        self.fetchReloadData(nil)
        self.slider.hidden = false
        addCircleOverlay(self.getUserLocation(self.mapView))
        self.toggleActionButton()
        self.adjustZoomLevelOnMap()
        
    }
    
    func rangeButtonDisable(){
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
        self.slider.hidden  = true
    }
    
    func nearByButtonActive(){
        
         // Remove Everything
        self.rangeButtonDisable()
        self.windowButtonDisable()
        
        self.fetchReloadData(Defaults.defaultDistance)
        self.toggleActionButton()
        self.adjustZoomLevelOnMapDefault()
    }

    func windowButtonActive(){
        self.rangeButtonDisable()
        self.isWindowEnabled = true
        self.toggleActionButton()
    }
    
    func windowButtonDisable(){
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
        self.isWindowEnabled = false
    }
    
    func toggleActionButton(){
        actionButton.toggleMenu()
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
    
    func adjustZoomLevelOnMap(){
        let distance    = milesToMeters(Double(slider.value))*2+200
        let region      = MKCoordinateRegionMakeWithDistance(self.getUserLocation(self.mapView), distance, distance)
        mapView.setRegion(region, animated: true)
    }
    
    func adjustZoomLevelOnMapDefault(){
        let region = MKCoordinateRegionMakeWithDistance(self.getUserLocation(self.mapView), 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    
    //MARK: Slider Related
    
    @IBAction func sliderChange(sender: UISlider) {
        addCircleOverlay(self.getUserLocation(self.mapView))
    }
    
    @IBAction func sliderChangeFinished(sender: UISlider) {
        
        fetchReloadData(nil)
        self.adjustZoomLevelOnMap()
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
    func fetchReloadData(defaultDistance:Double?) {
        
        let userCoordinates = self.getUserLocation(self.mapView)
        
        
        var distance:Double
        if defaultDistance == nil {
            distance    = self.milesToMeters(Double(self.slider.value))
        }
        else {
            distance        = defaultDistance!
        }
        
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
    }
    
    
    
    
    //Mark: - Map Methods
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check if annotation is user location
        if annotation.isKindOfClass(MKUserLocation){
            return nil
        }
        
        if self.isWindowEnabled {
            
            let identifier = Defaults.dropPinIdentifier
            
            var view: MKImmidiateDraggableAnnotationView
            if let dequedView           = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKImmidiateDraggableAnnotationView {
                dequedView.annotation   = annotation
                view                    = dequedView
            }
            else {
                let image           = UIImage(named: "windowpin.png")
                view                = MKImmidiateDraggableAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image          = image
                view.draggable      = true
                view.canShowCallout = false
            }
            
            return view
            
        }
        else {
        
            let identifier = Defaults.categoryRestaurant
        
            //var view: MKPinAnnotationView
            var view: MKAnnotationView
            if let annotation = annotation as? JSONAnnotationModel {

                if let dequedView           = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                    dequedView.annotation   = annotation
                    view                    = dequedView
                }
                else {
                    //view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    
                    let image                   = UIImage(named: "map-marker.png")
                    view                        = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view.image                  = image
                    
                    view.canShowCallout         = true
                    view.calloutOffset          = CGPoint(x: -5, y: 5)
                    view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                }
                
                return view
            }
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! JSONAnnotationModel
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
    
    // Mark: - Buttons
    @IBAction func gpsButton(sender: UIButton) {
        self.adjustZoomLevelOnMapDefault()
    }
}
