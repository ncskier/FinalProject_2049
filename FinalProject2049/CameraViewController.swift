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

    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var livePreviewView: UIView!
    
    // Image processing
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
    
    func setupCameraFunction() {
        // Hide Captured Image View
        capturedImageView.hidden = true
        
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
        previewLayer!.frame = livePreviewView.bounds
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        livePreviewView.layer.addSublayer(previewLayer!)
        
        // Start session
        captureSession!.startRunning()
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
        
        let currentLocation = locations.last!
        
        print("\ncurrent location: \(currentLocation)")
        print("\tCoordinate: \(currentLocation.coordinate)")
        print("\tFloor: \(currentLocation.floor)")
        print("\tHorizontal accuracy: \(currentLocation.horizontalAccuracy) (meters)")
        print("\tVertical accuracy: \(currentLocation.verticalAccuracy) (meters)")
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
    
    @IBAction func capturePhotoButtonTapped(sender: UIButton) {
        // Capture the location
        pictureLocation = locationManager!.location
        print("\n\nPicture Location: \(pictureLocation)")
        print("\tCoordinate: \(pictureLocation!.coordinate)")
        print("\tFloor: \(pictureLocation!.floor)")
        print("\tHorizontal accuracy: \(pictureLocation!.horizontalAccuracy) (meters)")
        print("\tVertical accuracy: \(pictureLocation!.verticalAccuracy) (meters)")
        
        // Set up data connection to capture photo
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            
            stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                
                let contextImage = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: .Right)
                
                // Crop image to livePreviewView Size
                let croppedImage = self.cropToSquare(image: contextImage)
                
                self.capturedImageView.image = croppedImage
            })
        }
        
        // Show capturedImageView
        capturedImageView.hidden = false
        
        // Hide livePreviewLayer
        livePreviewView.hidden = true
    }

    @IBAction func retakePictureButtonTapped(sender: UIButton) {
        
        // Show livePreviewLayer
        livePreviewView.hidden = false
        
        // Hide capturedImageView
        capturedImageView.hidden = true
        capturedImageView.image = nil
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
