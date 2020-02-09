//
//  ViewController.swift
//  ObjectDetectionWithCoreML
//
//  Created by Tolga İskender on 9.02.2020.
//  Copyright © 2020 Tolga İskender. All rights reserved.
//

import UIKit
import AVKit
import Vision
class ViewController: UIViewController {
    
    @IBOutlet weak var outPutLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingUpCamera()
    }
    
    func settingUpCamera(){
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input  = try? AVCaptureDeviceInput(device: device) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer =  AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    
}
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            
            guard let result = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let firstObs = result.first else { return }
            DispatchQueue.main.async {
                self.outPutLabel.text = "\(firstObs.identifier) \(firstObs.confidence * 100)%"
            }
            
            
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
    
}

