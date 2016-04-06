//
//  NewPuzzleViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Firebase

class NewPuzzleViewController: UIViewController, CLLocationManagerDelegate {

    // Photo Buttons
    var usePhotoButton : UIButton!
    var retakePictureButton : UIButton!
    var capturePhotoButton : UIButton!
    var locationAccuracyLabel : UILabel!
    
    // Image processing
    var capturedImageView = UIImageView()
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // Location processing
    var locationManager : CLLocationManager?
    var pictureLocation : CLLocation?
    var pictureData : NSData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCameraFunction()
        setupLocationServices()
    }
    
    func setupCameraFunction() {
        // Use Photo Button
        let width : CGFloat = 100.0
        let height : CGFloat = 30.0
        usePhotoButton = UIButton(type: .System)
        usePhotoButton.setTitle("Use Photo", forState: .Normal)
        usePhotoButton.frame = CGRect(
            x: view.frame.maxX - width - 8,
            y: view.frame.maxY - height - 78.0,
            width: width,
            height: height
        )
        usePhotoButton.addTarget(self, action: #selector(usePhotoButtonTapped), forControlEvents: .TouchUpInside)
        view.addSubview(usePhotoButton)
        
        // Retake Picture Button
        retakePictureButton = UIButton(type: .System)
        retakePictureButton.setTitle("Retake", forState: .Normal)
        retakePictureButton.frame = CGRect(
            x: view.frame.minX + 8,
            y: view.frame.maxY - height - 78,
            width: width,
            height: height
        )
        retakePictureButton.addTarget(self, action: #selector(retakePictureButtonTapped), forControlEvents: .TouchUpInside)
        view.addSubview(retakePictureButton)
        
        // Capture Photo Button
        capturePhotoButton = UIButton(type: .Custom)
        let length : CGFloat = 70.0
        capturePhotoButton.frame = CGRect(
            x: view.frame.midX - length/2.0,
            y: view.frame.maxY - length - 70.0,
            width: length,
            height: length
        )
        capturePhotoButton.layer.cornerRadius = capturePhotoButton.frame.width/2.0
        capturePhotoButton.backgroundColor = UIColor.blackColor()
        capturePhotoButton.addTarget(self, action: #selector(capturePhotoButtonTapped), forControlEvents: .TouchUpInside)
        view.addSubview(capturePhotoButton)
        view.bringSubviewToFront(capturePhotoButton)
        
        // Location Accuracy Label
        locationAccuracyLabel = UILabel()
        locationAccuracyLabel.textAlignment = .Center
        locationAccuracyLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
        locationAccuracyLabel.center = CGPoint(x: view.frame.midX, y: capturePhotoButton.frame.minY - 8)
        view.addSubview(locationAccuracyLabel)
        
        // Set up captured image view
        capturedImageView.frame = CGRect(x: 0, y: 80, width: view.bounds.width, height: view.bounds.width)
        view.addSubview(capturedImageView)
        
        // Hide Captured Image View
        capturedImageView.hidden = true
        usePhotoButton.hidden = true     // Hide until picture is taken
        retakePictureButton.hidden = true
        locationAccuracyLabel.hidden = true
        
        // Set up Capture Session
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Set up input device
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input = try? AVCaptureDeviceInput(device: backCamera)
        
        if (input != nil && captureSession!.canAddInput(input)) {
            captureSession!.addInput(input)
        }
        
        // Set up Output
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput!.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        
        captureSession!.addOutput(stillImageOutput)
        
        // Set up Live Preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        previewLayer!.frame = capturedImageView.frame
        previewLayer!.zPosition = -10
        view.layer.addSublayer(previewLayer!)
        
        // Start session
        captureSession!.startRunning()
    }
    
    func setupLocationServices() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == .Restricted) {
            
            // Show Error Alert
            let errorAlertController = UIAlertController(
                title: "Location Authorization Restricted",
                message: "This app will be unable to verify the correctness of puzzles without enabled location services.",
                preferredStyle: .Alert
            )
            let dismissAlertAction = UIAlertAction(
                title: "Dismiss",
                style: .Default,
                handler: nil
            )
            errorAlertController.addAction(dismissAlertAction)
            
        } else if (authorizationStatus == .Denied) {
            
            // Show Error Alert
            let errorAlertController = UIAlertController(
                title: "Location Authorisation Denied",
                message: "This app will be unable to verify the correctness of puzzles without enabled location services.",
                preferredStyle: .Alert
            )
            let dismissAlertAction = UIAlertAction(
                title: "Dismiss",
                style: .Default,
                handler: nil
            )
            errorAlertController.addAction(dismissAlertAction)
            
        } else {
            
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.distanceFilter = 0.5
            
            if (authorizationStatus == .NotDetermined) {
                locationManager!.requestWhenInUseAuthorization()    // handled later by Delegate
            } else {
                locationManager!.startUpdatingLocation()
            }
        }
        
        print("Location services enabled: \(CLLocationManager.locationServicesEnabled())")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error: \(error.description)")
        
        // Show Error Alert
        let errorAlertController = UIAlertController(
            title: "Location Services Error",
            message: "\(error.description)",
            preferredStyle: .Alert
        )
        let dismissAlertAction = UIAlertAction(
            title: "Dismiss",
            style: .Default,
            handler: nil
        )
        errorAlertController.addAction(dismissAlertAction)
        
        presentViewController(errorAlertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if (status == .AuthorizedWhenInUse) {
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print("Did finish deferring updates with error: \(error!.description)")
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        print("did pause location updates")
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        print("Did resume location updates")
    }
    
    
    // MARK: - Actions
    func capturePhotoButtonTapped() {
        // Set up data connection to capture photo
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            
            stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                
                let contextImage = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: .Right)
                
                // Crop image to a square
                let croppedImage = self.cropToSquare(image: contextImage)
                
                self.capturedImageView.image = croppedImage
                
                // Save image data
                self.pictureData = UIImageJPEGRepresentation(croppedImage, 1.0)
                
                // Show capturedImageView and buttons
                self.capturedImageView.hidden = false
                self.usePhotoButton.hidden = false
                self.retakePictureButton.hidden = false
                self.locationAccuracyLabel.hidden = false
                
                // Hide previewLayer
                self.previewLayer!.hidden = true
                self.capturePhotoButton.hidden = true
                
                print("number of bytes: \(self.pictureData!.bytes)")
//                print("description: \(self.pictureData!.description)")
            })
        }
        
        // Capture the location
        pictureLocation = locationManager!.location
        self.locationAccuracyLabel.text = "Accuracy: \(pictureLocation!.horizontalAccuracy)m"
        print("\n\nPicture Location: \(pictureLocation)")
        print("\tCoordinate: \(pictureLocation!.coordinate)")
        print("\tFloor: \(pictureLocation!.floor)")
        print("\tHorizontal accuracy: \(pictureLocation!.horizontalAccuracy) (meters)")
        print("\tVertical accuracy: \(pictureLocation!.verticalAccuracy) (meters)")
    }
    
    func retakePictureButtonTapped() {
        
        // Show previewLayer
        previewLayer!.hidden = false
        capturePhotoButton.hidden = false
        
        // Hide capturedImageView and buttons
        capturedImageView.hidden = true
        capturedImageView.image = nil
        
        usePhotoButton.hidden = true
        retakePictureButton.hidden = true
        locationAccuracyLabel.hidden = true
    }
    
    func usePhotoButtonTapped() {
        
        if (pictureLocation == nil) {
            // Alert location error
            print("Error creating puzzle - location")
            let errorAlertController = UIAlertController(title: "Error Creating Puzzle", message: "There was an error with the location data creating your puzzle.", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            presentViewController(errorAlertController, animated: true, completion: nil)
            
        } else if (pictureData == nil) {
            // Alert image error
            print("Error creatinng puzzle - picture data")
            let errorAlertController = UIAlertController(title: "Error Creating Puzzle", message: "There was an error with the image data creating your puzzle.", preferredStyle: .Alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            presentViewController(errorAlertController, animated: true, completion: nil)
            
        } else {
            // Create Puzzle Object
            var tagsText = ""
            
            print("Ask for tags")
            
            // Ask user for tags
            let tagAlertController = UIAlertController(title: "Add Tag", message: "Please enter tags for your puzzle separated by commas. For example, Cornell University.", preferredStyle: .Alert)
            tagAlertController.addTextFieldWithConfigurationHandler({(textField) in
                
                textField.placeholder = "Tags"
                
            })
            let doneAlertAction = UIAlertAction(title: "Done", style: .Default, handler: {(action) in
                
                let tagsField = tagAlertController.textFields!.first!
                if (tagsField.text != nil) {
                    tagsText = tagsField.text!
                }
                
                // Create Puzzle Object
                let newPuzzle = Puzzle(
                    withPictureData: self.pictureData!,
                    latitude: self.pictureLocation!.coordinate.latitude,
                    longitude: self.pictureLocation!.coordinate.longitude,
                    horizontalAccuracy: self.pictureLocation!.horizontalAccuracy,
                    tags: tagsText
                )
                
                // Save puzzle
                let firebaseReference = Firebase(url: "https://shining-heat-3670.firebaseio.com/")
                
                let puzzlesRef = firebaseReference.childByAppendingPath("puzzles")
                let newPuzzleRef = puzzlesRef.childByAutoId()
                newPuzzleRef.setValue(newPuzzle.convertToFirebaseData(), withCompletionBlock: {(error, firebaseRef) in
                    
                    if (error != nil) {
                        print("Error saving to firebase: \(error)")
                        
                        // Alert User of error
                        let errorAlertController = UIAlertController(title: "Error Creating Puzzle", message: "There was an error with the database creating your puzzle.", preferredStyle: .Alert)
                        let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                        errorAlertController.addAction(dismissAlertAction)
                        self.presentViewController(errorAlertController, animated: true, completion: nil)
                        
                        // Save puzzle locally
                        // #Warning
                    } else {
                        print("Succesfully saved to Firebase")
                    }
                })
                
                // Return to camera mode
                self.retakePictureButtonTapped()
            })
            
            tagAlertController.addAction(doneAlertAction)
            presentViewController(tagAlertController, animated: true, completion: nil)
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
    
    override func viewWillDisappear(animated: Bool) {
        if (locationManager != nil && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
            print("stop updating location")
            locationManager!.stopUpdatingLocation()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print("view will appear")
        if (locationManager != nil && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
            print("start updating location")
            locationManager!.startUpdatingLocation()
        }
    }
    
}
