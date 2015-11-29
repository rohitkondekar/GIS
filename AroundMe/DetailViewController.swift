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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        self.navigationItem.title                       = jsonData!["title"].stringValue
        self.navBar.backItem?.title = ""
        let scrollview  = self.view.viewWithTag(1) as! UIScrollView
        let imageview   = scrollview.viewWithTag(2)?.subviews.first as! UIImageView
        let description = scrollview.viewWithTag(3) as! UITextView
        let postedBy    = scrollview.viewWithTag(4) as! UILabel
        
        // TODO
        imageview.image     = UIImage(named: "food"+String((row!%Defaults.numImages)+1))!
        postedBy.text       = "By: "+jsonData!["posted_by"]["name"].stringValue
        

        description.attributedText = NSAttributedString(string: jsonData!["description"].stringValue, attributes: [NSFontAttributeName : UIFont(name: "HelveticaNeue-Italic", size: 17.0)!])
        description.textContainerInset = UIEdgeInsetsZero

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
