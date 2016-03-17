//
//  NewPuzzleViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/16/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import CoreLocation

class NewPuzzleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var pictureImageView: UIImageView!
    var locationManager : CLLocationManager? = nil
    var currentLocation : CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up Visual Properties
        
        // Set Up Location Services
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        print("authorizationStatus is \(authorizationStatus.hashValue)")
        
        if (authorizationStatus != .Restricted ) {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            
            // Request authorization if not determined
            if (authorizationStatus == .NotDetermined) {
                print("Request authorization")
                locationManager!.requestWhenInUseAuthorization()
            } else if (authorizationStatus == .Denied) {
                print("Authorization denied")
                
                // Alert user
                let errorAlertController = UIAlertController(
                    title: "Location Services Disabled",
                    message: "This app will only work if location services are enabled. Please enable them in your settings.",
                    preferredStyle: .Alert
                )
                let dismissAction = UIAlertAction(
                    title: "Dismiss",
                    style: .Default,
                    handler: nil
                )
                errorAlertController.addAction(dismissAction)
                
                presentViewController(errorAlertController, animated: true, completion: nil)
            } else {
                locationManager!.startUpdatingLocation()
            }
            
            // Start updating location
            print("location services enabled: \(CLLocationManager.locationServicesEnabled())")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("update location")
        currentLocation = locations.first
        
        print("new location is \(currentLocation!)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location failed with error: \(error)")
        
        // Show failure alert
        let errorAlertController = UIAlertController(
            title: "Location Services Error",
            message: "\(error.description)",
            preferredStyle: .Alert
        )
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Cancel,
            handler: nil
        )
        errorAlertController.addAction(cancelAction)
        
        presentViewController(errorAlertController, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss Picker
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get Original Image
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set image to display
        pictureImageView.image = selectedImage
        
        // Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Actions
    
    @IBAction func selectPictureButtonTapped(sender: UIButton) {
        // Bring up Image Picker
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func takePictureButtonTapped(sender: UIButton) {
        // Bring up Image Picker
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .Camera
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func createButtonTapped(sender: UIButton) {
        
        if (currentLocation != nil) {
            print("\nCurrent Location:")
            
            let locationAlertController = UIAlertController(
                title: "Location",
                message: "Latitude: \(currentLocation!.coordinate.latitude), Longitude: \(currentLocation?.coordinate.longitude)",
                preferredStyle: .Alert
            )
            let okAction = UIAlertAction(
                title: "OK",
                style: .Default,
                handler: nil
            )
            locationAlertController.addAction(okAction)
            presentViewController(locationAlertController, animated: true, completion: nil)
        } else {
            let errorAlertController = UIAlertController(
                title: "Location Services Error",
                message: "Location services may be disabled.",
                preferredStyle: .Alert
            )
            let dismissAction = UIAlertAction(
                title: "Dismiss",
                style: .Default,
                handler: nil
            )
            errorAlertController.addAction(dismissAction)
            
            presentViewController(errorAlertController, animated: true, completion: nil)
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
