import Foundation
import AVFoundation
import PhotosUI

protocol CameraManDelegate: class {
    func cameraManNotAvailable(_ cameraMan: CameraMan)
    func cameraManDidPhoto(_ photo: AVCapturePhoto)
    func cameraManDidStart(_ cameraMan: CameraMan)
    func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
    func cameraManFaceDetected(_ cameraMan: CameraMan, didOutput metadataObjects: [AVMetadataObject])
}

class CameraMan: NSObject, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate,
AVCaptureMetadataOutputObjectsDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
    
    weak var delegate: CameraManDelegate?
    
    
    let session = AVCaptureSession()
    let queue = DispatchQueue(label: "com.inplaced.ImagePicker.Camera.SessionQueue")
    
    var backCamera: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDeviceInput?
    var stillImageOutput: AVCapturePhotoOutput?
    var startOnFrontCamera: Bool = false
    
    var movieFileOutput : AVCaptureMovieFileOutput?
    var outputURL : URL?
    fileprivate var library: PHPhotoLibrary?
    fileprivate var videoCompletion: ((_ videoURL: URL?, _ error: NSError?) -> Void)?
    //    fileprivate lazy var mic: AVCaptureDevice? = {
    //        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    //    }()
    open var showErrorsToUsers = false
    open var showErrorBlock:(_ erTitle: String, _ erMessage: String) -> Void = { (erTitle: String, erMessage: String) -> Void in
        
        
        //        var alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .Alert)
        //        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in  }))
        //
        //        if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
        //            topController.presentViewController(alertController, animated: true, completion:nil)
        //        }
    }
    
    
    
    deinit {
        stop()
    }
    
    
    
    open func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        session.beginConfiguration()
        session.commitConfiguration()
    }
    
    open func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            _show(NSLocalizedString("Unable to save video to the iPhone", comment:""), message: error.localizedDescription)
            // } else {
            
            //     // we don`t save video to iphone on that stage
            //         if PHPhotoLibrary.authorizationStatus() == .authorized {
            //             //saveVideoToLibrary(outputFileURL)
            //         }
            //         else {
            //             PHPhotoLibrary.requestAuthorization({ (autorizationStatus) in
            //                 if autorizationStatus == .authorized {
            //                     //self.saveVideoToLibrary(outputFileURL)
            //                 }
            //             })
            //         }
            
        }
    }
    
    
    
    
    // MARK: - Setup
    
    func setup(_ startOnFrontCamera: Bool = false) {
        self.startOnFrontCamera = startOnFrontCamera
        checkPermission()
    }
    
    func setupDevices() {
        // Input
        AVCaptureDevice
            .devices().flatMap {
                return $0 as? AVCaptureDevice
                //            }.filter {
                //                return $0.hasMediaType(AVMediaTypeVideo)
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
        stillImageOutput = AVCapturePhotoOutput()
        let settings = AVCapturePhotoSettings()
        settings.livePhotoVideoCodecType = .jpeg
        
        
        movieFileOutput = AVCaptureMovieFileOutput()
        self.session.addOutput(self.movieFileOutput!)
        if library == nil {
            library = PHPhotoLibrary.shared()
        }
        
        //        if let validMic = _deviceInputFromDevice(mic) {
        //            self.addInput(validMic)
        //        }
        
        
        
        
        
        
    }
    
    
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        self.delegate?.cameraManFaceDetected(self, didOutput: metadataObjects)
        
    }
    
    
    
    fileprivate func _deviceInputFromDevice(_ device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let outError {
            _show(NSLocalizedString("Device setup error occured", comment:""), message: "\(outError)")
            return nil
        }
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
        return session.inputs.last as? AVCaptureDeviceInput
    }
    
    fileprivate func start() {
        // Devices
        setupDevices()
        
        guard let input = (self.startOnFrontCamera) ? frontCamera ?? backCamera : backCamera, let output = stillImageOutput else { return }
        
        
        let dims : CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(input.device.activeFormat.formatDescription)
        print("dims \(dims)")
        
        
        addInput(input)
        
        
        for output in self.session.outputs {
            if output is AVCaptureMetadataOutput {
                self.session.removeOutput(output)
            }
        }
        
        
        let metadataOutput = AVCaptureMetadataOutput()
        self.session.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        if metadataOutput.availableMetadataObjectTypes.contains(.face) {
            metadataOutput.metadataObjectTypes = [.face]
        }
        
        
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
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        print("did finish processing photo")
        
//        print("Image captured.")
//            if let imageData = photo.fileDataRepresentation() {
//                if let uiImage = UIImage(data: imageData){
//                    // do stuff to UIImage
//                }
//            }
      
        self.delegate?.cameraManDidPhoto(photo)
        
//        PHPhotoLibrary.requestAuthorization { status in
//                guard status == .authorized else { return }
//
//                PHPhotoLibrary.shared().performChanges({
//                    // Add the captured photo's file data as the main resource for the Photos asset.
//                    let creationRequest = PHAssetCreationRequest.forAsset()
//                    creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
//                }, completionHandler: nil)
//            }
    }
    
    func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: (() -> Void)? = nil) {
        
        guard let connection = stillImageOutput?.connection(with: AVMediaType.video) else { return }
        
        connection.videoOrientation = Helper.videoOrientation()
        
        queue.async {
            
            let settings = AVCapturePhotoSettings()
            self.stillImageOutput?.capturePhoto(with: settings, delegate: self)
            
            //            captureStillImageAsynchronously(from: connection) {
            //                buffer, error in
            //
            //                guard let buffer = buffer, error == nil && CMSampleBufferIsValid(buffer),
            //                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            //                    let image = UIImage(data: imageData)
            //                    else {
            //                        DispatchQueue.main.async {
            //                            completion?()
            //                        }
            //                        return
            //                }
            //
            //                self.savePhoto(image, location: location, completion: completion)
            //            }
        }
    }
    
    //    func takePhotoNotSave(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?,
    //                          completion: (() -> Void)? = nil,  result: @escaping (_ image: UIImage?, _ location: CLLocation?) -> Void) {
    //        guard let connection = stillImageOutput?.connection(with: AVMediaType.video) else { return }
    //
    //        connection.videoOrientation = Helper.videoOrientation()
    //       // var retImage:UIImage? = nil
    //        queue.async {
    //            self.stillImageOutput?.captureStillImageAsynchronously(from: connection) {
    //                buffer, error in
    //
    //                guard let buffer = buffer, error == nil && CMSampleBufferIsValid(buffer),
    //                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
    //                    let image = UIImage(data: imageData)
    //                    else {
    //                        DispatchQueue.main.async {
    //                            completion?()
    //                        }
    //                        return
    //                }
    //                result(image,location)
    //            }
    //        }
    //
    //    }
    
    
    
    //--- video section
    func takeVideo(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: (() -> Void)? = nil) {
        
        
        
        
        self.outputURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + "test.mp4") as URL
        
        
        print("takeVideo")
        queue.async {
            self.movieFileOutput?.startRecording(to: (self.outputURL as URL?)!, recordingDelegate: self)
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //
        //            self.stopTakingVideoAndGenerateThumbnail(location: location, completion: completion)
        //        }
        //
        
        
        
    }
    
    func stopVideo(location: CLLocation?, completion: (() -> Void)? = nil, result: @escaping (_ image: UIImage?, _ location: CLLocation?, _ url: URL?) -> Void) {
        
        
        self.movieFileOutput?.stopRecording()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //            self.savePhoto(self.generateThumnail(url: self.outputURL! as URL, fromTime: 1.0)!, location: location, completion: completion)
            
            // self.saveVideoToLibrary(self.outputURL!)
            self.doNotSaveVideoToLibrary(self.outputURL!)
            
            result(self.generateThumnail(url: self.outputURL! as URL, fromTime: 0.0)!,location, self.outputURL!)
            
            
            
            
        }
        
    }
    
    fileprivate func saveVideoToLibrary(_ fileURL: URL) {
        
        if let validLibrary = self.library {
            
            validLibrary.performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            }, completionHandler: { success, error in
                if (error != nil) {
                    self._show(NSLocalizedString("Unable to save video to the iPhone.", comment:""), message: error!.localizedDescription)
                    self._executeVideoCompletionWithURL(nil, error: error as NSError?)
                } else {
                    self._executeVideoCompletionWithURL(fileURL, error: error as NSError?)
                }
            })
        }
    }
    
    fileprivate func doNotSaveVideoToLibrary(_ fileURL: URL) {
        self._executeVideoCompletionWithURL(fileURL, error: nil)
        
    }
    
    fileprivate func _executeVideoCompletionWithURL(_ url: URL?, error: NSError?) {
        if let validCompletion = videoCompletion {
            validCompletion(url, error)
            videoCompletion = nil
        }
    }
    
    fileprivate func _show(_ title: String, message: String) {
        if showErrorsToUsers {
            DispatchQueue.main.async(execute: { () -> Void in
                self.showErrorBlock(title, message)
            })
        }
    }
    
    
    fileprivate func generateThumnail(url : URL, fromTime:Float64) -> UIImage? {
        let asset :AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore = CMTime.zero;
        //let time        : CMTime = CMTimeMakeWithSeconds(fromTime, 600)
        let time        : CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 1)
        var img: CGImage?
        do {
            img = try assetImgGenerate.copyCGImage(at:time, actualTime: nil)
        } catch {
        }
        if img != nil {
            let frameImg    : UIImage = UIImage(cgImage: img!)
            return frameImg
        } else {
            return nil
        }
    }
    
    
    //--video section
    
    
    
    func savePhoto(_ image: UIImage, location: CLLocation?, completion: (() -> Void)? = nil) {
        //        PHPhotoLibrary.shared().performChanges({
        //            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
        //            request.creationDate = Date()
        //            request.location = location
        //        }, completionHandler: { _ in
        //            DispatchQueue.main.async {
        //                completion?()
        //            }
        //        })
    }
    
    
    
    func flash(_ mode: AVCaptureDevice.FlashMode, _ videoflag: Int) {
        guard let device = currentInput?.device, device.isFlashModeSupported(mode) else { return }
        
        queue.async {
            self.lock {
                device.flashMode = mode
                //device.torchMode = device.isTorchActive ? AVCaptureTorchMode.off : AVCaptureTorchMode.on
            }
        }
    }
    
    func flashOn(_ mode: AVCaptureDevice.FlashMode) {
        guard let device = currentInput?.device, device.isFlashModeSupported(mode) else { return }
        
        queue.async {
            self.lock {
                device.flashMode = mode
                device.torchMode = AVCaptureDevice.TorchMode.on
            }
        }
    }
    
    func flashOff(_ mode: AVCaptureDevice.FlashMode) {
        print("flash off")
        guard let device = currentInput?.device, device.isFlashModeSupported(mode) else { return }
        
        queue.async {
            self.lock {
                device.flashMode = mode
                device.torchMode = AVCaptureDevice.TorchMode.off
            }
        }
    }
    
    
    
    //    func flash(_ mode: AVCaptureFlashMode, _ videoflag: Int) {
    //        guard let device = currentInput?.device, device.isFlashModeSupported(mode) else {
    //            print("device.isFlashModeSupported(mode)" )
    //            return
    //
    //        }
    //
    //        queue.async {
    //            self.lock {
    ////                device.flashMode = mode
    ////                print ("mode1 \(mode.rawValue)")
    ////                print ("device.flashMode \(device.flashMode)")
    //
    //            //    device.torchMode = device.isTorchActive ? AVCaptureTorchMode.off : AVCaptureTorchMode.on
    //
    //
    ////                if (videoflag == 1){
    ////
    //////                    if mode.rawValue == 1 {
    //////                    print ("mode2 \(mode.rawValue)")
    //////                    }
    ////                device.torchMode = device.isTorchActive ? AVCaptureTorchMode.off : AVCaptureTorchMode.on
    ////                //try device.setTorchModeOnWithLevel(_ : 1.0)
    ////                }
    ////                else {
    ////                     device.torchMode = AVCaptureTorchMode.off
    ////                }
    //            }
    //        }
    //    }
    
    
    
    
    
    //    @objc public func focus(_ point: CGPoint) {
    //        if let device = currentInput?.device, device.isFocusPointOfInterestSupported {
    //
    //            if let device = self.currentInput?.device, device.isFocusPointOfInterestSupported {
    //                       do {
    //                           try device.lockForConfiguration()
    //                           device.focusPointOfInterest = point
    //                           device.focusMode = .continuousAutoFocus
    //
    //                        device.exposurePointOfInterest = point
    //                        device.exposureMode = .continuousAutoExposure
    //
    //
    //                           device.unlockForConfiguration()
    //                       } catch let error {
    //                           print("Error while focusing at point \(point): \(error)")
    //                       }
    //                   }
    //        }
    //    }
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    
    func zoom(_ pinch: UIPinchGestureRecognizer) {
        guard let device = currentInput?.device else { return }
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    
    
    func focus(_ point: CGPoint) {
        var focusModeSupported = false;
        //guard
        let device = currentInput?.device
        
        if (device?.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus))! {
            focusModeSupported = true
            
        }
            
        else {
            print("device.isFocusModeSupported" )
            focusModeSupported = false
            //return
        }
        
        queue.async {
            self.lock {
                if (focusModeSupported == true) {
                    print("focusPointOfInterest \(point)" )
                    device?.focusPointOfInterest = point
                    device?.focusMode = .continuousAutoFocus
                    //device.focusMode = AVCaptureFocusMode.autoFocus
                    //device.focusMode = .locked
                    device?.exposurePointOfInterest = point
                    //device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                    device?.exposureMode = .continuousAutoExposure
                }
                else {
                    print("focus mode is not supported")
                    device?.exposurePointOfInterest = point
                    device?.exposureMode = .continuousAutoExposure

                }
//                else {
//                    device?.exposurePointOfInterest = point
//                    //device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
//                    device?.exposureMode = .continuousAutoExposure
//                }
                
            }
        }
    }
    //
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
            if input.device.supportsSessionPreset(AVCaptureSession.Preset(rawValue: asset.rawValue)) && self.session.canSetSessionPreset(asset) {
                self.session.sessionPreset = AVCaptureSession.Preset(rawValue: asset.rawValue)
                return
            }
        }
    }
    
    func preferredPresets() -> [AVCaptureSession.Preset] {
        return [
            
            AVCaptureSession.Preset.high,
            AVCaptureSession.Preset.medium,
            AVCaptureSession.Preset.low
        ]
    }
}
