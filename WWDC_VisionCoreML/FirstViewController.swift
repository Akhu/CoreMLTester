//
//  FirstViewController.swift
//  WWDC_VisionCoreML
//
//  Created by Anthony Da Cruz on 08/06/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit
import CoreImage
import CoreML
import Vision

class FirstViewController: UIViewController {
    
    
    @IBOutlet weak var image: UIImageView!
    
    var imageToProcess:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.imageToProcess = UIImage(named: "ticket")
        self.image.image = self.imageToProcess
        
        guard let cgImage = self.imageToProcess.cgImage else { return }
        
//        do {
//            let model = try VNCoreMLModel(for: isReceipt().model)
//            let model2 = try VNCoreMLModel(for: GoogLeNetPlaces().model)
//
//            let request = VNCoreMLRequest(model: model, completionHandler: self.resultHandlerMethod)
//            let request2 = VNCoreMLRequest(model: model2, completionHandler: self.resultHandlerMethod)
//
//            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//
//            try handler.perform([request,request2])
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
    }
    
    func resultHandlerMethod(request: VNRequest, error: Error?) {
        print(request.results)
        if let results = request.results as? [VNClassificationObservation] {
                for classification in results {
                    if (classification.confidence * 100) > 20 {
                        print(classification.identifier)
                        print(classification.confidence * 100)
                    }
                    
                }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

