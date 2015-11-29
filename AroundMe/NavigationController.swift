//
//  NavigationController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/25/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    var homeTableViewController:HomeTableViewController!
    var category:String = Defaults.category
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableViewController = self.viewControllers[0] as! HomeTableViewController
        homeTableViewController.category = self.category
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
