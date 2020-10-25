import UIKit
import MediaPlayer
import Photos

import AssetsPickerViewController



private let imageSize = CGSize(width: 80, height: 80)


@objc public protocol ImagePickerDelegate: class {

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage])
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage])
    func cancelButtonDidPress(_ imagePicker: ImagePickerController)
}

open class ImagePickerController: UIViewController

{

//    public func assetsPickerController(_ picker: CTAssetsPickerController, didFinishPicking assets: [PHAsset]) {
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
//
//        print("didFinishPickingAssets")
////        picker.dismiss(animated: true, completion: {
////        })
////        self.dismiss(animated:false, completion: nil);
//
//    }
//
//    public func assetsPickerControllerDidCancel(_ picker: CTAssetsPickerController) {
//        //self.navigationController?.popViewController(animated: true)
//        picker.dismiss(animated: true, completion: nil)
//    }

    struct GestureConstants {
        static let maximumHeight: CGFloat = 200
        static let minimumHeight: CGFloat = 115
        static let velocity: CGFloat = 150
    }

    var photoModeOnly = false


    open lazy var galleryView: ImageGalleryView = { [unowned self] in
        let galleryView = ImageGalleryView()
        galleryView.delegate = self
        galleryView.selectedStack = self.stack
        galleryView.collectionView.layer.anchorPoint = CGPoint(x: 0, y: 0)
        galleryView.imageLimit = self.imageLimit
        return galleryView
        }()

    open lazy var bottomContainer: BottomContainerView = { [unowned self] in
        //let view = BottomContainerView()
        let view = BottomContainerView(frame: self.view.frame, b: self.photoModeOnly)
        //view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
        // прозрачность нижнего слоя !!!
        view.backgroundColor = UIColor.clear
        //view.photoModeOnly = self.photoModeOnly
        view.delegate = self

        return view
        }()

    lazy var topView: TopView = { [unowned self] in
        let view = TopView()
        view.backgroundColor = UIColor.clear
        view.delegate = self

        return view
        }()

    lazy var cameraController: CameraView = { [unowned self] in
        let controller = CameraView()
        controller.photoModeOnly = self.photoModeOnly
        controller.delegate = self
        controller.startOnFrontCamera = self.startOnFrontCamera

        return controller
        }()

    lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(panGestureRecognizerHandler(_:)))

        return gesture
        }()


    lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = { [unowned self] in
    let gesture = UIPinchGestureRecognizer()
    gesture.addTarget(self, action: #selector(pinchGestureRecognizerHandler(_:)))

    return gesture
    }()



    @objc func pinchGestureRecognizerHandler(_ gesture: UIPinchGestureRecognizer) {
        print("pinch pinch pinch")

        cameraController.cameraMan.zoom(gesture)

    }

    lazy var volumeView: MPVolumeView = { [unowned self] in
        let view = MPVolumeView()
        view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)

        return view
        }()

    var volume = AVAudioSession.sharedInstance().outputVolume

    open weak var delegate: ImagePickerDelegate?
    open var stack = ImageStack()
    open var imageLimit = 0
    open var preferredImageSize: CGSize?
    open var startOnFrontCamera = false
    var totalSize: CGSize { return UIScreen.main.bounds.size }
    var initialFrame: CGRect?
    var initialContentOffset: CGPoint?
    var numberOfCells: Int?
    var statusBarHidden = false
    open var globalFlash: String = "Auto"

    open lazy var timerCamera = UILabel()
   // open var mycountdownTimer: MZTimerLabel?
    open lazy var reddot = UIView()





    open var navCtrl : UIViewController?

    open var galleryExpanded = false;
    open var galleryShown = true;

    var viewWasLoaded = false


    fileprivate var isTakingPicture = false
    open var doneButtonTitle: String? {
        didSet {
            if let doneButtonTitle = doneButtonTitle {
                bottomContainer.doneButton.setTitle(doneButtonTitle, for: UIControl.State())
            }
        }
    }
    
    
    class CustomAlbumCell: UICollectionViewCell, AssetsAlbumCellProtocol {
        //private let imageSize = CGSize(width: 80, height: 80)

        // MARK: - AssetsAlbumCellProtocol
        var album: PHAssetCollection? {
            didSet {}
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    contentView.dim(animated: false, color: .gray, alpha: 0.3)
                } else {
                    contentView.undim()
                }
            }
        }
        
        var imageView: UIImageView = {
            let view = UIImageView()
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.backgroundColor = UIColor(rgbHex: 0xF0F0F0)
            return view
        }()
        
        var titleText: String? {
            didSet {
                if let titleText = self.titleText {
                    titleLabel.text = "\(titleText) (\(count))"
                } else {
                    titleLabel.text = nil
                }
            }
        }
        
        var count: Int = 0 {
            didSet {
                if let titleText = self.titleText {
                    titleLabel.text = "\(titleText) (\(count))"
                } else {
                    titleLabel.text = nil
                }
            }
        }
        
        // MARK: - At your service
        
        var titleLabel: UILabel = {
            let label = UILabel()
            label.clipsToBounds = true
            return label
        }()
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        private func commonInit() {
            contentView.addSubview(imageView)
            contentView.addSubview(titleLabel)
            
            imageView.snp.makeConstraints { (make) in
                make.size.equalTo(imageSize)
                make.leading.equalToSuperview()
            }
            titleLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(imageView.snp.trailing).inset(10)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.trailing.equalToSuperview()
            }
        }
    }

    // MARK: - View lifecycle


    open override func viewDidLoad() {
        super.viewDidLoad()



//        view.translatesAutoresizingMaskIntoConstraints = false
//               if #available(iOS 11.0, *) {
//                   let guide = self.view.safeAreaLayoutGuide
//                   view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//                   view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//                   view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
//                   view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
//
//               }


        cameraController.previewLayer?.connection?.videoOrientation = .portrait  // ?????



        if (self.view.frame.width > self.view.frame.height){
            statusBarHidden = true
        }

        self.reddot.alpha = 0.9
        self.reddot.layer.cornerRadius = 3
        self.reddot.backgroundColor = UIColor.red

        self.reddot.isHidden = true;
        self.timerCamera.isHidden = true;


        for subview in [
            cameraController.view
        ,
                        galleryView,
                        bottomContainer,
                        topView,
                        timerCamera,
                        reddot
            ] {
                            if(!(self.photoModeOnly && subview == galleryView)) {
                                view.addSubview(subview!)
                            }
                            //subview?.translatesAutoresizingMaskIntoConstraints = false
        }



        view.backgroundColor = UIColor.black

        self.timerCamera.textColor = UIColor.white
        self.timerCamera.font = UIFont(name: "Verdana", size: 15.0)
       // self.mycountdownTimer = MZTimerLabel(label: self.timerCamera)

        cameraController.view.addGestureRecognizer(panGestureRecognizer)
        cameraController.view.addGestureRecognizer(pinchGestureRecognizer)
       // cameraController.view.isMultipleTouchEnabled = true




        subscribe()
        setupConstraints()

        //cameraController.flashCamera("ON") //сначала включаем камеру
        //cameraController.flashCamera("AUTO")

        // ---
        let rotate = Helper.rotationTransform()

        UIView.animate(withDuration: 0.25, animations: {
            //            [self.topView.rotateCamera, self.bottomContainer.pickerButton,
            //             self.bottomContainer.stackView, self.bottomContainer.doneButton].forEach {
            //                $0.transform = rotate
            //            }
            [//self.topView.rotateCamera,
             self.bottomContainer.pickerButton,
             self.bottomContainer.galleryButton, self.bottomContainer.doneButton].forEach {
                $0.transform = rotate
            }

            self.galleryView.collectionViewLayout.invalidateLayout()

            if (self.photoModeOnly) {
                self.topView.rotateCamera.isHidden=true;
                //self.bottomContainer.galleryButton.isHidden = true;
            }

            let translate: CGAffineTransform
            if [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight]
                .contains(UIDevice.current.orientation) {
                translate = CGAffineTransform(translationX: -20, y: 15)
            } else {
                translate = CGAffineTransform.identity
            }

            self.topView.flashButton.transform = rotate.concatenating(translate)
        })

        // ---

        cameraController.flashCamera(self.globalFlash)
        
        
        //adding view controller in container

                     let containerView = UIView()

                     containerView.translatesAutoresizingMaskIntoConstraints = false

                     view.addSubview(containerView)

                     NSLayoutConstraint.activate([
                         containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                         containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                         containerView.heightAnchor.constraint(equalToConstant: 250),
                         containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -250),
                     ])



                     // add child view controller view to container


              let pickerConfig = AssetsPickerConfig()
              pickerConfig.assetCellType = AssetsPhotoCell.classForCoder()
              pickerConfig.albumCellType = CustomAlbumCell.classForCoder()
              pickerConfig.albumPortraitForcedCellHeight = imageSize.height
              pickerConfig.albumLandscapeForcedCellHeight = imageSize.height
              pickerConfig.albumForcedCacheSize = imageSize
              pickerConfig.albumDefaultSpace = 1
              pickerConfig.albumLineSpace = 1
              pickerConfig.albumPortraitColumnCount = 1
              pickerConfig.albumLandscapeColumnCount = 1

              let controller = AssetsPickerViewController()
              controller.pickerConfig = pickerConfig
              //controller.pickerDelegate = self

      //               let controller = UIViewController()
      //        controller.view.backgroundColor = .blue

                     addChild(controller)

                     controller.view.translatesAutoresizingMaskIntoConstraints = false

                   //  containerView.addSubview(controller.view)



//                     NSLayoutConstraint.activate([
//
//                         controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//
//                         controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//
//                         controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
//
//                         controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//
//                     ])
//
//
//
//                     controller.didMove(toParent: self)
        

    }

    override  open var shouldAutorotate: Bool {
        return false
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }



    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if(!photoModeOnly){
            _ = try? AVAudioSession.sharedInstance().setActive(true)
        }
        // statusBarHidden = UIApplication.shared.isStatusBarHidden
        //UIApplication.shared.setStatusBarHidden(true, with: .fade)


        //UIApplication.shared.setStatusBarHidden(true, with: .fade)

        // self.setNeedsStatusBarAppearanceUpdate()
            statusBarHidden = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {// выход из галереи в камере, чтобы не залипало
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        }
        //self.modalPresentationCapturesStatusBarAppearance = true

        //self.navigationController?.navigationBar.isHidden = true;


    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")



        if (!viewWasLoaded) {

            let galleryHeight: CGFloat = UIScreen.main.nativeBounds.height == 960
                ? ImageGalleryView.Dimensions.galleryBarHeight : GestureConstants.minimumHeight

            galleryView.collectionView.transform = CGAffineTransform.identity
            galleryView.collectionView.contentInset = UIEdgeInsets.zero

            galleryView.frame = CGRect(x: 0,
                                       y: totalSize.height - bottomContainer.frame.height - 55 - galleryHeight,
                                       width: totalSize.width,
                                       height: galleryHeight)
            galleryView.updateFrames()
            checkStatus()

            initialFrame = galleryView.frame
            initialContentOffset = galleryView.collectionView.contentOffset
            viewWasLoaded = true

            galleryView.topSeparator.addSubview(Configuration.indicatorView)

        }

        else { // в случае изменения размеров галереи до вызова фотогалереи

            //            galleryView.frame = CGRect(x: 0,
            //                                       y: totalSize.height - bottomContainer.frame.height - galleryHeight,
            //                                       width: totalSize.width,
            //                                       height: galleryHeight)
            //            galleryView.updateFramesNoReload()
            //            checkStatus()
            //
            //            initialFrame = galleryView.frame
            //            initialContentOffset = galleryView.collectionView.contentOffset
            //



        }


    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        // UIApplication.shared.setStatusBarHidden(statusBarHidden, with: .fade)
        statusBarHidden = false
//        UIView.animate(withDuration: 0.01) {
//            self.setNeedsStatusBarAppearanceUpdate()
//        }
    }

    open func resetAssets() {
        self.stack.resetAssets([])
    }

    func checkStatus() {
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        guard currentStatus != .authorized else { return }

        if currentStatus == .notDetermined { hideViews() }

        PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void in
            DispatchQueue.main.async {
                if authorizationStatus == .denied {
                    self.presentAskPermissionAlert()
                } else if authorizationStatus == .authorized {
                    self.permissionGranted()
                }
            }
        }
    }

    func presentAskPermissionAlert() {
        let alertController = UIAlertController(title: Configuration.requestPermissionTitle, message: Configuration.requestPermissionMessage, preferredStyle: .alert)

        let alertAction = UIAlertAction(title: Configuration.OKButtonTitle, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: Configuration.cancelButtonTitle, style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func hideViews() {
        enableGestures(false)
    }

    func permissionGranted() {
        galleryView.fetchPhotos()
        galleryView.canFetchImages = false
        enableGestures(true)
    }

    // MARK: - Notifications



    deinit {
        _ = try? AVAudioSession.sharedInstance().setActive(false)
        NotificationCenter.default.removeObserver(self)
    }

    func subscribe() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustButtonTitle(_:)),
                                               name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidPush),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustButtonTitle(_:)),
                                               name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidDrop),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReloadAssets(_:)),
                                               name: NSNotification.Name(rawValue: ImageStack.Notifications.stackDidReload),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(volumeChanged(_:)),
                                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRotation(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    @objc func didReloadAssets(_ notification: Notification) {
        adjustButtonTitle(notification)
        galleryView.collectionView.reloadData()
        galleryView.collectionView.setContentOffset(CGPoint.zero, animated: false)
    }

    @objc func volumeChanged(_ notification: Notification) {
        guard let slider = volumeView.subviews.filter({ $0 is UISlider }).first as? UISlider,
            let userInfo = (notification as NSNotification).userInfo,
            let changeReason = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String, changeReason == "ExplicitVolumeChange" else { return }

        slider.setValue(volume, animated: false)
        takePicture()
    }

    @objc func adjustButtonTitle(_ notification: Notification) {
        guard let sender = notification.object as? ImageStack else { return }

        //        let title = !sender.assets.isEmpty ?
        //            Configuration.doneButtonTitle : Configuration.cancelButtonTitle
        //        bottomContainer.doneButton.setTitle(title, for: UIControlState())

        let image = !sender.assets.isEmpty ? UIImage(named: "button_ok_big_old") : UIImage(named: "button_fotopovorot_new")
        //let image = !sender.assets.isEmpty ? UIImage(named: "envelope") : UIImage(named: "button_exit")
        bottomContainer.doneButton.setImage(image, for: .normal)
//        bottomContainer.doneButton.setImage(image, for: .highlighted)
//        bottomContainer.doneButton.setImage(image, for: .focused)
        bottomContainer.doneButton.setImage(image, for: .selected)



    }

    // MARK: - Helpers

    open override var prefersStatusBarHidden: Bool {

        return statusBarHidden
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    open func collapseGalleryView(_ completion: (() -> Void)?) {
        galleryView.collectionViewLayout.invalidateLayout()
        UIView.animate(withDuration: 0.3, animations: {
            self.updateGalleryViewFrames(self.galleryView.topSeparator.frame.height, 0)
            self.galleryView.collectionView.transform = CGAffineTransform.identity
            self.galleryView.collectionView.contentInset = UIEdgeInsets.zero
            self.galleryView.collectionView.frame.size.height = 0;
            self.galleryView.layoutIfNeeded()

        }, completion: { _ in
            completion?()
        })
    }

    open func showGalleryView() {
        galleryView.collectionViewLayout.invalidateLayout()
        UIView.animate(withDuration: 0.3, animations: {
            self.updateGalleryViewFrames(GestureConstants.minimumHeight, 96)
            self.galleryView.collectionView.transform = CGAffineTransform.identity
            self.galleryView.collectionView.contentInset = UIEdgeInsets.zero
        })
    }

    open func expandGalleryView(_ completion: (() -> Void)?) {
        // self.galleryView.collectionView.frame.size.height = 200
        self.galleryView.layoutIfNeeded()
        // galleryView.collectionViewLayout.invalidateLayout()

        UIView.animate(withDuration: 0.3, animations: {
            self.updateGalleryViewFrames(GestureConstants.maximumHeight, 176)
            //self.galleryView.topSeparator.isUserInteractionEnabled = false;
            let scale = (GestureConstants.maximumHeight - ImageGalleryView.Dimensions.galleryBarHeight) / (GestureConstants.minimumHeight - ImageGalleryView.Dimensions.galleryBarHeight)
            self.galleryView.collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)

            let value = self.view.frame.width * (scale - 1) / scale
            self.galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  value)
            //self.galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  120)


        },
                       completion: { _ in
                        completion?()
                        // self.galleryView.topSeparator.isUserInteractionEnabled = true;
        })
    }

    func updateGalleryViewFrames(_ constant: CGFloat, _ height: CGFloat) {
        // galleryView.frame.origin.y = totalSize.height - bottomContainer.frame.height - constant
        galleryView.frame.origin.y = totalSize.height - bottomContainer.frame.height - constant
        galleryView.frame.size.height = constant
        galleryView.collectionView.frame.size.height = height;
    }

    func enableGestures(_ enabled: Bool) {
        galleryView.alpha = enabled ? 1 : 0
        bottomContainer.pickerButton.isEnabled = enabled
        bottomContainer.tapGestureRecognizer.isEnabled = enabled
        topView.flashButton.isEnabled = enabled
        topView.rotateCamera.isEnabled = Configuration.canRotateCamera
    }

    fileprivate func isBelowImageLimit() -> Bool {
        return (imageLimit == 0 || imageLimit > galleryView.selectedStack.assets.count)
    }

    fileprivate func takePicture() {
        //self.resetAssets()
        guard isBelowImageLimit() && !isTakingPicture else {
            return }
        isTakingPicture = true
        bottomContainer.pickerButton.isEnabled = false
        //  bottomContainer.stackView.startLoader()
        let action: () -> Void = { [unowned self] in
            self.cameraController.takePicture {

                self.isTakingPicture = false
                self.bottomContainer.pickerButton.numberLabel.text = ""

            }

        }

        if Configuration.collapseCollectionViewWhileShot {
            collapseGalleryView(action)
        } else {
            action()
        }
    }

    fileprivate func takeVideo() {
        self.topView.isHidden = true
        self.bottomContainer.doneButton.isHidden = true
        self.bottomContainer.galleryButton.isHidden = true
        self.timerCamera.isHidden = false
        self.reddot.isHidden = false
        //self.mycountdownTimer?.start()
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.reddot.layer.opacity = 0
        }, completion: nil)
        let action: () -> Void = { [unowned self] in
            self.cameraController.takeVideo(flashMode: self.globalFlash) {  self.isTakingPicture = true }
        }
        if Configuration.collapseCollectionViewWhileShot {
            collapseGalleryView(action)
        } else {
            action()
        }


    }

    fileprivate func stopVideo() {
        print("Stop video")
        //self.mycountdownTimer?.pause()
        self.topView.isHidden = false
        self.bottomContainer.doneButton.isHidden = false
        self.bottomContainer.galleryButton.isHidden = false
        self.timerCamera.isHidden = true
        self.reddot.isHidden = true
        //self.mycountdownTimer?.reset()
        guard isBelowImageLimit() && !isTakingPicture else { return }
        isTakingPicture = true
        bottomContainer.pickerButton.isEnabled = false
        // bottomContainer.stackView.startLoader()
        let action: () -> Void = { [unowned self] in
            self.cameraController.stopVideo { self.isTakingPicture = false }
        }

        if Configuration.collapseCollectionViewWhileShot {
            collapseGalleryView(action)
        } else {
            action()
        }
    }
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {

    func pickerButtonDidPress() {
        print("take picture__")
        takePicture()
    }

    func pickerButtonDidLongPress() {
        if (self.photoModeOnly) {
            takePicture()
        }
        else {
            takeVideo()
        }
    }

    func pickerButtonDidRelease() {
        stopVideo()
    }


    func doneButtonDidPress() {
        var images: [UIImage]
        if let preferredImageSize = preferredImageSize {
            images = AssetManager.resolveAssets(stack.assets, size: preferredImageSize)
        } else {
            images = AssetManager.resolveAssets(stack.assets)
        }

        delegate?.doneButtonDidPress(self, images: images)
    }

    func cancelButtonDidPress() {
        dismiss(animated: true, completion: nil)
        delegate?.cancelButtonDidPress(self)
    }

    func imageStackViewDidPress() {
        var images: [UIImage]
        if let preferredImageSize = preferredImageSize {
            images = AssetManager.resolveAssets(stack.assets, size: preferredImageSize)
        } else {
            images = AssetManager.resolveAssets(stack.assets)
        }

        // if(images.count == 0) {
//        var picker:CTAssetsPickerController?
//        picker = CTAssetsPickerController()
//        picker?.delegate = self
//        self.present(picker!, animated: true, completion: nil)

        //self.navigationController?.navigationBar.isHidden = true
        //picker?.navigationController?.navigationBar.isHidden = true
        //self.navigationController?.pushViewController(picker!, animated: true )
        // }
        //        else {
        //
        //            var photos = [INSPhotoViewable]()
        //            for image in images {
        //               photos.append(INSPhoto(image: image, thumbnailImage: image))
        //            }
        //
        //
        //            for photo in photos {
        //                if let photo = photo as? INSPhoto {
        //                    photo.attributedTitle = NSAttributedString(string: "21.12.2016", attributes: [NSForegroundColorAttributeName: UIColor.white])
        //                }
        //            }
        //
        //            let currentPhoto = photos[0]
        //            let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
        //
        //
        //            present(galleryPreview, animated: true, completion: nil)
        //
        //        }


        delegate?.wrapperDidPress(self, images: images)
    }
}

extension ImagePickerController: CameraViewDelegate {

    func cameraManDidPhoto(_ photo: AVCapturePhoto) {
    }
    
    func setFlashButtonHidden(_ hidden: Bool) {
        topView.flashButton.isHidden = hidden
    }

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

    func imageToLibrary(_ img: UIImage?, _ location: CLLocation?, _ videoUrl: URL?) {
        guard let collectionSize = galleryView.collectionSize else { return }

        //        galleryView.fetchPhotos() {
        //            guard let asset = self.galleryView.assets.first else { return }
        //            self.stack.pushAsset(asset)
        //            self.bottomContainer.pickerButton.numberLabel.text = ""
        //        }

        galleryView.shouldTransform = true
        bottomContainer.pickerButton.isEnabled = true

        UIView.animate(withDuration: 0.3, animations: {
            self.galleryView.collectionView.transform = CGAffineTransform(translationX: collectionSize.width, y: 0)
        }, completion: { _ in
            self.galleryView.collectionView.transform = CGAffineTransform.identity

        // галерея которая должна быть в камере????

//            //self.gotoDetailedGallery()
//            // --  taking photos and open in separate controller
//            var images: [UIImage] = [img!]
//            //            if let preferredImageSize = self.preferredImageSize {
//            //               // images = AssetManager.resolveAssets(self.stack.assets, size: preferredImageSize)
//            //                images = [img!]
//            //            } else {
//            //                //images = AssetManager.resolveAssets(self.stack.assets)
//            //                images = [img!]
//            //            }
//
//
//            var photos = [INSPhotoViewable]()
//            for image in images {
//                if (videoUrl != nil){
//                    photos.append(INSPhoto(image: image, thumbnailImage: image, videoUrl: videoUrl))
//                }
//                else {
//                    photos.append(INSPhoto(image: image, thumbnailImage: image))
//                }
//            }
//
//
//            for photo in photos {
//                if let photo = photo as? INSPhoto {
//                    photo.attributedTitle = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.white])
//                }
//            }
//
//            let currentPhoto = photos[0]
//            var galleryPreview: INSPhotosViewController?
//
//
//            galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
//            if (self.photoModeOnly) {
//                //                self.doneButtonDidPress()
//                //                return
//                let overlayView = INSPhotosOverlayView3()
//                galleryPreview?.overlayView = overlayView
//
//                var imageCropVC : RSKImageCropViewController!
//
//                imageCropVC = RSKImageCropViewController(image: currentPhoto.image!, cropMode: RSKImageCropMode.circle)
//
//                imageCropVC.delegate = self as? RSKImageCropViewControllerDelegate
//
//                //self.dismiss(animated: true, completion: nil)
//                print("self.parent?.parent?.presentingViewController?.navigationController?  \(String(describing: self.parent?.parent?.presentingViewController?.navigationController))")
//
//                print("self..navigationController?  \(String(describing: self.navigationController))")
//
//                print("self.parent?.navigationController?  \(String(describing: self.parent?.navigationController))")
//
//                print("self.parent?.parent?.navigationController?  \(String(describing: self.parent?.parent?.navigationController))")
//
//                print("self.parent?.parent?.parent?.navigationController?  \(String(describing: self.parent?.parent?.parent?.navigationController))")
//
//
//                print("self.presentingViewController?  \(String(describing: self.presentingViewController))")
//
//                print("self.presentingViewController?.navigationController  \(String(describing: self.presentingViewController?.navigationController))")
//
//
//                print("self.navigationController.viewControllers.popLast()  \(String(describing: self.navigationController?.viewControllers.count))")
//
//
//
//
////
////                print("self.view.window?.rootViewController?.navigationController  \(String(describing: self.view.window?.rootViewController?.navigationController))")
//
//
//                print("self.navCtrl  count \(String(describing: self.navCtrl))")
//                print("self.navCtrl  count \(String(describing: self.navCtrl?.navigationController))")
//
//
////                print("self.navCtrl  count \(String(describing: self.navCtrl?.viewControllers.count))")
//
//
//                //let navEditorViewController: UINavigationController = UINavigationController(rootViewController: imageCropVC)
//                //navEditorViewController.pushViewController(imageCropVC, animated: true)
//
//               //self.navCtrl?.navigationController?.pushViewController(imageCropVC, animated: true)
//
//                //self.navCtrl.viewControllers[0].navigationController?.pushViewController(navEditorViewController, animated: true)
//
//               // self.view.window?.rootViewController?.navigationController?.pushViewController(imageCropVC, animated: true)
//
//                //self.present(navEditorViewController, animated: false, completion: nil)
//
//                 // self.navigationController?.pushViewController(imageCropVC, animated: true)
//
//                //self.dismiss(animated: true, completion: nil)
//
//                imageCropVC.transitioningDelegate = self
//
//                imageCropVC.modalPresentationStyle = .custom
//
//               // imageCropVC.modalPresentationStyle = .currentContext;
//
//                self.present(imageCropVC, animated: true, completion: nil)
//
//                return
//
//            }

//            galleryPreview?.didDismissHandler = { _ in
//                print("didDismissHandler")
//                //                guard let asset = self.galleryView.assets.first else { return }
//                //                self.stack.dropAsset(asset)
//                //                let assetArray = [asset]
//                //
//                //
//                //                PHPhotoLibrary.shared().performChanges({
//                //                    PHAssetChangeRequest.deleteAssets(assetArray as NSFastEnumeration)
//                //                }, completionHandler: { (success, error) in
//                //                    print("Success \(success) - Error \(error)")
//                //                })
//                self.resetAssets()
//            }
//            //need to change to OK button
//            galleryPreview?.longPressGestureHandler = { _ in
//                print("longPressGestureHandler")
//                self.savePhoto(img!, location: location, completion: nil)
//
//                //                self.galleryView.fetchPhotos() {
//                //                    guard let asset = self.galleryView.assets.first else { return }
//                //                    self.stack.pushAsset(asset)
//                //                    self.bottomContainer.pickerButton.numberLabel.text = ""
//                //                }
//                return true
//            }
            self.resetAssets()
    //        self.present(galleryPreview!, animated: true, completion: nil)
            //--

        })



    }

    func cameraNotAvailable() {
        topView.flashButton.isHidden = true
        topView.rotateCamera.isHidden = true
        bottomContainer.pickerButton.isEnabled = false
    }

    // MARK: - Rotation



    @objc public func handleRotation(_ note: Notification) {
        let rotate = Helper.rotationTransform()

        UIView.animate(withDuration: 0.25, animations: {
            //            [self.topView.rotateCamera, self.bottomContainer.pickerButton,
            //             self.bottomContainer.stackView, self.bottomContainer.doneButton].forEach {
            //                $0.transform = rotate
            //            }
            [self.topView.rotateCamera, self.bottomContainer.pickerButton,
             self.bottomContainer.galleryButton, self.bottomContainer.doneButton].forEach {
                $0.transform = rotate
            }

            self.galleryView.collectionViewLayout.invalidateLayout()

            let translate: CGAffineTransform
            if [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight]
                .contains(UIDevice.current.orientation) {
                translate = CGAffineTransform(translationX: -20, y: 15)
            } else {
                translate = CGAffineTransform.identity
            }

            self.topView.flashButton.transform = rotate.concatenating(translate)
        })
    }
}

// MARK: - TopView delegate methods

extension ImagePickerController: TopViewDelegate {

    func flashButtonDidPress(_ title: String) {
        self.globalFlash = title
        cameraController.flashCamera(title)
    }

    func rotateDeviceDidPress() {
        cameraController.rotateCamera(globalFlash: self.globalFlash)
        //cameraController.flashCamera(self.globalFlash)
    }
}

// MARK: - Pan gesture handler

extension ImagePickerController: ImageGalleryPanGestureDelegate {

    func panGestureDidStart() {
        print("panGestureDidStart")
        guard let collectionSize = galleryView.collectionSize else { return }

        initialFrame = galleryView.frame
        initialContentOffset = galleryView.collectionView.contentOffset
        if let contentOffset = initialContentOffset { numberOfCells = Int(contentOffset.x / collectionSize.width) }
    }

    @objc func panGestureRecognizerHandler(_ gesture: UIPanGestureRecognizer) {
        print("panGestureRecognizerHandler")

        let translation = gesture.translation(in: view)
        //        let velocity = gesture.velocity(in: view)
        //
        //        if gesture.location(in: view).y > galleryView.frame.origin.y - 20 {
        //            gesture.state == .began ? panGestureDidStart() : panGestureDidChange(translation)
        //        }

        panGestureDidChange(translation)


        //        if gesture.state == .ended {
        //            panGestureDidEnd(translation, velocity: velocity)
        //        }
    }

    func panGestureDidChange(_ translation: CGPoint) {
        guard let initialFrame = initialFrame else { return }

        let galleryHeight = initialFrame.height - translation.y

        if galleryHeight >= GestureConstants.maximumHeight { return }

        if galleryHeight <= ImageGalleryView.Dimensions.galleryBarHeight {
            updateGalleryViewFrames(ImageGalleryView.Dimensions.galleryBarHeight, 0)
        } else if galleryHeight >= GestureConstants.minimumHeight {
            let scale = (galleryHeight - ImageGalleryView.Dimensions.galleryBarHeight) / (GestureConstants.minimumHeight - ImageGalleryView.Dimensions.galleryBarHeight)
            galleryView.collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
            galleryView.frame.origin.y = initialFrame.origin.y + translation.y
            galleryView.frame.size.height = initialFrame.height - translation.y
            galleryView.collectionView.frame.size.height = initialFrame.height - translation.y - 25;


            let value = view.frame.width * (scale - 1) / scale
            galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  value)
        } else {
            galleryView.frame.origin.y = initialFrame.origin.y + translation.y
            galleryView.frame.size.height = initialFrame.height - translation.y

            galleryView.collectionView.frame.size.height = initialFrame.height - translation.y - 25;

            if (abs(initialFrame.height - translation.y - 25) < 1) {
                galleryView.collectionView.frame.size.height = 0;

            }



            // if(galleryView.frame.size.height < 115)  {


            //galleryView.collectionView.frame.size.height = initialFrame.height - translation.y - 25;


            //                if (initialFrame.height - translation.y - 5 < 0) {
            //                   // galleryView.collectionView.frame.size.height = 0;
            //
            //                }
            //
            //                else {
            //               // galleryView.collectionView.frame.size.height = initialFrame.height - translation.y - 25;
            //                }
            //            }

            //            if (galleryView.collectionView.frame.size.height < 10) {
            //                galleryView.collectionView.frame.size.height = 0;
            //            }


            //galleryView.collectionView.frame = galleryView.frame;

            print ("translation.y \(translation.y)")
            print ("initialFrame.height \(initialFrame.height)")
            print ("size!!!! \(initialFrame.height - translation.y)")
            print ("DELTA!!!! \(initialFrame.height - translation.y - 25)")
            print ("initialFrame.origin.y \(initialFrame.origin.y)")
            //            print ("galleryView.frame.size.height \(galleryView.frame.size.height)")
            //            print ("galleryView.collectionView.frame.size.height \(galleryView.collectionView.frame.size.height)")
            //            print ("self.galleryView.topSeparator.frame.origin.y \(self.galleryView.topSeparator.frame.origin.y)")


        }
        //
        galleryView.updateNoImagesLabel()
    }



    func panGestureDidEnd(_ translation: CGPoint, velocity: CGPoint) {
        print("panGestureDidEnd")

        guard let initialFrame = initialFrame else { return }
        let galleryHeight = initialFrame.height - translation.y

        //if (self.galleryView.topSeparator.frame.height )

        if galleryView.frame.height < GestureConstants.minimumHeight && velocity.y < 0 {
            //print ("showGalleryView")
            collapseGalleryView(nil)

            showGalleryView()
        } else if velocity.y < -GestureConstants.velocity {
            print ("expandGalleryView")
            // expandGalleryView(nil)
        } else if velocity.y > GestureConstants.velocity || galleryHeight < GestureConstants.minimumHeight {
            print ("collapseGalleryView")
            //collapseGalleryView(nil)
        }
    }

//    public func assetsPickerController(_ picker: CTAssetsPickerController!, didFinishPickingAssets assets: [Any]!) {
//        // 1st version
//        //        picker.dismiss(animated: false, completion: nil)
//        //        self.dismiss(animated: true, completion: nil)
//        // 2nd version
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
//
//        print("didFinishPickingAssets")
//        //        for asset in assets {
//        //        self.stack.pushAsset(asset as! PHAsset)
//        //        }
//    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }

    //    public func gotoDetailedGallery() {
    //
    //        var images: [UIImage]
    //        if let preferredImageSize = preferredImageSize {
    //            images = AssetManager.resolveAssets(stack.assets, size: preferredImageSize)
    //        } else {
    //            images = AssetManager.resolveAssets(stack.assets)
    //        }
    //
    //
    //        var photos = [INSPhotoViewable]()
    //        for image in images {
    //            photos.append(INSPhoto(image: image, thumbnailImage: image))
    //        }
    //
    //
    //        for photo in photos {
    //            if let photo = photo as? INSPhoto {
    //                photo.attributedTitle = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.white])
    //            }
    //        }
    //
    //        let currentPhoto = photos[0]
    //        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
    //
    //        galleryPreview.didDismissHandler = { _ in
    //            print("didDismissHandler")
    //            self.resetAssets()
    //        }
    //
    //        present(galleryPreview, animated: true, completion: nil)
    //
    //    }

//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        print("whywhywhy")
//        let animation:GalleryTransitionAnimator2 = GalleryTransitionAnimator2()
//        animation.presenting = true
//        return animation
//    }
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let animation:GalleryTransitionAnimator2 = GalleryTransitionAnimator2()
//        animation.presenting = false
//        return animation
//
//    }






}

//extension ImagePickerController: UIViewControllerTransitioningDelegate
//{
//    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let animation: TransitionForAssetTo2 = TransitionForAssetTo2()
//        animation.presenting = true
//        return animation
//    }
//
//    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let animation: TransitionForAssetFrom2 = TransitionForAssetFrom2()
//        animation.presenting = false
//        return animation
//    }
//
//}
//
//
//
//extension ImagePickerController: RSKImageCropViewControllerDelegate {
//
//
//
//    public func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
//        print("imageCropViewControllerDidCancelCrop sw")
//        controller.dismiss(animated: true)
//        //controller.navigationController?.popViewController(animated: true)
//    }
//
//    public func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
//        print("didCropImage sw")
//        // self.avatarImageView.image = croppedImage
//
//        var images = [UIImage]()
//
//        images.append(croppedImage)
//
//        //  DispatchQueue.main.async {
//        self.delegate?.doneButtonDidPress(self, images:images)
//
//        //}
//
//        //  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//        // _ = self.dismiss(animated: true)
//        //self.dismiss(animated: true)
//
//    //   self.navigationController?.parent?.navigationController?.popViewController(animated: true);
//
//        //self.navCtrl?.popViewController(animated: true)
//
//
//        print("self.navigationController?.viewControllers.count \(String(describing: self.navigationController?.viewControllers.count))")
//
//        //self.navigationController?.popToViewController(self.navCtrl!, animated: true)
//        //self.view.alpha = 0;
//        self.dismiss(animated: true)
//
//
//        //}
//
//
//
//    }

//}

