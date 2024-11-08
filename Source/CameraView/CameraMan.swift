import Foundation
import AVFoundation
import PhotosUI

protocol CameraManDelegate: AnyObject {
    func cameraManNotAvailable(_ cameraMan: CameraMan)
    func cameraManDidStart(_ cameraMan: CameraMan)
    func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
}

class CameraMan:NSObject {
    weak var delegate: CameraManDelegate?
    
    let session = AVCaptureSession()
    let queue = DispatchQueue(label: "no.hyper.ImagePicker.Camera.SessionQueue")
    
    var backCamera: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput!
    var startOnFrontCamera: Bool = false
    let existingImages = [UIImage]()
    var updatedImages = [UIImage]()
    // Define an array to hold the captured images
    var capturedImages: [UIImage] = []
    // Define a completion handler property
    var photoCaptureCompletion: ((UIImage?) -> Void)?
    var photoOutput = AVCapturePhotoOutput()
    
    private let captureOrientation = CaptureOrientation()
    deinit {
        stop()
    }
    
    // MARK: - Setup
    
    func setup(_ startOnFrontCamera: Bool = false) {
        self.startOnFrontCamera = startOnFrontCamera
        checkPermission()
        print("\(Date()) \("💙") \(self).\(#function):\(#line)-CameraMan setup")
    }
    
    func setupDevices() {
      // Input
      AVCaptureDevice
      .devices()
      .filter {
        return $0.hasMediaType(AVMediaType.video)
      }.forEach {
        switch $0.position {
        case .front:
          self.frontCamera = try? AVCaptureDeviceInput(device: $0)
        case .back:
          self.backCamera = try? AVCaptureDeviceInput(device: $0)
        default:
          break
        }
      }

      // Output
      stillImageOutput = AVCaptureStillImageOutput()
      //  let settings = AVCapturePhotoSettings()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
    }
    
    func addInput(_ input: AVCaptureDeviceInput) {
        configurePreset(input)
        
        if session.canAddInput(input) {
            session.addInput(input)
            
            DispatchQueue.main.async {
                self.delegate?.cameraMan(self, didChangeInput: input)
            }
        }
    }
    
    // MARK: - Permission
    
    func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch status {
        case .authorized:
            start()
        case .notDetermined:
            requestPermission()
        default:
            delegate?.cameraManNotAvailable(self)
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.start()
                } else {
                    self.delegate?.cameraManNotAvailable(self)
                }
            }
        }
    }
    
    // MARK: - Session
    
    var currentInput: AVCaptureDeviceInput? {
        return session.inputs.first as? AVCaptureDeviceInput
    }
    
    fileprivate func start() {
        // Devices
        setupDevices()
        print("\(Date()) \("💙") \(self).\(#function):\(#line)-CameraMan start")
        guard let input = (self.startOnFrontCamera) ? frontCamera ?? backCamera : backCamera, let output = stillImageOutput else { return }
        
        addInput(input)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        queue.async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.delegate?.cameraManDidStart(self)
            }
        }
    }
    
    func stop() {
        self.session.stopRunning()
    }
    
    func switchCamera(_ completion: (() -> Void)? = nil) {
        guard let currentInput = currentInput
        else {
            completion?()
            return
        }
        
        queue.async {
            guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera
            else {
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            self.configure {
                self.session.removeInput(currentInput)
                self.addInput(input)
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: @escaping (UIImage?) -> Void) {
        // Directly use `photoOutput` since it’s not optional
        let connection = photoOutput.connection(with: .video)
        guard let connection = connection else {
            completion(nil)
            return
        }

        connection.videoOrientation = previewLayer.connection?.videoOrientation ?? .portrait

        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto // Adjust flash settings if needed

        photoOutput.capturePhoto(with: photoSettings, delegate: self)

        // Store the completion handler to be called in the delegate method
        self.photoCaptureCompletion = completion
    }
    
//    func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: (() -> Void)? = nil) {
//        guard let connection = stillImageOutput?.connection(with: AVMediaType.video) else { return }
//        connection.videoOrientation = captureOrientation.current
//        
//        queue.async {
//            self.stillImageOutput?.captureStillImageAsynchronously(from: connection) { buffer, error in
//                guard let buffer = buffer, error == nil && CMSampleBufferIsValid(buffer),
//                      let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
//                      let image = UIImage(data: imageData)
//                else {
//                    DispatchQueue.main.async {
//                        completion?()
//                    }
//                    return
//                }
//                // Add the captured image to the array
//                self.capturedImages.append(image)
//               // self.savePhotos(self.existingImages, newImage: image, location: nil) { updatedImages in
//                    // Handle the updated array of images
//               //     print(updatedImages)
//               // }
//                // Optionally call the completion handler
//                            DispatchQueue.main.async {
//                                completion?()
//                            }
//               // self.savePhoto(image, location: location, completion: completion)
//            }
//        }
//    }
    
    func savePhotos(_ imagesArray: [UIImage], newImage: UIImage, location: CLLocation?, completion: @escaping ([UIImage]) -> Void) {
        // Process the images or perform any other necessary operations
        // For demonstration purposes, let's assume you just want to append the new image
        var updatedImages = imagesArray

        // Append the new image to the array
        updatedImages.append(newImage)

        // Call the completion handler with the updated array
        completion(updatedImages)
    }

    func savePhoto(_ image: UIImage, location: CLLocation?, completion: (() -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.creationDate = Date()
            request.location = location
        }, completionHandler: { (_, _) in
            DispatchQueue.main.async {
                completion?()
            }
        })
    }
    
    func flash(_ mode: AVCaptureDevice.FlashMode) {
        guard let device = currentInput?.device, device.isFlashModeSupported(mode) else { return }
        
        queue.async {
            self.lock {
                device.flashMode = mode
            }
        }
    }
    
    func focus(_ point: CGPoint) {
        guard let device = currentInput?.device, device.isFocusModeSupported(AVCaptureDevice.FocusMode.locked) else { return }
        
        queue.async {
            self.lock {
                device.focusPointOfInterest = point
            }
        }
    }
    
    func zoom(_ zoomFactor: CGFloat) {
        guard let device = currentInput?.device, device.position == .back else { return }
        
        queue.async {
            self.lock {
                device.videoZoomFactor = zoomFactor
            }
        }
    }
    
    // MARK: - Lock
    
    func lock(_ block: () -> Void) {
        if let device = currentInput?.device, (try? device.lockForConfiguration()) != nil {
            block()
            device.unlockForConfiguration()
        }
    }
    
    // MARK: - Configure
    func configure(_ block: () -> Void) {
        session.beginConfiguration()
        block()
        session.commitConfiguration()
    }
    
    // MARK: - Preset
    
    func configurePreset(_ input: AVCaptureDeviceInput) {
        for asset in preferredPresets() {
            if input.device.supportsSessionPreset(AVCaptureSession.Preset(rawValue: asset)) && self.session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: asset)) {
                self.session.sessionPreset = AVCaptureSession.Preset(rawValue: asset)
                return
            }
        }
    }
    
    func preferredPresets() -> [String] {
        return [
            AVCaptureSession.Preset.high.rawValue,
            AVCaptureSession.Preset.high.rawValue,
            AVCaptureSession.Preset.low.rawValue
        ]
    }
}
// Conform to AVCapturePhotoCaptureDelegate
extension CameraMan: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            // Call the completion with nil if there’s an error
            photoCaptureCompletion?(nil)
            photoCaptureCompletion = nil
            return
        }

        // Call the completion with the captured image
        photoCaptureCompletion?(image)
        photoCaptureCompletion = nil
    }
}
