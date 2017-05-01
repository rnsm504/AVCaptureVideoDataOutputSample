//
//  ViewController.swift
//  AVCaptureVideoDataOutputSample
//
//  Created by msnr on 2017/04/30.
//  Copyright © 2017年 msnr. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    var session : AVCaptureSession!
    
    var imageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
    }
    
    func initCamera() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(self.imageView)
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        let camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        
        var inputDevice : AVCaptureDeviceInput!
        do {
            inputDevice = try AVCaptureDeviceInput(device: camera)
        } catch let error as NSError {
            print(error)
        }
        
        if(session.canAddInput(inputDevice)){
            session.addInput(inputDevice)
        }
        
        let output = AVCaptureVideoDataOutput()
        if(session.canAddOutput(output)){
            session.addOutput(output)
        }
        
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        output.alwaysDiscardsLateVideoFrames = true
        
        session.startRunning()
        
        do {
            try camera?.lockForConfiguration()
            camera?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            camera?.unlockForConfiguration()
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    
    //MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer!).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        let outputImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        
        
        connection.videoOrientation = .portrait
        
        
        DispatchQueue.main.async {
            self.imageView.image = UIImage(ciImage: outputImage)
        }
        
    }
    

}

