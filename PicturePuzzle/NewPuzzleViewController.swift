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
    var pictureData : Data?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCameraFunction()
        setupLocationServices()
    }
    
    func setupCameraFunction() {
        // Use Photo Button
        let width : CGFloat = 100.0
        let height : CGFloat = 30.0
        usePhotoButton = UIButton(type: .system)
        usePhotoButton.setTitle("Use Photo", for: UIControlState())
        usePhotoButton.frame = CGRect(
            x: view.frame.maxX - width - 8,
            y: view.frame.maxY - height - 78.0,
            width: width,
            height: height
        )
        usePhotoButton.addTarget(self, action: #selector(usePhotoButtonTapped), for: .touchUpInside)
        view.addSubview(usePhotoButton)
        
        // Retake Picture Button
        retakePictureButton = UIButton(type: .system)
        retakePictureButton.setTitle("Retake", for: UIControlState())
        retakePictureButton.frame = CGRect(
            x: view.frame.minX + 8,
            y: view.frame.maxY - height - 78,
            width: width,
            height: height
        )
        retakePictureButton.addTarget(self, action: #selector(retakePictureButtonTapped), for: .touchUpInside)
        view.addSubview(retakePictureButton)
        
        // Capture Photo Button
        capturePhotoButton = UIButton(type: .custom)
        let length : CGFloat = 70.0
        capturePhotoButton.frame = CGRect(
            x: view.frame.midX - length/2.0,
            y: view.frame.maxY - length - 70.0,
            width: length,
            height: length
        )
        capturePhotoButton.layer.cornerRadius = capturePhotoButton.frame.width/2.0
        capturePhotoButton.backgroundColor = UIColor.black
        capturePhotoButton.addTarget(self, action: #selector(capturePhotoButtonTapped), for: .touchUpInside)
        view.addSubview(capturePhotoButton)
        view.bringSubview(toFront: capturePhotoButton)
        
        // Location Accuracy Label
        locationAccuracyLabel = UILabel()
        locationAccuracyLabel.textAlignment = .center
        locationAccuracyLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
        locationAccuracyLabel.center = CGPoint(x: view.frame.midX, y: capturePhotoButton.frame.minY - 8)
        view.addSubview(locationAccuracyLabel)
        
        // Set up captured image view
        capturedImageView.frame = CGRect(x: 0, y: 80, width: view.bounds.width, height: view.bounds.width)
        view.addSubview(capturedImageView)
        
        // Hide Captured Image View
        capturedImageView.isHidden = true
        usePhotoButton.isHidden = true     // Hide until picture is taken
        retakePictureButton.isHidden = true
        locationAccuracyLabel.isHidden = true
        
        // Set up Capture Session
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Set up input device
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
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
        print("Authorization status: \(authorizationStatus)")
        if (authorizationStatus == .restricted) {
            
            // Show Error Alert
            let errorAlertController = UIAlertController(
                title: "Location Authorization Restricted",
                message: "This app will be unable to verify the correctness of puzzles without enabled location services.",
                preferredStyle: .alert
            )
            let dismissAlertAction = UIAlertAction(
                title: "Dismiss",
                style: .default,
                handler: nil
            )
            errorAlertController.addAction(dismissAlertAction)
            
        } else if (authorizationStatus == .denied) {
            
            // Show Error Alert
            let errorAlertController = UIAlertController(
                title: "Location Authorisation Denied",
                message: "This app will be unable to verify the correctness of puzzles without enabled location services.",
                preferredStyle: .alert
            )
            let dismissAlertAction = UIAlertAction(
                title: "Dismiss",
                style: .default,
                handler: nil
            )
            errorAlertController.addAction(dismissAlertAction)
            
        } else {
            
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.distanceFilter = 0.5
            
            if (authorizationStatus == .notDetermined) {
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
        let contextImage: UIImage = UIImage(cgImage: originalImage.cgImage!)
        
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
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error: \(error.localizedDescription)")
        
        // Show Error Alert
        let errorAlertController = UIAlertController(
            title: "Location Services Error",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert
        )
        let dismissAlertAction = UIAlertAction(
            title: "Dismiss",
            style: .default,
            handler: nil
        )
        errorAlertController.addAction(dismissAlertAction)
        
        present(errorAlertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedWhenInUse) {
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("Did finish deferring updates with error: \(String(describing: error?.localizedDescription))")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("did pause location updates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Did resume location updates")
    }
    
    
    // MARK: - Actions
    func capturePhotoButtonTapped() {
        // Set up data connection to capture photo
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            
            stillImageOutput!.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProvider(data: imageData! as CFData)
                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                
                let contextImage = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
                
                // Crop image to a square
                let croppedImage = self.cropToSquare(image: contextImage)
                
                self.capturedImageView.image = croppedImage
                
                // Save image data
                self.pictureData = UIImageJPEGRepresentation(croppedImage, 1.0)
                
                // Show capturedImageView and buttons
                self.capturedImageView.isHidden = false
                self.usePhotoButton.isHidden = false
                self.retakePictureButton.isHidden = false
                self.locationAccuracyLabel.isHidden = false
                
                // Hide previewLayer
                self.previewLayer!.isHidden = true
                self.capturePhotoButton.isHidden = true
                
                print("number of bytes: \((self.pictureData! as NSData).bytes)")
                //                print("description: \(self.pictureData!.description)")
            })
        }
        
        // Capture the location
        pictureLocation = locationManager!.location
        if pictureLocation != nil {
            self.locationAccuracyLabel.text = "Accuracy: \(pictureLocation!.horizontalAccuracy)m"
            print("\n\nPicture Location: \(String(describing: pictureLocation))")
            print("\tCoordinate: \(pictureLocation!.coordinate)")
            print("\tFloor: \(String(describing: pictureLocation!.floor))")
            print("\tHorizontal accuracy: \(pictureLocation!.horizontalAccuracy) (meters)")
            print("\tVertical accuracy: \(pictureLocation!.verticalAccuracy) (meters)")
        } else {
            print("ERROR: location nil")
        }
    }
    
    func retakePictureButtonTapped() {
        
        // Show previewLayer
        previewLayer!.isHidden = false
        capturePhotoButton.isHidden = false
        
        // Hide capturedImageView and buttons
        capturedImageView.isHidden = true
        capturedImageView.image = nil
        
        usePhotoButton.isHidden = true
        retakePictureButton.isHidden = true
        locationAccuracyLabel.isHidden = true
    }
    
    func usePhotoButtonTapped() {
        
        if (pictureLocation == nil) {
            // Alert location error
            print("Error creating puzzle - location")
            let errorAlertController = UIAlertController(title: "Error Creating Puzzle", message: "There was an error with the location data creating your puzzle.", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            present(errorAlertController, animated: true, completion: nil)
            
        } else if (pictureData == nil) {
            // Alert image error
            print("Error creatinng puzzle - picture data")
            let errorAlertController = UIAlertController(title: "Error Creating Puzzle", message: "There was an error with the image data creating your puzzle.", preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlertController.addAction(dismissAlertAction)
            present(errorAlertController, animated: true, completion: nil)
            
        } else {
            // Create Puzzle Object
            var tagText = ""
            
            print("Ask for tag")
            
            // Ask user for tag
            let tagAlertController = UIAlertController(title: "Add Tag", message: "Please enter a tag for your puzzle. For example, Cornell University.", preferredStyle: .alert)
            tagAlertController.addTextField(configurationHandler: {(textField) in
                
                textField.placeholder = "Tag"
                
            })
            let doneAlertAction = UIAlertAction(title: "Done", style: .default, handler: {(action) in
                
                let tagField = tagAlertController.textFields!.first!
                if (tagField.text != nil) {
                    tagText = tagField.text!
                }
                
                // Create Puzzle Object
                let newPuzzle = Puzzle(
                    withPictureData: self.pictureData!,
                    latitude: self.pictureLocation!.coordinate.latitude,
                    longitude: self.pictureLocation!.coordinate.longitude,
                    horizontalAccuracy: self.pictureLocation!.horizontalAccuracy,
                    tag: tagText
                )
                
                // Save puzzle
                let firebaseRef = Database.database().reference()
//                let firebaseReference = Firebase(url: "https://picturepuzzle-709d1.firebaseio.com/")
                
                let puzzlesRef = firebaseRef.child("puzzles");
//                let puzzlesRef = firebaseReference?.child(byAppendingPath: "puzzles")
                let newPuzzleRef = puzzlesRef.childByAutoId()
                newPuzzleRef.setValue(newPuzzle.convertToFirebaseData(), withCompletionBlock: {(error, firebaseRef) in
                    
                    if (error != nil) {
                        print("Error saving to firebase: \(error!.localizedDescription)")
                        
                        // Alert User of error
                        let errorAlertController = UIAlertController(title: "Error Creating Puzzle", message: "There was an error with the database creating your puzzle.", preferredStyle: .alert)
                        let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                        errorAlertController.addAction(dismissAlertAction)
                        self.present(errorAlertController, animated: true, completion: nil)
                        
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
            present(tagAlertController, animated: true, completion: nil)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if (locationManager != nil && CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            print("stop updating location")
            locationManager!.stopUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        if (locationManager != nil && CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            print("start updating location")
            locationManager!.startUpdatingLocation()
        }
    }
    
}
