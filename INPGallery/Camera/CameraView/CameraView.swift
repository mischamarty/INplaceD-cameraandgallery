import UIKit
import AVFoundation
import PhotosUI

protocol CameraViewDelegate: class {
    
    func setFlashButtonHidden(_ hidden: Bool)
    func imageToLibrary(_ img: UIImage?, _ location: CLLocation?, _ isVideo: URL?)
    func cameraNotAvailable()
    func cameraManDidPhoto(_ photo: AVCapturePhoto)

}

class CameraView: UIViewController, CLLocationManagerDelegate, CameraManDelegate {
    
    var photoModeOnly = false
    
    func cameraManDidPhoto(_ photo: AVCapturePhoto) {
        self.delegate?.cameraManDidPhoto(photo)
    }
    
    lazy var blurView: UIVisualEffectView = { [unowned self] in
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        
        return blurView
        }()
    
//    lazy var focusImageView: UIImageView = { [unowned self] in
//        let imageView = UIImageView()
//        imageView.image = AssetManager.getImage("focusIcon")
//        //imageView.image = AssetManager.getImage("focus3")
//        imageView.backgroundColor = UIColor.clear
//        imageView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
//        imageView.alpha = 0
//
//        return imageView
//        }()
    
    let focusImageView = FocusSquare()
//        = { [unowned self] in
//           let imageView = UIView()
//           imageView.backgroundColor = UIColor.clear
//           imageView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
//           imageView.layer.borderColor = UIColor.yellow.cgColor
//           imageView.layer.borderWidth = 2
//           imageView.layer.cornerRadius = 15
//           imageView.alpha = 0
//
//        drawLine(startx: imageView.frame.width/2, starty: 0, endx: imageView.frame.width/2, endy: 10, lineWidth: 2, color: UIColor.yellow)
//
//           return imageView
//           }()
//
//    override func drawRect(startx: CGFloat, starty: CGFloat, endx: CGFloat, endy: CGFloat, lineWidth: CGFloat, color: UIColor) {
//        let aPath = UIBezierPath()
//        aPath.move(to: CGPoint(x:startx, y:starty))
//        aPath.addLine(to: CGPoint(x: endx, y: endy))
//        aPath.close()
//        color.set()
//        aPath.lineWidth = lineWidth
//        aPath.stroke()
//    }
    
    lazy var capturedImageView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.alpha = 0
        
        return view
        }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.alpha = 0
        
        return view
    }()
    
    lazy var noCameraLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = Configuration.noCameraFont
        label.textColor = Configuration.noCameraColor
        label.text = Configuration.noCameraTitle
        label.sizeToFit()
        
        return label
        }()
    
    lazy var noCameraButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: Configuration.settingsTitle,
                                       attributes: [
                                        NSAttributedString.Key.font : Configuration.settingsFont,
                                        NSAttributedString.Key.foregroundColor : Configuration.settingsColor,
                                        ])
        
        button.setAttributedTitle(title, for: UIControl.State())
        button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        button.sizeToFit()
        button.layer.borderColor = Configuration.settingsColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
        
        return button
        }()
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))
        
        return gesture
        }()
    
    let cameraMan = CameraMan()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraViewDelegate?
    var animationTimer: Timer?
    var locationManager: LocationManager?
    var startOnFrontCamera: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Configuration.recordLocation {
            locationManager = LocationManager()
        }
        
        view.backgroundColor = Configuration.mainColor
        
        //containerView.frame = CGRect(x: 20, y: 20, width: 200, height: 300)
        
      
        


        view.addSubview(containerView)
        
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
              
                  if #available(iOS 11.0, *) {
                      let guide = self.view.safeAreaLayoutGuide
                      containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
                      containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
                      containerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 25).isActive = true
                      containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -43).isActive = true
                  }
        
        containerView.addSubview(blurView)
        
        [focusImageView, capturedImageView].forEach {
            view.addSubview($0)
        }
        
        view.addGestureRecognizer(tapGestureRecognizer)
        
        cameraMan.delegate = self
        cameraMan.setup(self.startOnFrontCamera)
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        previewLayer?.connection.videoOrientation = .portrait
////            if(view.layer.frame.size.width > view.layer.frame.size.height) {
////                previewLayer?.connection.videoOrientation = .landscapeLeft
////            }
//        locationManager?.startUpdatingLocation()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        locationManager?.stopUpdatingLocation()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer?.connection?.videoOrientation = .portrait
        //            if(view.layer.frame.size.width > view.layer.frame.size.height) {
        //                previewLayer?.connection.videoOrientation = .landscapeLeft
        //            }
        locationManager?.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    
    func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: cameraMan.session)
        layer.backgroundColor = Configuration.mainColor.cgColor
        layer.autoreverses = true
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //layer.videoGravity = AVLayerVideoGravity.resizeAspect
        //layer.masksToBounds = true
        //view.layer.masksToBounds = true
        
        
        view.layer.insertSublayer(layer, at: 0)
        
        
        layer.frame = containerView.frame

        layer.cornerRadius = 30
        
         if #available(iOS 13.0, *) {
                   layer.cornerCurve = .continuous
               } else {
                   print("ios 13 is not available")
                   // Fallback on earlier versions
               }

        
            //  containerView.layer.addSublayer(layer)
        
        
//        print("layer.visibleRect \(layer.visibleRect)")
//              print("layer.bounds \(layer.bounds)")
//
//

        
        //in a case if only photo supported
        //добавить полосу
//        if (photoModeOnly) {
//            layer.frame = CGRect(x: 0,
//                                 y: 40,
//                                 width: view.layer.frame.size.width,
//                                 height: view.layer.frame.size.height - 140)
//
////            view.layer.frame = CGRect(x: 0,
////                                      y: 40,
////                                      width: view.layer.frame.size.width,
////                                      height: view.layer.frame.size.height - 140)
//
//        }
        
        
            // made in a case if camera appears in horizontal mode
//            if(view.layer.frame.size.width > view.layer.frame.size.height) {
//                layer.frame = CGRect(x: view.layer.frame.origin.x,
//                                     y: view.layer.frame.origin.y,
//                                     width: view.layer.frame.size.height,
//                                     height: view.layer.frame.size.width)
//            }
//
            
            //view.clipsToBounds = true
            
            previewLayer = layer
        }
        
        // MARK: - Layout
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            let centerX = view.bounds.width / 2
            
            noCameraLabel.center = CGPoint(x: centerX,
                                           y: view.bounds.height / 2 - 80)
            
            noCameraButton.center = CGPoint(x: centerX,
                                            y: noCameraLabel.frame.maxY + 20)
            
//            containerView.frame = view.bounds
//            capturedImageView.frame = view.bounds
//
//            blurView.frame = view.bounds

            
        }
        
        // MARK: - Actions
        
    @objc func settingsButtonDidTap() {
            DispatchQueue.main.async {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(settingsURL)
                }
            }
        }
        
        // MARK: - Camera actions
        
    func rotateCamera(globalFlash:String) {
           // UIView.animate(withDuration: 0.4, animations: { _ in
              //  self.containerView.alpha = 1
                
               // let blurView = UIVisualEffectView(frame: self.view.bounds)
        
        print("self.capturedImageView.bounds \(self.view.bounds)" )
        //dims CMVideoDimensions(width: 1920, height: 1080)
        //812 x 375
        //640 x 360
        //let view2 = UIView(frame: CGRect(x:0, y:70, width:self.view.frame.width, height: 670 ))
               
        for _ in 0..<self.faceDetectionBoxes.count
        {
        self.faceDetectionBoxes.popLast()?.removeFromSuperview()
        }
        
        let blurView = UIVisualEffectView(frame: containerView.frame)
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 30
        if #available(iOS 13.0, *) {
            blurView.layer.cornerCurve = .continuous
        } else {
            print("ios 13 is not available")
            // Fallback on earlier versions
        }


        
               // blurView.addSubview(self.containerView.ins_snapshotView())
                blurView.effect = UIBlurEffect(style: .light)
                self.view.addSubview(blurView)
            
            
//            UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromLeft, animations: {})
//            , completion: {};)
            
            UIView.transition(with: self.view, duration: 0.8, options: .transitionFlipFromLeft, animations: {
            
                self.cameraMan.switchCamera {
                    //blurView.removeFromSuperview()
                    //blurView.alpha = 0.5
                    UIView.animate(withDuration: 0.5, animations: {
                         //blurView.removeFromSuperview()
                        blurView.alpha = 0
                        self.containerView.alpha = 0
                        
                        // blurView.alpha = 0
                        
                    //}, completion: { (finished: Bool) in
                       // blurView.alpha = 0

                    }
                  )
                    
                }
                
            }
            ) {
                
                (completion) -> Void in
                
                    //blurView.alpha = 0.5

//                    self.cameraMan.switchCamera {
//                        //blurView.removeFromSuperview()
//
//                                            UIView.animate(withDuration: 0.3, animations: {
//                                               // blurView.removeFromSuperview()
//                                                blurView.alpha = 0
//                                                self.containerView.alpha = 0
//
//                                               // blurView.alpha = 0
//
//                                            })
//
//                                            }
                
                self.flashCamera(globalFlash)

                }
                
                
    //        }
//    , completion: { _ in
//                self.cameraMan.switchCamera {
//                    UIView.animate(withDuration: 0.7, animations: {
//                        self.containerView.alpha = 0
//                    })
//                }
//            })
        }
        
        func flashCamera(_ title: String) {
            let mapping: [String: AVCaptureDevice.FlashMode] = [
                "On": .on,
                "Off": .off
            ]
            // cameraMan.flash(mapping[title] ?? .auto, 0)
        }
        
        func takePicture(_ completion: @escaping () -> ()) {
            print("take picture in cameraview")
            guard let previewLayer = previewLayer else { return }
            
            UIView.animate(withDuration: 0.1, animations: {
                self.capturedImageView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.capturedImageView.alpha = 0
                })
            })
            
                cameraMan.takePhoto(previewLayer, location: locationManager?.latestLocation) {
                  completion()
                  //self.delegate?.imageToLibrary()
                }
            
//            cameraMan.takePhotoNotSave(previewLayer, location: locationManager?.latestLocation) {image,location in
//                completion()
//                self.delegate?.imageToLibrary(image,location, nil)
//            }
        }
        
        func takeVideo(flashMode: String, completion: @escaping () -> ()) {
            
            let mapping: [String: AVCaptureDevice.FlashMode] = [
                "On": .on,
                "Off": .off
            ]
            //        if (flashMode == "ON"){
            //        cameraMan.flash(mapping[flashMode] ?? .auto, 1)
            //        }
            //        else {
            //            cameraMan.flash(mapping[flashMode] ?? .auto, 0)
            //
            //        }
            
            print("flash mode  \(flashMode)")
            if (flashMode == "On" || flashMode == "Off") {
               // cameraMan.flashOn(mapping[flashMode] ?? .auto)
            }
            
            
            guard let previewLayer = previewLayer else { return }
            UIView.animate(withDuration: 0.1, animations: {
                self.capturedImageView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.capturedImageView.alpha = 0
                })
            })
            //        let device = cameraMan.currentInput?.device
            //        device?.torchMode = (device?.isTorchActive)! ? AVCaptureTorchMode.off : AVCaptureTorchMode.on
            cameraMan.takeVideo(previewLayer, location: locationManager?.latestLocation)
        }
        
        func stopVideo(_ completion: @escaping () -> ()) {
            
            print("stop video")
            
            let mapping: [String: AVCaptureDevice.FlashMode] = [
                "On": .on,
                "Off": .off
            ]
            
            // cameraMan.flashOff(mapping["OFF"] ?? .auto)
            
            
            UIView.animate(withDuration: 0.1, animations: {
                self.capturedImageView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.capturedImageView.alpha = 0
                })
            })
            
            cameraMan.stopVideo(location: locationManager?.latestLocation) { image, loc, url in
                completion()
                self.delegate?.imageToLibrary(image,loc, url)
                
            }
        }
        
        
        // MARK: - Timer methods
        
    @objc func timerDidFire() {
            UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                self.focusImageView.alpha = 0
                }, completion: { _ in
                    //self.focusImageView.transform = CGAffineTransform.identity
            })
        }
        
        // MARK: - Camera methods
    
        
        func focusTo(_ point: CGPoint) {
            print("origiinal point \(point)")
            var convertedPoint = CGPoint(x: point.y / UIScreen.main.bounds.height,
                                         y: 1.0 - point.x / UIScreen.main.bounds.width)
            
            // for camera opened in horizontal mode
            //    if (UIScreen.main.bounds.width > UIScreen.main.bounds.height) {
            //        convertedPoint = CGPoint(x: point.x / UIScreen.main.bounds.height,
            //                                 y:point.y / UIScreen.main.bounds.width)
            //    }
            
            cameraMan.focus(convertedPoint)
            
            focusImageView.center = point
            UIView.animate(withDuration: 0.2, animations: {
                self.focusImageView.alpha = 1
                self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                
                
                
                //        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.autoreverse], animations: { _ in
                //            self.focusImageView.alpha = 0
                //        }, completion: { _ in
                //        })
                //
                //
            }, completion: { _ in
                
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = self.focusImageView.layer.cornerRadius
                animation.fromValue = 1
                animation.toValue = 0.5
                animation.repeatCount = 4
                //animation.autoreverses = true
                self.focusImageView.layer.add(animation, forKey: "opacity")
                
                
                //                UIView.animate(withDuration: 1, delay: 0.0, options: [.autoreverse], animations: { _ in
                //                    self.focusImageView.alpha = 0.3
                //                }, completion: { _ in
                //
                //                    self.animationTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                //                                                               selector: #selector(CameraView.timerDidFire), userInfo: nil, repeats: false)
                //
                //                })
                
                
                //        UIView.transition(from: self.focusImageView, to: self.focusImageView, duration: 1, options: .transitionCrossDissolve, completion: { _ in
                //            self.animationTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                //                                                       selector: #selector(CameraView.timerDidFire), userInfo: nil, repeats: false)
                //
                //        })
                
                
                
                self.animationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                                           selector: #selector(CameraView.timerDidFire), userInfo: nil, repeats: false)
                
                
            })
        }
        
        // MARK: - Tap
        
    @objc func tapGestureRecognizerHandler(_ gesture: UITapGestureRecognizer) {
            let touch = gesture.location(in: view)
            
            focusImageView.transform = CGAffineTransform.identity
            animationTimer?.invalidate()
            focusTo(touch)
        }
    
    
        
        // MARK: - Private helpers
        
        func showNoCamera(_ show: Bool) {
            [noCameraButton, noCameraLabel].forEach {
                show ? view.addSubview($0) : $0.removeFromSuperview()
            }
        }
        
        // CameraManDelegate
        func cameraManNotAvailable(_ cameraMan: CameraMan) {
            showNoCamera(true)
            focusImageView.isHidden = true
            delegate?.cameraNotAvailable()
        }
        
        func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
            delegate?.setFlashButtonHidden(!input.device.hasFlash)
        }
        
        func cameraManDidStart(_ cameraMan: CameraMan) {
            setupPreviewLayer()
        }
    
     func cameraManFaceDetected(_ cameraMan: CameraMan, didOutput metadataObjects: [AVMetadataObject]) {
                  let faceMetadataObjects = metadataObjects.filter({ $0.type == .face })
        if (faceMetadataObjects.count != numberOfFaces) {
            numberOfFaces = faceMetadataObjects.count
            for _ in 0..<self.faceDetectionBoxes.count
            {
                self.faceDetectionBoxes.popLast()?.removeFromSuperview()
            }
        }
                  if faceMetadataObjects.count > self.faceDetectionBoxes.count {
                      for f in 0..<faceMetadataObjects.count - self.faceDetectionBoxes.count
                      {
                          let view = UIView()
                          view.layer.borderColor = UIColor.yellow.cgColor
                          view.layer.borderWidth = 1
                        view.layer.cornerRadius = 15
                        view.alpha = 0
                        self.view.addSubview(view)
                        
                       UIView.animate(withDuration: 0.5,
                                       delay: 0.5,
                                     options: [],
                                     animations: {
                                       view.alpha = 1
                            }, completion:  nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                            UIView.animate(withDuration: 0.5,
                                           delay: 0.0,
                                         options: [],
                                         animations: {
                                           view.alpha = 0
                                }, completion:  { _ in
                                    view.removeFromSuperview()}
                            )
                        })
                         if let transformedMetadataObject = self.previewLayer?.transformedMetadataObject(for: faceMetadataObjects[f]) {
                        let tempFrame = transformedMetadataObject.bounds
                            view.frame =  self.containerView.convert(tempFrame, to: self.view)
                        }

                          self.faceDetectionBoxes.append(view)
                      }
                  } else if faceMetadataObjects.count < self.faceDetectionBoxes.count {
                      for _ in 0..<self.faceDetectionBoxes.count - faceMetadataObjects.count
                      {
                          self.faceDetectionBoxes.popLast()?.removeFromSuperview()
                      }
                  }
        
                  for i in 0..<faceMetadataObjects.count {
//                    print("faceMetadataObjects.count \(i)")
                    
                      if let transformedMetadataObject = self.previewLayer?.transformedMetadataObject(for: faceMetadataObjects[i]) {
                        let tempFrame = transformedMetadataObject.bounds
                        print("tempFrame \(tempFrame)")
                       // if (tempFrame.origin.x > 20 && tempFrame.origin.y > 20) {
                          UIView.animate(withDuration: 0.5) {
                        self.faceDetectionBoxes[i].frame =  self.containerView.convert(tempFrame, to: self.view)
                       // }
                        }
                      }
                  }
    }
    
    
    var faceDetectionBoxes: [UIView] = []
    var numberOfFaces = 0

    
  
}
