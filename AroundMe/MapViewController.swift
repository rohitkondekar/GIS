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
    @IBOutlet weak var gpsButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var windowClearButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    var actionButton: ActionButton!
    
    var locationManager: CLLocationManager?
    var circleOverlay:MKCircle?                     // ? do we need this
    var jsonData:JSON?                              // Actual data from mongo
    var isWindowEnabled:Bool = false                // window query is active or not
    var windowAnnotations:[MKPointAnnotation] = []  // Stores annotations sequentially for a polygon
    var currentAnnotation:MKAnnotation?
    
    
    //MARK: ViewRelated
    
    override func viewDidLoad() {
        
        mapView.delegate = self
        
        // Fetch data as soon as possible
        fetchReloadData(Defaults.defaultDistance, limitCount:  nil)
        
        
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
        
        
        actionButton    = ActionButton(attachedToView: self.view, items: [nearBy,range, window], verticalConstrain: 155, horizontalConstraint: 14)
        
        actionButton.action = { button in
            button.toggleMenu()
        }
        actionButton.setTitle("+",forState: .Normal)
        
        
        // Default remove everything just enable nearby query
        self.rangeButtonDisable()
        self.windowButtonDisable()
        
        let gestureLP:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        gestureLP.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(gestureLP)
        
        self.updateReverseGeoCode(self.getUserLocation(self.mapView))
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
        self.windowAnnotations.append(annotation)
        
        print(touchCoordinate)
        print(annotation.coordinate)
        
        
        checkPolygon()
    }
    
    
    
    //MARK: Filter Buttons
    
    func rangeButtonActive(){
        
        // Remove Everything
        self.windowButtonDisable()
        
        self.fetchReloadData(nil,limitCount: nil)
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
        self.fetchReloadData(Defaults.defaultDistance,limitCount: nil)
        self.toggleActionButton()
        self.adjustZoomLevelOnMapDefault()
    }
    
    func windowButtonActive(){
        self.rangeButtonDisable()
        self.isWindowEnabled = true
        self.windowClearButton.hidden = false
        self.toggleActionButton()
        self.disableMapInterations()
    }
    
    func windowButtonDisable(){
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
        self.isWindowEnabled = false
        self.enableMapInteractions()
        self.windowClearButton.hidden = true
    }
    
    func toggleActionButton(){
        actionButton.toggleMenu()
    }
    
    func disableMapInterations(){
        self.mapView.zoomEnabled            = false
        self.mapView.scrollEnabled          = false
        self.mapView.pitchEnabled           = false
        self.mapView.rotateEnabled          = false
    }
    
    func enableMapInteractions(){
        self.mapView.zoomEnabled            = true
        self.mapView.scrollEnabled          = true
        self.mapView.pitchEnabled           = true
        self.mapView.rotateEnabled          = true
    }
    
    @IBAction func windowClearButtonClicked(sender: AnyObject) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        windowAnnotations.removeAll()
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
        
        fetchReloadData(nil,limitCount: nil)
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
    
    func checkPolygon() {
        
        if self.windowAnnotations.count < 3 {
            return
        }

        self.mapView.removeOverlays(self.mapView.overlays)
        var coordinateList:[CLLocationCoordinate2D]  = self.getPolygonCoordinates(self.windowAnnotations)
        let polygon         = MKPolygon(coordinates: &coordinateList, count: coordinateList.count)
        self.mapView.addOverlay(polygon)
        
        let doubleArray = getCoordinateToDoubleArray(coordinateList)
        RestApiManager.sharedInstance.makeHTTPPostRequest("/api/ads/polygon", body: ["category": Defaults.categoryRestaurant, "vertices":doubleArray], onCompletion: handleRESTCall)
    }
    
    func getPolygonCoordinates(annotations:[MKAnnotation]) -> [CLLocationCoordinate2D]{
        
        var coordinateList:[CLLocationCoordinate2D] = []
        for annotation in annotations {
            coordinateList.append(annotation.coordinate)
        }
        coordinateList.append(coordinateList.first!)
        
        return coordinateList
    }
    
    func getCoordinateToDoubleArray(coordinates:[CLLocationCoordinate2D]) -> [[Double]]{
        var array:[[Double]] = []
        
        for coordinate in coordinates{
            array.append([Double(coordinate.longitude),Double(coordinate.latitude)])
        }
        
        return array
    }
    
    
    
    func updateReverseGeoCode(coordinate:CLLocationCoordinate2D) {
        let location:CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            
            if placemarks != nil && placemarks!.count > 0{
                
                self.addressLabel.text = (placemarks![0].subThoroughfare?.capitalizedString)! + " " + (placemarks![0].thoroughfare?.capitalizedString)!
            }
        })
    }
    
    func getUserDistance(coordinates:[Double],label:UILabel){
        
        let destinationCord = CLLocationCoordinate2DMake(coordinates[1], coordinates[0])
        
        let sourceCord:CLLocationCoordinate2D
        let userLocation = self.getUserLocation(self.mapView)
        
        sourceCord  = CLLocationCoordinate2DMake((userLocation.latitude), (userLocation.longitude))
        
        let destinationPlaceMark:MKPlacemark = MKPlacemark.init(coordinate: destinationCord, addressDictionary: nil)
        let sourcePlaceMark:MKPlacemark = MKPlacemark.init(coordinate: sourceCord, addressDictionary: nil)
        
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.init(placemark: sourcePlaceMark)
        directionsRequest.destination = MKMapItem.init(placemark: destinationPlaceMark)
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        let directions = MKDirections.init(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler({
            (response: MKDirectionsResponse?, error: NSError?) in
            if response != nil && response?.routes.first != nil {
                label.text = String(self.metersToMiles(Double((response?.routes.first?.distance)!)))+"M"
            }
        })
        
    }

    func metersToMiles(distance:Double) -> Double{
        return round(100*(distance/1609.344))/100
    }
    
    //MARK: REST Calls
    func fetchReloadData(defaultDistance:Double?, var limitCount:Int?) {
        
        let userCoordinates = self.getUserLocation(self.mapView)
        
        
        var distance:Double
        if defaultDistance == nil {
            distance    = self.milesToMeters(Double(self.slider.value))
        }
        else {
            distance        = defaultDistance!
        }
        
        if limitCount == nil {
            limitCount = 100
        }
        
        let email           = NSUserDefaults.standardUserDefaults().valueForKey("email")!
        
        RestApiManager.sharedInstance.makeHTTPPostRequest("/api/ads/within", body: ["email" : email, "latitude" : userCoordinates.latitude, "longitude": userCoordinates.longitude, "distance" : distance, "category": Defaults.categoryRestaurant, "count": limitCount!], onCompletion: handleRESTCall)
    }
    
    func handleRESTCall(json:JSON,error:NSError?) {
        
        self.jsonData   = json
        var annotations: [JSONAnnotationModel] = []
        
        for index in 0..<json.count {
            annotations.append(JSONAnnotationModel(json: json, index:index))
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            for annotation in self.mapView.annotations {
                if annotation.isKindOfClass(JSONAnnotationModel){
                    self.mapView.removeAnnotation(annotation)
                }
            }
            
            self.mapView.addAnnotations(annotations)
        })
    }
    

    //MARK: - Map Methods
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.centerCoordinate = (userLocation.location?.coordinate)!
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check if annotation is user location
        if annotation.isKindOfClass(MKUserLocation){
            return nil
        }
        
        if annotation.isKindOfClass(JSONAnnotationModel){
            
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
        
        
        
        if self.isWindowEnabled {
//            
            let identifier = Defaults.dropPinIdentifier
//
            var view: MKImmidiateDraggableAnnotationView
//            if let dequedView           = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKImmidiateDraggableAnnotationView {
//                dequedView.annotation   = annotation
//                view                    = dequedView
//            }
//            else {
                let image           = UIImage(named: "windowpin.png")
                view                = MKImmidiateDraggableAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image          = image
                view.draggable      = true
                view.canShowCallout = false
//            }
            
            return view
            
        }
        
        return nil
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let location = view.annotation as! JSONAnnotationModel
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
        
        //var detailViewController        = DetailViewController()
        let annotation                  = view.annotation as! JSONAnnotationModel
        
        var detailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController

        
        detailViewController.jsonData   = self.jsonData![annotation.index!]
        
        let navCon = UINavigationController.init(rootViewController: detailViewController)
        detailViewController = navCon.topViewController as! DetailViewController
        detailViewController.jsonData   = self.jsonData![annotation.index!]
        detailViewController.row        = annotation.index!
        self.presentViewController(navCon, animated: true, completion: nil)
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isKindOfClass(MKCircle) {
            let circleRenderer          = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor    = UIColor(colorLiteralRed: 1, green: 1, blue: 0, alpha: 0.05)
            
            
            circleRenderer.strokeColor  = UIColor.redColor()
            circleRenderer.lineWidth    = 1
            return circleRenderer
        }
        else if overlay.isKindOfClass(MKPolygon) {
            let polygonView             = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor     = UIColor.redColor()
            polygonView.fillColor       = UIColor(colorLiteralRed: 0, green: 1, blue: 0, alpha: 0.1)
            polygonView.lineWidth       = 2
            return polygonView
        }
        
        
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {

        if newState == MKAnnotationViewDragState.Ending {
            if self.windowAnnotations.count < 3 {
                return
            }
            
            self.mapView.removeOverlays(self.mapView.overlays)
            self.checkPolygon()
        }
        else if newState == MKAnnotationViewDragState.Starting {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.updateReverseGeoCode((view.annotation?.coordinate)!)
        
        let latitude    = (view.annotation?.coordinate.latitude)! as Double
        let longitude   = (view.annotation?.coordinate.longitude)! as Double
        self.getUserDistance([longitude,latitude], label: self.distanceLabel)
        self.currentAnnotation  = view.annotation
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        self.updateReverseGeoCode(self.getUserLocation(self.mapView))
        self.distanceLabel.text = ""
        self.currentAnnotation = nil
    }

    
    // Mark: - Buttons
    @IBAction func gpsButton(sender: UIButton) {
        self.adjustZoomLevelOnMapDefault()
    }
    
    @IBAction func adressViewClicked(sender: AnyObject) {
        if self.currentAnnotation == nil {
            return
        }
        let location = self.currentAnnotation as! JSONAnnotationModel
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
        
    }
}
