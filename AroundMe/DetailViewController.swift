//
//  DetailViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/28/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit


class DetailViewController: UIViewController, UINavigationControllerDelegate {

    var jsonData:JSON?
    var row:Int?
    
    @IBOutlet weak var expiryDate: UILabel!
    @IBOutlet weak var titleNavBar: UINavigationItem!
    @IBOutlet weak var locationField: UILabel!
    @IBOutlet weak var distanceFIeld: UILabel!
    @IBOutlet weak var friendImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        checkUserFriends(self.jsonData!["likes"].arrayObject as! [String])
        
        self.titleNavBar.title = self.jsonData!["title"].stringValue
        let scrollview  = self.view.viewWithTag(1) as! UIScrollView
        let imageview   = scrollview.viewWithTag(2)?.subviews.first as! UIImageView
        let description = scrollview.viewWithTag(3) as! UITextView
        let postedBy    = scrollview.viewWithTag(4) as! UILabel
        
        let date = self.jsonData!["end_date"].stringValue
        expiryDate.text = "Expires on "+date.substringToIndex(date.startIndex.advancedBy(10))
        
        if !self.jsonData!["imagedata"].isExists(){
            let image       = UIImage(named: "food"+String((row!%Defaults.numImages)+1))!
            imageview.image = image
        }
        else {
            print("in dexoded")
            let decodedData = NSData(base64EncodedString: self.jsonData!["imagedata"].stringValue, options: NSDataBase64DecodingOptions(rawValue: 0))
            imageview.image = UIImage(data: decodedData!)
        }
        
        self.friendImage.layer.cornerRadius = self.friendImage.frame.size.width / 2;
        self.friendImage.clipsToBounds = true;
        
        if row! % 3 != 0 {
            friendImage.removeFromSuperview()
        }
        
        postedBy.text       = "By: "+jsonData!["posted_by"]["name"].stringValue
        

        description.attributedText = NSAttributedString(string: jsonData!["description"].stringValue, attributes: [NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 17.0)!])
        description.textContainerInset = UIEdgeInsetsZero
        
        
        updateReverseGeoCode()
        
    }
    
    func checkUserFriends(let userIds:[String]){
        if userIds.count > 0 {
            for user in userIds{
                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(normal)"])
            }
        }
//        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(normal)"])
    }
    
    
    func updateReverseGeoCode(){
        
        let coordinates = CLLocationCoordinate2D(latitude: jsonData!["location"]["coordinates"].arrayObject![1] as! Double, longitude: jsonData!["location"]["coordinates"].arrayObject![0] as! Double)
        
        print(coordinates)
        let location:CLLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            
            if placemarks != nil && placemarks!.count > 0{
                self.locationField.text = (placemarks![0].subThoroughfare?.capitalizedString)! + " " + (placemarks![0].thoroughfare?.capitalizedString)!
            }
        })
    }

   
    @IBAction func fbButtonClicked(sender: UIBarButtonItem) {
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://www.yelp.com/la")
        content.contentTitle = jsonData!["title"].stringValue
        content.contentDescription = jsonData!["description"].stringValue
        content.imageURL = NSURL(string: "http://thenextweb.com/wp-content/blogs.dir/1/files/2012/10/Food.jpg")
        
        let button : FBSDKShareButton = FBSDKShareButton()
        
        button.shareContent = content
        button.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
    }
  
    @IBAction func doneButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func directionButtonClicked(sender: AnyObject) {
        let coordinates = CLLocationCoordinate2D(latitude: jsonData!["location"]["coordinates"].arrayObject![1] as! Double, longitude: jsonData!["location"]["coordinates"].arrayObject![0] as! Double)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
    

}
