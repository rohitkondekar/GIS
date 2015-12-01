//
//  DetailViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/28/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import SwiftyJSON



class DetailViewController: UIViewController, UINavigationControllerDelegate {

    var jsonData:JSON?
    var row:Int?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var expiryDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        self.navigationItem.title                       = jsonData!["title"].stringValue
        self.navBar.backItem?.title = ""
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

        
        postedBy.text       = "By: "+jsonData!["posted_by"]["name"].stringValue
        

        description.attributedText = NSAttributedString(string: jsonData!["description"].stringValue, attributes: [NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 17.0)!])
        description.textContainerInset = UIEdgeInsetsZero
        
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
  
}
