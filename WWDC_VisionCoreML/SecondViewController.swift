//
//  SecondViewController.swift
//  WWDC_VisionCoreML
//
//  Created by Anthony Da Cruz on 08/06/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//
import UIKit
import CoreML
import Vision
import AVFoundation

class SecondViewController: UIViewController, FrameExtractorDelegate {
    func previewLayer(previewLayer: AVCaptureVideoPreviewLayer) {
        DispatchQueue.main.async {
            self.previewLayer = previewLayer
            self.previewLayer!.frame = self.previewView.bounds
            print(self.previewLayer!.debugDescription)
            self.previewLayer!.videoGravity = .resizeAspectFill
            self.previewView.layer.addSublayer(self.previewLayer!)
            if self.previewLayer!.connection!.isVideoOrientationSupported {
                self.previewLayer!.connection!.videoOrientation = .portrait
            }
            //self.image.layer.addSublayer(previewLayer)
        }
    }
    
    func captured(image: UIImage, pixelBuffer: CVPixelBuffer) {
        //self.image.image = image
        queue.async {
            self.launchDetection(withImage: pixelBuffer)
        }
        
    }
    @IBOutlet weak var confidenceLabel: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    let queue = DispatchQueue(label: "coreML")
    
    @IBOutlet weak var labelDescription: UILabel!
    
    var frameExtractor:FrameExtractor!
    
    var previewLayer:AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.frameExtractor = FrameExtractor()
        self.frameExtractor.delegate = self
        //guard let previewLayer = self.frameExtractor.previewLayer else { return }
        //self.image.layer.addSublayer(previewLayer)
    }
    
    func launchDetection(withImage imageToProcess: CVPixelBuffer) {
        
        do {
            let model = try VNCoreMLModel(for: VGG16().model)
//            let model2 = try VNCoreMLModel(for: GoogLeNetPlaces().model)
//            let model3 = try VNCoreMLModel(for: Inceptionv3().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: self.resultHandlerMethod)
//            let request2 = VNCoreMLRequest(model: model2, completionHandler: self.resultHandlerMethod)
//            let request3 = VNCoreMLRequest(model: model3, completionHandler: self.resultHandlerMethod)
            
            
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            
            
            let handler = VNImageRequestHandler(cvPixelBuffer: imageToProcess, options: [:])
            
            try handler.perform([request])
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func resultHandlerMethod(request: VNRequest, error: Error?) {
        //print(request.results)
        if let results = request.results as? [VNClassificationObservation] {
            if let maxConfidence = results.max(by: { a, b in a.confidence < b.confidence }) {
                DispatchQueue.main.async {
                    self.confidenceLabel.text = String(describing: maxConfidence.confidence)
                    self.labelDescription.text = maxConfidence.identifier
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

