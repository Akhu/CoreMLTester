import Foundation
import AVFoundation
import UIKit

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage, pixelBuffer: CVPixelBuffer)
    func previewLayer(previewLayer: AVCaptureVideoPreviewLayer)
}

class FrameExtractor : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var delegate: FrameExtractorDelegate?
    
    private let context = CIContext()
    
    //Access Camera
    
    public var previewLayer:AVCaptureVideoPreviewLayer?
    
    //Custom access to any camera
    
    private let position = AVCaptureDevice.Position.back
    
    public let quality = AVCaptureSession.Preset.hd1280x720
    
    private let devicesType = [AVCaptureDevice.DeviceType.builtInWideAngleCamera]
    
    //Return every frame captured
    
    private let captureSession = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "capture session queue")
    
    private var permissionGranted = false
    
    override init() {
        
        super.init()
        self.checkPermission()
        
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
            if let currentDelegate = self.delegate, let preview = self.previewLayer  {
                currentDelegate.previewLayer(previewLayer: preview)
            }
        }
    }
    
    private func configureSession(){
        guard permissionGranted else { return }
        
        captureSession.sessionPreset = quality
        
        //Getting our devices
        
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let extractorResult = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            guard let currentDelegate = self.delegate else { return }
            
            currentDelegate.captured(image: extractorResult.0,pixelBuffer:  extractorResult.1 )
        }
    }
    
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> (UIImage, CVPixelBuffer)? {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        guard let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return (UIImage(cgImage: cgImage), imageBuffer)
        
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: self.devicesType, mediaType: AVMediaType.video, position: self.position)
            
            return discoverySession.devices.first
            
        } else {
            // Fallback on earlier versions
        }
        
        return nil
    }
    
    // MARK: AVSession configuration
    
    public func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            
        case .authorized:
            // The user has explicitly granted permission for media capture
            permissionGranted = true
            break
            
        case .notDetermined:
            // The user has not yet granted or denied permission
            self.requestPermission()
            break
            
        case .restricted:
            // The user is not allowed to access media capture devices
            permissionGranted = false
            break
            
        case .denied:
            // The user has explicitly denied permission for media capture
            permissionGranted = false
            break
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        })
        
    }
}

