//
//  RestApiManager.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/25/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    
    static let sharedInstance = RestApiManager()
    
    let defaultPath = "http://localhost:3000"
    
    //MARK: Perform a GET Request
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: defaultPath+path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume() // This submits the request
    }
    
    //MARK: Perform a POST Request
    func makeHTTPPostRequest(path: String, body: [String: AnyObject]?, onCompletion: ServiceResponse?) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: defaultPath+path)!)
        
        // Set the method to POST
        request.HTTPMethod = "POST"
        
        // Set the POST body for the request
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject( (body != nil ? body! : []) , options: NSJSONWritingOptions(rawValue:0))
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        catch {
            
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, err -> Void in
            
            if data != nil {
                let json:JSON = JSON(data: data!)
                
                if onCompletion != nil {
                    onCompletion?(json, err)
                }
            }
        })
        task.resume()
    }
    
}