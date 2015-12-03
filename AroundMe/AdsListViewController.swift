//
//  AdsListViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/25/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class AdsListViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rows:Int?
    var jsonData:JSON?
    var locationManager: CLLocationManager?
    var userLocation: CLLocation?
    var sortBy: String = "distance"
    
    
    @IBOutlet var tableview: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways{
            self.locationManager?.requestAlwaysAuthorization()
        }
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager?.startUpdatingLocation()
        
        // place tableview below status bar, cuz I think it's prettier that way
        // self.tableview?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        makeRequestAndReload()
    }
    
    
    func makeRequestAndReload(){
        
        let coordinates = getUserLocation()
        
        var url: String
        
        if self.sortBy == "distance" {
            url = Defaults.sortRestaurants_byDistance
        }
        else {
            url = Defaults.sortRestaurants_byRating
        }
        
        print("Sorting by : "+self.sortBy)
        
        RestApiManager.sharedInstance.makeHTTPPostRequest(url, body:["latitude":coordinates.latitude, "longitude":coordinates.longitude], onCompletion: handleRESTCall)
        
        
    }
    
    func getUserLocation() -> CLLocationCoordinate2D {
        if userLocation == nil {
            return CLLocationCoordinate2D.init(latitude: Defaults.latitude, longitude: Defaults.longitude)
        }
        else {
            return (userLocation?.coordinate)!
        }
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if newLocation.coordinate.latitude != self.userLocation?.coordinate.latitude || newLocation.coordinate.longitude != self.userLocation?.coordinate.longitude{
            self.userLocation = newLocation
            makeRequestAndReload()
        }
    }
    


    
    func handleRESTCall(json:JSON,error:NSError?){
        print("Retrieved Documents = "+String(json.count))

        self.jsonData   = json
        self.rows       = json.count
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableview.reloadData()
            })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if rows == nil {
            return 0;
        }
        
        return rows!
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell                    = tableView.dequeueReusableCellWithIdentifier("AdsCell", forIndexPath: indexPath)

        // Configure the cell...
        let uiview                  = cell.contentView.subviews.first!
        uiview.layer.cornerRadius   = 4.0
        uiview.layer.borderColor    = UIColor.grayColor().CGColor
        uiview.layer.borderWidth    = 0.2
        uiview.clipsToBounds        = true
        
        
        // --------- Deal with Image and like button here
        
        // view with image given tag 2
        let imageview   = uiview.viewWithTag(2)?.subviews.first as! UIImageView
        
        
        
        if !self.jsonData![indexPath.row]["imagedata"].isExists(){
            let image       = UIImage(named: "food"+String((indexPath.row%Defaults.numImages)+1))!
            imageview.image = image
        }
        else {
            
            let decodedData = NSData(base64EncodedString: self.jsonData![indexPath.row]["imagedata"].stringValue, options: NSDataBase64DecodingOptions(rawValue: 0))
            imageview.image = UIImage(data: decodedData!)
        }
        
        let title       = uiview.viewWithTag(3) as! UILabel
        let postedBy    = uiview.viewWithTag(4) as! UILabel
        
        title.text      = self.jsonData![indexPath.row]["title"].stringValue
        postedBy.text   = self.jsonData![indexPath.row]["posted_by"]["name"].stringValue

        let id       = NSUserDefaults.standardUserDefaults().valueForKey("id")! as! String
        let likedUsers  = self.jsonData![indexPath.row]["likes"].arrayObject as? [String]
        
        // Assign tag to the button with the row number so that when the event fires we know which record it belonged to
        print(likedUsers)
        for tmp:AnyObject in uiview.viewWithTag(2)!.subviews{
            if tmp is UIButton {
                let button = tmp as! UIButton
                button.tag = indexPath.row
                button.addTarget(self, action: "likeButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                
                if likedUsers != nil && likedUsers!.contains(id){
                    button.setImage(UIImage(named: Defaults.like), forState: UIControlState.Normal)
                }
                else {
                    button.setImage(UIImage(named: Defaults.unlike), forState: UIControlState.Normal)
                }
                
            }
        }
        
        // ---------------------
        
        // The label displaying the distance is given tag -1
        
        
        let dLabel  = uiview.viewWithTag(-1) as! UILabel
        dLabel.text = String(metersToMiles(self.jsonData![indexPath.row]["distance"].doubleValue))+"M"

        // Use this code if road distance is needed
        if dLabel.text == "0.0M" {
            dLabel.text = ""
            getUserDistance(self.jsonData![indexPath.row]["location"]["coordinates"].arrayObject as! [Double], label: dLabel)
        }
        
        return cell
    }
    
    func getUserDistance(coordinates:[Double],label:UILabel){
        
        let destinationCord = CLLocationCoordinate2DMake(coordinates[1], coordinates[0])
        
        let sourceCord:CLLocationCoordinate2D
        if userLocation != nil {
            sourceCord  = CLLocationCoordinate2DMake((userLocation?.coordinate.latitude)!, (userLocation?.coordinate.longitude)!)
        }else {
            //Default
            sourceCord = CLLocationCoordinate2DMake(34.02169700,-118.28301700)
        }
        
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
    
    
    func likeButtonClicked(sender:UIButton!){
        
        let adsId       = jsonData![sender.tag]["_id"].stringValue
        let email       = NSUserDefaults.standardUserDefaults().valueForKey("email")!
        var image       = UIImage(named: "Like Filled-50.png")
        
        print(NSUserDefaults.standardUserDefaults().valueForKey("id")!)
        
        if sender.currentImage == image {
            image       = UIImage(named: "Like-50.png")
            RestApiManager.sharedInstance.makeHTTPPostRequest("/api/ads/restaurant/unlike", body: ["id" : adsId, "email" : email, "userid": NSUserDefaults.standardUserDefaults().valueForKey("id")!], onCompletion: nil)
        }
        else {
            RestApiManager.sharedInstance.makeHTTPPostRequest("/api/ads/restaurant/like", body: ["id" : adsId, "email" : email, "userid": NSUserDefaults.standardUserDefaults().valueForKey("id")!], onCompletion: nil)
        }
        
        sender.setImage(image, forState: UIControlState.Normal)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("detailSegue", sender: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200.00
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            
            self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            
            var indexPath:NSIndexPath?
            if let cell = sender as? UITableViewCell {
                indexPath   = self.tableview.indexPathForCell(cell)!
            }
            else {
                indexPath           = sender as? NSIndexPath
            }
            
            let navController       = segue.destinationViewController as!  UINavigationController
            
            
            let destinationController   = navController.topViewController as! DetailViewController
            destinationController.jsonData  = jsonData![indexPath!.row]
            destinationController.row       = indexPath!.row
        }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
