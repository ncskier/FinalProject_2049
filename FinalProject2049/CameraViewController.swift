//
//  CameraViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/17/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class CameraViewController: UIViewController, CLLocationManagerDelegate {
    
    // Photo Buttons
    var usePhotoButton : UIButton!
    var retakePictureButton : UIButton!
    var capturePhotoButton : UIButton!
    
    // Image processing
    var capturedImageView = UIImageView()
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // Location processing
    var locationManager : CLLocationManager?
    var pictureLocation : CLLocation?
    
    
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
        usePhotoButton.addTarget(self, action: "usePhotoButtonTapped", forControlEvents: .TouchUpInside)
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
        retakePictureButton.addTarget(self, action: "retakePictureButtonTapped", forControlEvents: .TouchUpInside)
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
        capturePhotoButton.addTarget(self, action: "capturePhotoButtonTapped", forControlEvents: .TouchUpInside)
        view.addSubview(capturePhotoButton)
        view.bringSubviewToFront(capturePhotoButton)
        
        // Set up captured image view
        capturedImageView.frame = CGRect(x: 0, y: 80, width: view.bounds.width, height: view.bounds.width)
        view.addSubview(capturedImageView)
        
        // Hide Captured Image View
        capturedImageView.hidden = true
        usePhotoButton.hidden = true     // Hide until picture is taken
        retakePictureButton.hidden = true
        
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
        print("capturePhotobutton: \(capturePhotoButton)")
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        let currentLocation = locations.last!
        
//        print("\ncurrent location: \(currentLocation)")
//        print("\tCoordinate: \(currentLocation.coordinate)")
//        print("\tFloor: \(currentLocation.floor)")
//        print("\tHorizontal accuracy: \(currentLocation.horizontalAccuracy) (meters)")
//        print("\tVertical accuracy: \(currentLocation.verticalAccuracy) (meters)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if (status == .AuthorizedWhenInUse) {
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print("Did finish deferring updates with error: \(error!.description)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("Did update heading: \(newHeading)")
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        print("did pause location updates")
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        print("Did resume location updates")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("did update to location: \(newLocation)")
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
                
                // Show capturedImageView and buttons
                self.capturedImageView.hidden = false
                self.usePhotoButton.hidden = false
                self.retakePictureButton.hidden = false
                
                // Hide previewLayer
                self.previewLayer!.hidden = true
                self.capturePhotoButton.hidden = true
            })
        }
        
        // Capture the location
        pictureLocation = locationManager!.location
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
    }
    
    func usePhotoButtonTapped() {
        
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
