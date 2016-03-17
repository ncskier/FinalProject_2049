//
//  CameraViewController.swift
//  FinalProject2049
//
//  Created by Brandon Walker on 3/17/16.
//  Copyright © 2016 Brandon Walker. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var livePreviewView: UIView!
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCameraFunction()
        setupLocationServices()
    }
    
    func setupLocationServices() {
        
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
    
    
    // MARK: - Actions
    
    @IBAction func capturePhotoButtonTapped(sender: UIButton) {
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
        
        
        // Hide livePreviewLayer
        livePreviewView.hidden = true
        
        // Show capturedImageView
        capturedImageView.hidden = false
        
    }

    @IBAction func retakePictureButtonTapped(sender: UIButton) {
        
        // Hide capturedImageView
        capturedImageView.hidden = true
        capturedImageView.image = nil
        
        // Show livePreviewLayer
        livePreviewView.hidden = false
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
