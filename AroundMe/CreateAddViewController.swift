//
//  CreateAddViewController.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/30/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import MapKit

class CreateAddViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var selector: UIPickerView!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let selectorData  = ["Restaurant", "Electronics", "Shopping"]
    
    
    @IBOutlet weak var resultDate: UIDatePicker!
    var resultCoordinates:CLLocationCoordinate2D?
    var resultCategory:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled  = self.checkEverythingIsFilled()
        
        selector.dataSource = self
        selector.delegate = self
        
        resultCategory      = selectorData[0]
    }
    
    // MARK: segue related
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        print("unwind controller")
        print("sourceViewController.resultLocation")
        
        let sourceViewController    = sender.sourceViewController as! NewAdMapViewController
        resultCoordinates           = sourceViewController.resultCoordinate!
        self.locationText.text      = sourceViewController.resultLocation
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    @IBAction func selectImageFromLibrary(sender: UITapGestureRecognizer) {
        print("tapped")
        titleText.resignFirstResponder()
        descriptionText.resignFirstResponder()
        selector.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        
        // Now present this controller
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        imageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: button
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        
        titleText = nil
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        
        let imageData = UIImageJPEGRepresentation(self.imageView.image!, 1)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        
        let dateFormatter           = NSDateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd"
        let date = dateFormatter.stringFromDate(self.resultDate.date)
        
       RestApiManager.sharedInstance.makeHTTPPostRequest("/api/ads/add", body: ["category": self.resultCategory!, "end_date": date, "email": NSUserDefaults.standardUserDefaults().valueForKey("email")!,
        "name":NSUserDefaults.standardUserDefaults().valueForKey("name")!,
        "title":self.titleText.text!,"description":self.descriptionText.text!,"longitude":(self.resultCoordinates?.longitude)!, "latitude":(self.resultCoordinates?.latitude)!, "imagedata":base64String], onCompletion: nil)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func titleEnd(sender: AnyObject) {
        self.saveButton.enabled  = self.checkEverythingIsFilled()
    }
    
    @IBAction func descriptionEnd(sender: AnyObject) {
        saveButton.enabled  = self.checkEverythingIsFilled()
    }
    
    @IBAction func locationEnd(sender: AnyObject) {
        saveButton.enabled  = self.checkEverythingIsFilled()
    }
    
    // MARK: custom
    func checkEverythingIsFilled() -> Bool{
        
        if (titleText.text == nil || descriptionText.text == nil || locationText.text == nil) {
            return false;
        }
        
        return !(titleText.text!.isEmpty || descriptionText.text!.isEmpty || locationText.text!.isEmpty)
    }
    
    // MARK: Picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return selectorData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectorData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.resultCategory  = selectorData[row]
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
