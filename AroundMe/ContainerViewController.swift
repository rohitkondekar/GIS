//
//  ContainerViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 10/18/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    static let SegueIdentifierFirst : String = "embedFirst"
    static let SegueIdentifierSecond : String = "embedSecond"
    var currentSegueIdentifier : String = ""
    @IBOutlet weak var toggleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentSegueIdentifier = ContainerViewController.SegueIdentifierFirst
        performSegueWithIdentifier(self.currentSegueIdentifier, sender: nil)
        print("aftersegue")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == ContainerViewController.SegueIdentifierFirst {
            
            if self.childViewControllers.count > 0 {
                self.swapFromViewControllers(self.childViewControllers[0],toViewContoller: segue.destinationViewController)
            }
            else{
                self.addChildViewController(segue.destinationViewController)
                segue.destinationViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                self.view.addSubview(segue.destinationViewController.view)
                segue.destinationViewController.didMoveToParentViewController(self)
                self.view.bringSubviewToFront(self.toggleButton)
            }
        }
        else if segue.identifier == ContainerViewController.SegueIdentifierSecond {
            self.swapFromViewControllers(self.childViewControllers[0], toViewContoller: segue.destinationViewController)
        }
    }
    
    func swapFromViewControllers(fromViewContoller: UIViewController, toViewContoller: UIViewController){
        toViewContoller.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewContoller.willMoveToParentViewController(nil)
        self.addChildViewController(toViewContoller)
        self.transitionFromViewController(fromViewContoller, toViewController: toViewContoller, duration: 0.4, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: {finished in
            fromViewContoller.removeFromParentViewController()
            toViewContoller.didMoveToParentViewController(self)})
        self.view.bringSubviewToFront(self.toggleButton)
    }
    
    func swapViewControllers() {
        self.currentSegueIdentifier = self.currentSegueIdentifier == ContainerViewController.SegueIdentifierFirst ? ContainerViewController.SegueIdentifierSecond:ContainerViewController.SegueIdentifierFirst
        self.performSegueWithIdentifier(self.currentSegueIdentifier, sender: nil)
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        
        let button = sender as! UIButton
        var image:UIImage
        
        if self.currentSegueIdentifier == ContainerViewController.SegueIdentifierFirst {
            image = UIImage(named: "colored_list-48.png")!
        }
        else {
            image = UIImage(named: "waypoint_map-48.png")!
        }
        
        button.setBackgroundImage(image, forState: UIControlState.Normal);
        self.swapViewControllers()
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
