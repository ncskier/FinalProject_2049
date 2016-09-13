//
//  SolvePuzzleViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/19/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import RealmSwift
import Firebase

class SolvePuzzleViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var solvedLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    
    // Puzzle Elements
    var puzzle : Puzzle!
    var previewPuzzleView : UIImageView!
    var originalPreviewFrame : CGRect!
    var previewPuzzleEnlarged = false
    
    // Photo Buttons
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
        
        // Visuals
        solvedLabel.isHidden = true
        incorrectLabel.isHidden = true
        
        // Preview Puzzle View
        let previewLength = view.frame.width/4.0
        previewPuzzleView = UIImageView(image: UIImage(data: puzzle.pictureData as Data))
        previewPuzzleView.frame = CGRect(
            x: view.frame.maxX - previewLength - 8,
            y: view.frame.maxY - previewLength - 8,
            width: previewLength,
            height: previewLength
        )
        originalPreviewFrame = previewPuzzleView.frame
        view.addSubview(previewPuzzleView)
        
        setupCameraFunction()
        setupLocationServices()
    }
    
    func setupCameraFunction() {
        // Retake Picture Button
        let width : CGFloat = 100.0
        let height : CGFloat = 30.0
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
        
        // Set up captured image view
        capturedImageView.frame = CGRect(x: 0, y: 80, width: view.bounds.width, height: view.bounds.width)
        view.addSubview(capturedImageView)
        
        // Hide Captured Image View
        capturedImageView.isHidden = true
        retakePictureButton.isHidden = true
        
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
        print("capturePhotobutton: \(capturePhotoButton)")
    }
    
    func setupLocationServices() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
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
    
    
//    func incrementRealmPuzzleUsersCorrectBy() {
//        do {
//            let realm = try Realm()
//            
//            try realm.write({
//                puzzle.usersCorrect += 1
//            })
//        }
//        catch {
//            print("error updating puzzle users correct: \(error)")
//            
//            let errorAlertController = UIAlertController(title: "Error Updating Puzzle Users Correct", message: "\(error)", preferredStyle: .Alert)
//            let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
//            errorAlertController.addAction(dismissAlertAction)
//            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(errorAlertController, animated: true, completion: nil)
//        }
//    }
    
    func updatePuzzleFirebasePuzzleUsersCorrect() {
        let firebaseReference = Firebase(url: "https://shining-heat-3670.firebaseio.com/")
        let puzzlesReferece = firebaseReference?.child(byAppendingPath: "puzzles")
        let puzzleReference = puzzlesReferece?.child(byAppendingPath: puzzle.id)
        let puzzleUsersCorrectReference = puzzleReference?.child(byAppendingPath: "usersCorrect")
        puzzleUsersCorrectReference?.setValue(puzzle.usersCorrect, withCompletionBlock: {(error, firebaseRef) in
            
            if (error != nil) {
                print("Error updating users correct to firebase: \(error)")
                
                // Alert User of error
                let errorAlertController = UIAlertController(title: "Error Updating Puzzle Users Correct", message: "\(error)", preferredStyle: .alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(errorAlertController, animated: true, completion: nil)
            } else {
                print("Succesfully saved votes to Firebase")
            }
        })
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
    
    // Lay preview puzzle view over camera preview
    func enlargePreviewPuzzleView() {
        view.bringSubview(toFront: previewPuzzleView)
        previewPuzzleEnlarged = true
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.15)
        previewPuzzleView.frame = capturedImageView.frame
        previewPuzzleView.alpha = 0.85
        UIView.commitAnimations()
    }
    
    func delargePreviewPuzzleView() {
        previewPuzzleEnlarged = false
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.15)
        previewPuzzleView.frame = originalPreviewFrame
        previewPuzzleView.alpha = 1.0
        UIView.commitAnimations()
    }
    
    // MARK: - Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handlePreviewPuzzleTouch(touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handlePreviewPuzzleTouch(touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handlePreviewPuzzleEndTouch()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        handlePreviewPuzzleEndTouch()
    }
    
    func handlePreviewPuzzleEndTouch() {
        if (previewPuzzleEnlarged) {
            delargePreviewPuzzleView()
        }
    }
    
    func handlePreviewPuzzleTouch(_ touch: UITouch) {
        if (!previewPuzzleEnlarged) {       // Only check if preview puzzle is NOT enlarged
            let location = touch.location(in: view)
            if (previewPuzzleView.frame.contains(location)) {
                enlargePreviewPuzzleView()
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error: \(error.description)")
        
        // Show Error Alert
        let errorAlertController = UIAlertController(
            title: "Location Services Error",
            message: "\(error.description)",
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //        let currentLocation = locations.last!
        
        //        print("\ncurrent location: \(currentLocation)")
        //        print("\tCoordinate: \(currentLocation.coordinate)")
        //        print("\tFloor: \(currentLocation.floor)")
        //        print("\tHorizontal accuracy: \(currentLocation.horizontalAccuracy) (meters)")
        //        print("\tVertical accuracy: \(currentLocation.verticalAccuracy) (meters)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedWhenInUse) {
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("Did finish deferring updates with error: \(error!.description)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("Did update heading: \(newHeading)")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("did pause location updates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Did resume location updates")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("did update to location: \(newLocation)")
    }
    
    
    
    
    // MARK: - Actions
    func capturePhotoButtonTapped() {
//        // Delarge Preview Puzzle
//        if (previewPuzzleEnlarged) {
//            delargePreviewPuzzleView()
//        }
        
        // Set up data connection to capture photo
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            
            stillImageOutput!.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProvider(data: imageData as! CFData)
                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                
                let contextImage = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
                
                // Crop image to a square
                let croppedImage = self.cropToSquare(image: contextImage)
                
                self.capturedImageView.image = croppedImage
                
                // Show capturedImageView and buttons
                self.capturedImageView.isHidden = false
                self.retakePictureButton.isHidden = false
                
                // Hide previewLayer
                self.previewLayer!.isHidden = true
                self.capturePhotoButton.isHidden = true
            })
        }
        
        // Capture the location
        pictureLocation = locationManager!.location
        print("\n\nPicture Location: \(pictureLocation)")
        print("\tCoordinate: \(pictureLocation!.coordinate)")
        print("\tFloor: \(pictureLocation!.floor)")
        print("\tHorizontal accuracy: \(pictureLocation!.horizontalAccuracy) (meters)")
        print("\tVertical accuracy: \(pictureLocation!.verticalAccuracy) (meters)")
        
        // Check if puzzle solved
        let puzzleLocation = CLLocation(latitude: puzzle.latitude, longitude: puzzle.longitude)
        var worstAccuracy = puzzle.horizontalAccuracy
        if (pictureLocation!.horizontalAccuracy > worstAccuracy) {
            worstAccuracy = pictureLocation!.horizontalAccuracy
        }
        if (pictureLocation!.distance(from: puzzleLocation) < worstAccuracy) {    // Puzzle Solved
            solvedLabel.isHidden = false
            incorrectLabel.isHidden = true
            
            // Update User Defaults
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: puzzle.id + ".solved")
            defaults.synchronize()
            
            // Update Users Correct
//            incrementRealmPuzzleUsersCorrectBy()
            do {
                let realm = try Realm()
                
                try realm.write({
                    puzzle.usersCorrect += 1
                })
            }
            catch {
                print("error updating puzzle votes: \(error)")
                
                let errorAlertController = UIAlertController(title: "Error Updating Puzzle Votes", message: "\(error)", preferredStyle: .alert)
                let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                errorAlertController.addAction(dismissAlertAction)
                present(errorAlertController, animated: true, completion: nil)
            }
            updatePuzzleFirebasePuzzleUsersCorrect()
            
            // Dismiss View (Go Back to Detail View)
            dismiss(animated: true, completion: nil)
            
        } else {    // Puzzle Incorrect
            incorrectLabel.isHidden = false
            solvedLabel.isHidden = true
            
            
        }
        
        // Show Accuracy - DEBUGGING
//        let locationAlertController = UIAlertController(
//            title: "Location Information",
//            message: "Distance from puzzle: \(pictureLocation!.distanceFromLocation(puzzleLocation))m\nPuzzle Horizontal Accuracy: \(puzzle.horizontalAccuracy)m\nSolution Horozontal Accuracy: \(pictureLocation!.horizontalAccuracy)m",
//            preferredStyle: .Alert
//        )
//        let dismissAlertAction = UIAlertAction(
//            title: "Dismiss",
//            style: .Default,
//            handler: nil
//        )
//        locationAlertController.addAction(dismissAlertAction)
//        presentViewController(locationAlertController, animated: true, completion: nil)
        
        print("Distance from puzzle: \(pictureLocation!.distance(from: puzzleLocation))")
        print("Puzzle Horizontal Accuracy: \(puzzle.horizontalAccuracy)")
        print("Solution Horozontal Accuracy: \(pictureLocation!.horizontalAccuracy)")
    }
    
    func retakePictureButtonTapped() {
        
        // Show previewLayer
        previewLayer!.isHidden = false
        capturePhotoButton.isHidden = false
        
        // Hide capturedImageView and buttons
        capturedImageView.isHidden = true
        capturedImageView.image = nil
        incorrectLabel.isHidden = true
        solvedLabel.isHidden = true
        
        retakePictureButton.isHidden = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
            locationManager!.stopUpdatingLocation()
        }
    }
}
