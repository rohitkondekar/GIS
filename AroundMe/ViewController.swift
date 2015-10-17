//
//  ViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 9/22/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var FacebookLoginButton: FBSDKLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FacebookLoginButton.readPermissions = ["email","user_location"]
        FacebookLoginButton.delegate = self
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            print("Not Logged in")
        }
        else{
            if loginServerSide(FBSDKAccessToken.currentAccessToken().tokenString) {

            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Mark: Facebook Login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        loginButton.backgroundColor?.set()
        if error == nil {
            
            if let token = result.token {
                print("login complete client side")
                if loginServerSide(token.tokenString) {
                    storeUserDetails(token.tokenString);
                }
            }
            else {
                let alert = UIAlertController(title: "Alert", message: "Facebook Login did not go through", preferredStyle:UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
        else{
            print(error.localizedDescription)
        }
    }
    
    
    func storeUserDetails(tokenString : String) {

        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(normal)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error in getting user details: \(error)")
            }
            else
            {
                
                // Save User data
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(result.valueForKey("name"), forKey: "name")
                defaults.setObject(result.valueForKey("first_name"), forKey: "first_name")
                defaults.setObject(result.valueForKey("last_name"), forKey: "last_name")

                let picturedata = result.valueForKey("picture")!["data"] as! NSDictionary
                let pictureURL = picturedata["url"] as? String
                
                if pictureURL != nil {
                    defaults.setURL(NSURL(string: pictureURL!), forKey: "profile_url")
                }
            }
            
        })

    }
    

    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out .. ")
    }
    
    
    func loginServerSide(token: String) -> Bool {
        
        var status = true
        let urlPath = "http://localhost:3000/api/auth/facebook?access_token="+token
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: urlPath)!) //mutable request
        urlRequest.HTTPMethod = "POST"
        
        let response : AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var data: NSData?
        
        do {
         data = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: response)
        }
        catch {
            print("error in server connection")
        }
        
        do {
            if let res = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
            {
                print("Access Token: "+(res["access_token"] as? String)!)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("RevealViewController") as! SWRevealViewController
                self.presentViewController(vc, animated: true, completion: nil)
                
            }
        } catch {
            
            let alert = UIAlertController(title: "Alert", message: "Invalid User credentials : could not verify on server", preferredStyle:UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            status = false
        }

        return status
    }
    
    
}

