//
//  HomeTableViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 10/16/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import MapKit

class HomeTableViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    var containerViewController: ContainerViewController?
    var category = Defaults.category
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.NavigationItem.title = category
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
       
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedContainer" {
            self.containerViewController = segue.destinationViewController as! ContainerViewController
        }
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
