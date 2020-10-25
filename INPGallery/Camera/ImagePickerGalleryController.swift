import UIKit
import MediaPlayer
import Photos

import PhotosUI
import Device
import SnapKit
import AssetsPickerViewController
import iOSPhotoEditor




private var imageSize = CGSize(width: 70, height: 70)


@objc public protocol ImagePickerGalleryDelegate: class {

    func wrapperDidPress(_ imagePicker: ImagePickerGalleryController, images: [UIImage])
    func doneButtonDidPress(_ imagePicker: ImagePickerGalleryController, images: [UIImage])
    func cancelButtonDidPress(_ imagePicker: ImagePickerGalleryController)
}

//public protocol AssetsPhotoCellDelegate: class {
//    func didPressSelectButton(sender: Any)
//}

open class ImagePickerGalleryController: UIViewController, AXPhotosViewControllerDelegate, AssetsPhotoCellDelegate {


    public func didPressSelectButton(sender: Any) {
        guard let cell = sender as? UICollectionViewCell else { print ("ex1"); return }
        guard let indexPath = self.collectionView.indexPath(for: cell) else {print ("ex2"); return}
        let asset = AssetsManager.shared.assetArray[indexPath.row]
        print("select or deselet asset ",asset)
        if selectedArray.contains(asset) {
         
            deselect(asset: asset, at: indexPath)
          
        }
        else {
           
            select(asset: asset, at: indexPath)
           
        }
        
        
        
    }
    
    lazy var topSeparator: UIView = {
        let topSeparator = UIView()
      //topSeparator.frame = CGRect(x: 0, y: 105, width: 100, height: 5)
      topSeparator.translatesAutoresizingMaskIntoConstraints = false
      //topSeparator.addGestureRecognizer(self.panGestureRecognizer)
      topSeparator.backgroundColor = UIColor.clear
      
      //Configuration.indicatorView.frame = CGRect(x: 0, y: 0, width: 100, height: 5)
      topSeparator.addSubview(Configuration.indicatorView)
        return topSeparator
    }()
    
    var galleryView1: UIView = {
        
        let galleryView = UIView()
        
       // galleryView.backgroundColor = .white
        

        return galleryView
        
    }()
    
    // MARK: Properties
    public var pickerConfig: AssetsPickerConfig {
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.assetCellType = AssetsPhotoCell.classForCoder()
        pickerConfig.albumPortraitForcedCellHeight = imageSize.height
        pickerConfig.albumLandscapeForcedCellHeight = imageSize.height
        pickerConfig.albumForcedCacheSize = imageSize
        pickerConfig.albumDefaultSpace = 1
        pickerConfig.albumLineSpace = 1
        pickerConfig.albumPortraitColumnCount = 1
        pickerConfig.albumLandscapeColumnCount = 1
        
        let config = pickerConfig.prepare()

    
        AssetsManager.shared.pickerConfig = pickerConfig
        AssetsManager.shared.pickerConfig = config

        AssetsManager.shared.registerObserver()
        return config
    }
    
    var viewerPresented: Bool = false
    
    //fileprivate var globalIndexPath: IndexPath?
    
   // fileprivate var previewing: UIViewControllerPreviewing?
    
    fileprivate let cellReuseIdentifier: String = UUID().uuidString
    fileprivate let footerReuseIdentifier: String = UUID().uuidString
    
    fileprivate var requestIdMap = [IndexPath: PHImageRequestID]()
    
    fileprivate lazy var cancelButtonItem: UIBarButtonItem = {
        //let buttonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
        //                                 target: self,
        //                                 action: #selector(pressedCancel(button:)))
        
        let button = UIButton(frame: CGRect(x: 20, y: 0, width: 44, height: 44))
        button.setImage(UIImage(named:"left_arrow"), for: .normal)
        button.addTarget(self, action: #selector(pressedTitle), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonItem = UIBarButtonItem(customView: button)

        
        return buttonItem
    }()
    
   
    
    fileprivate lazy var doneButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                              target: self,
                                              action: #selector(pressedDone(button:)))
        return buttonItem
    }()
    fileprivate let emptyView: AssetsEmptyView = {
        return AssetsEmptyView()
    }()
    fileprivate let noPermissionView: AssetsNoPermissionView = {
        return AssetsNoPermissionView()
    }()
    fileprivate var delegate: AssetsPickerViewControllerDelegate? {
        return (navigationController as? AssetsPickerViewController)?.pickerDelegate
    }
    
    fileprivate var picker: AssetsPickerViewController {
        return navigationController as! AssetsPickerViewController
    }
    fileprivate var tapGesture: UITapGestureRecognizer?
    fileprivate var longTapGesture: UILongPressGestureRecognizer?

    fileprivate var syncOffsetRatio: CGFloat = -1
    
    fileprivate var selectedArray = [PHAsset]()
    fileprivate var selectedMap = [String: PHAsset]()
    
    fileprivate var didSetInitialPosition: Bool = false
    
    fileprivate var isPortrait: Bool = true
    fileprivate var contentSize: CGSize?


    
    var leadingConstraint: LayoutConstraint?
    var trailingConstraint: LayoutConstraint?
    
    fileprivate lazy var collectionView: UICollectionView = {
        
        let layout = AssetsPhotoGalleryLayout(pickerConfig: self.pickerConfig)
        //layout.estimatedItemSize =  imageSize
        self.updateLayout(layout: layout, isPortrait: UIApplication.shared.statusBarOrientation.isPortrait)
        layout.scrollDirection = .horizontal
        
    
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.allowsMultipleSelection = true
        view.alwaysBounceVertical = false
        
       // view.alwaysBounceHorizontal = false
        
        view.register(self.pickerConfig.assetCellType, forCellWithReuseIdentifier: self.cellReuseIdentifier)
        view.register(AssetsPhotoFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: self.footerReuseIdentifier)
       // view.contentInset = UIEdgeInsets(top: 1, left: 100, bottom: 0, right: 0)
        if #available(iOS 13.0, *) {
            //view.adjustedContentInset = true
        }
    
        view.backgroundColor = UIColor.clear
        view.dataSource = self
        view.delegate = self
  //      view.remembersLastFocusedIndexPath = true
//        if #available(iOS 10.0, *) {
            view.prefetchDataSource = self
//        }
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        

        
        return view
    }()
    
    var selectedAssets: [PHAsset] {
        return selectedArray
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
//    override open func loadView() {
//        super.loadView()
//        view = UIView()
//        view.backgroundColor = .white
//        view.addSubview(collectionView)
//        view.addSubview(emptyView)
//        view.addSubview(noPermissionView)
//        //view.addSubview(toolbar)
//
//
//
//        view.setNeedsUpdateConstraints()
//    }
    
    
    
        
       


    struct GestureConstants {
        static let maximumHeight: CGFloat = 200
        static let minimumHeight: CGFloat = 115
        static let velocity: CGFloat = 150
    }

    var photoModeOnly = false


//    open lazy var galleryView: ImageGalleryView = { [unowned self] in
//        let galleryView = ImageGalleryView()
//        galleryView.delegate = self
//        galleryView.selectedStack = self.stack
//        galleryView.collectionView.layer.anchorPoint = CGPoint(x: 0, y: 0)
//        galleryView.imageLimit = self.imageLimit
//        return galleryView
//        }()

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

   // open weak var delegate: ImagePickerGalleryDelegate?
    open var stack = ImageStack()
    open var imageLimit = 0
    open var preferredImageSize: CGSize?
    open var startOnFrontCamera = false
    var totalSize: CGSize { return UIScreen.main.bounds.size }
    var initialFrame: CGRect?
    var initialContentOffset: CGPoint?
  //  var initialContentSize: CGSize?
  //  var initialContentInset: CGFloat?
    
    var startingImageSize = CGFloat(0)
    
    var coeff = CGFloat(1)
    var maxPath = 0
    
    var numberOfCells: Int = 1
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
    
    
  


    open override func viewDidLoad() {
        super.viewDidLoad()

        //gallery code
     
        
        self.transitioningDelegate = self

        setupCommon()
        
        updateEmptyView(count: 0)
        updateNoPermissionView()
        
        
        if let selectedAssets = self.pickerConfig.selectedAssets {
            setSelectedAssets(assets: selectedAssets)
        }
        
        AssetsManager.shared.authorize { [weak self] (isGranted) in
            guard let `self` = self else { return }
            self.updateNoPermissionView()
            if isGranted {
                self.setupAssets()
            } else {
                self.delegate?.assetsPickerCannotAccessPhotoLibrary?(controller: self.picker)
            }
        }
        
        //setupBarButtonItems()

        //


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
                      //  galleryView,
                        bottomContainer,
                        topView,
                        timerCamera,
                        reddot
            ] {
                            if(!(self.photoModeOnly)) {
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
        view.addSubview(galleryView1)

        setupGalleryView()
        galleryView1.addSubview(collectionView)
        galleryView1.addSubview(emptyView)
        galleryView1.addSubview(noPermissionView)
        setupCollectionView()
        galleryView1.clipsToBounds = true
        galleryView1.addSubview(topSeparator)



    }
    
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print("<><><><>viewDidLayoutSubviews")

        if !didSetInitialPosition {
            if pickerConfig.assetsIsScrollToBottom {
                let count = AssetsManager.shared.assetArray.count
                if count > 0 {
                    if self.collectionView.collectionViewLayout.collectionViewContentSize.height > 0 {
                        let lastRow = self.collectionView.numberOfItems(inSection: 0) - 1
                        print("<><><><>scrollToBottom")
                        self.collectionView.scrollToItem(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: false)
                    }
                }
            }
            didSetInitialPosition = true
        }
        
//        if(view.frame.width > view.frame.height){
//           statusView.button.frame =  CGRect(x: 0, y: 5, width: 35, height: 35)
//        }
//        else {
//            statusView.button.frame =  CGRect(x: 0, y: 0, width: 35, height: 35)
//
//        }
        
    }
    
    open func deselectAll() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        
        indexPaths.forEach({ [weak self] (indexPath) in
            let asset = AssetsManager.shared.assetArray[indexPath.row]
            self?.deselect(asset: asset, at: indexPath)
            self?.delegate?.assetsPicker?(controller: picker, didDeselect: asset, at: indexPath)
        })
        updateNavigationStatus()
        collectionView.reloadItems(at: indexPaths)
    }
    
    @available(iOS 11.0, *)
    override open func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        leadingConstraint?.constant = view.safeAreaInsets.left
        trailingConstraint?.constant = -view.safeAreaInsets.right
        
        updateLayout(layout: collectionView.collectionViewLayout)
        print("view.safeAreaInsets\(view.safeAreaInsets)")
    }
    
//    func setStatusViewPosition(_ isPortrait: Bool) {
//                            if (!isPortrait) {
//                                print("NOT PORTRAIT")
//                                             self.statusView.button.frame =  CGRect(x: 0, y: 3, width: 35, height: 35)
//                                       self.statusView.frame =  CGRect(x: 0, y: 3, width: 35, height: 35)
//
//
//                                         } else {
//                                      print("PORTRAIT")
//
//                                             self.statusView.button.frame =  CGRect(x: 0, y: 0, width: 35, height: 35)
//                                           self.statusView.frame =  CGRect(x: 0, y: 0, width: 35, height: 35)
//
//                                         }
//    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("<><><><>viewWillTransition")

        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.layer.speed = 1.2
        self.view.layer.speed = 1.0

        let isPortrait = size.height > size.width
        let contentSize = CGSize(width: size.width, height: size.height)
        
        
            print("<><>self.collectionView.collectionViewLayout0 \(contentSize)")
        
        
        if (!isPortrait) {
            leadingConstraint?.constant = 44;
            trailingConstraint?.constant = -44;

     
        } else {
            leadingConstraint?.constant = 0;
            trailingConstraint?.constant = 0;
            
        }
        
      //  setStatusViewPosition(isPortrait)
        
       
        
        if let photoLayout = collectionView.collectionViewLayout as? AssetsPhotoLayout {
            if let offset = photoLayout.translateOffset(forChangingSize: contentSize, currentOffset: collectionView.contentOffset) {
                photoLayout.translatedOffset = offset
                print("translated offset: \(offset)")


            }
            
            coordinator.animate(alongsideTransition: { (_) in
                
            }, completion: { (_) in
               photoLayout.translatedOffset = nil
                
                self.contentSize = contentSize
                 print("<><>self.collectionView.collectionViewLayout2 \(self.collectionView.collectionViewLayout.collectionViewContentSize)")

                print("<><>self.collectionView.collectionViewLayout3 \(self.collectionView.collectionViewLayout.collectionViewContentSize)")
                print("<><>self.collectionView.collectionViewLayout4 \(self.collectionView.contentSize)")

            })
            
        }
        
       
       // print("<><>self.collectionView.collectionViewLayout1 \(self.collectionView.collectionViewLayout.collectionViewContentSize)")
        self.updateLayout(layout: self.collectionView.collectionViewLayout, isPortrait: isPortrait)
      
       
    }
    
   // private var statusView = ButtonStatusView(frame: CGRect(x: 0, y: 0, width: 35, height: 35),count: 0)
    //var barSelectionStatusButton: UIBarButtonItem?

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
       
            statusBarHidden = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {// выход из галереи в камере, чтобы не залипало
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        }
      


    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


        Configuration.indicatorView.frame = CGRect(x: (galleryView1.frame.width - Configuration.indicatorWidth) / 2, y: 0,
          width: Configuration.indicatorWidth, height: Configuration.indicatorHeight)



//        if (!viewWasLoaded) {
//
//            let galleryHeight: CGFloat = UIScreen.main.nativeBounds.height == 960
//                ? ImageGalleryView.Dimensions.galleryBarHeight : GestureConstants.minimumHeight
//
//            galleryView.collectionView.transform = CGAffineTransform.identity
//            galleryView.collectionView.contentInset = UIEdgeInsets.zero
//
//            galleryView.frame = CGRect(x: 0,
//                                       y: totalSize.height - bottomContainer.frame.height - 55 - galleryHeight,
//                                       width: totalSize.width,
//                                       height: galleryHeight)
//            galleryView.updateFrames()
//            checkStatus()
//
            initialFrame = galleryView1.frame
            initialContentOffset = self.collectionView.contentOffset
//            viewWasLoaded = true
//
//            //galleryView.topSeparator.addSubview(Configuration.indicatorView)
//
//        }

        


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
       // galleryView.fetchPhotos()
       // galleryView.canFetchImages = false
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
//        galleryView.collectionView.reloadData()
//        galleryView.collectionView.setContentOffset(CGPoint.zero, animated: false)
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
//        galleryView.collectionViewLayout.invalidateLayout()
//        UIView.animate(withDuration: 0.3, animations: {
//            self.updateGalleryViewFrames(self.galleryView.topSeparator.frame.height, 0)
//            self.galleryView.collectionView.transform = CGAffineTransform.identity
//            self.galleryView.collectionView.contentInset = UIEdgeInsets.zero
//            self.galleryView.collectionView.frame.size.height = 0;
//            self.galleryView.layoutIfNeeded()
//
//        }, completion: { _ in
//            completion?()
//        })
    }

    open func showGalleryView() {
//        galleryView.collectionViewLayout.invalidateLayout()
//        UIView.animate(withDuration: 0.3, animations: {
//            self.updateGalleryViewFrames(GestureConstants.minimumHeight, 96)
//            self.galleryView.collectionView.transform = CGAffineTransform.identity
//            self.galleryView.collectionView.contentInset = UIEdgeInsets.zero
//        })
    }

    open func expandGalleryView(_ completion: (() -> Void)?) {
//        self.galleryView.layoutIfNeeded()
//
//        UIView.animate(withDuration: 0.3, animations: {
//            self.updateGalleryViewFrames(GestureConstants.maximumHeight, 176)
//            let scale = (GestureConstants.maximumHeight - ImageGalleryView.Dimensions.galleryBarHeight) / (GestureConstants.minimumHeight - ImageGalleryView.Dimensions.galleryBarHeight)
//            self.galleryView.collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
//
//            let value = self.view.frame.width * (scale - 1) / scale
//            self.galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  value)
//
//
//        },
//                       completion: { _ in
//                        completion?()
//                        // self.galleryView.topSeparator.isUserInteractionEnabled = true;
//        })
    }

    func updateGalleryViewFrames(_ constant: CGFloat, _ height: CGFloat) {
//        galleryView.frame.origin.y = totalSize.height - bottomContainer.frame.height - constant
//        galleryView.frame.size.height = constant
//        galleryView.collectionView.frame.size.height = height;
    }

    func enableGestures(_ enabled: Bool) {
//        galleryView.alpha = enabled ? 1 : 0
//        bottomContainer.pickerButton.isEnabled = enabled
//        bottomContainer.tapGestureRecognizer.isEnabled = enabled
//        topView.flashButton.isEnabled = enabled
//        topView.rotateCamera.isEnabled = Configuration.canRotateCamera
    }

    fileprivate func isBelowImageLimit() -> Bool {
        return (imageLimit == 0
                    //|| imageLimit > galleryView.selectedStack.assets.count
        )
    }

    fileprivate func takePicture() {
        print("play takePicture")
        //self.resetAssets()
        guard isBelowImageLimit() && !isTakingPicture else {
            return }
        isTakingPicture = true
        bottomContainer.pickerButton.isEnabled = false
        //  bottomContainer.stackView.startLoader()
        print("play takePicture2")

        let action: () -> Void = { [unowned self] in
            self.cameraController.takePicture {
                print("play takePicture3")


                self.isTakingPicture = false
                self.bottomContainer.pickerButton.numberLabel.text = ""

            }

        }
        
        action()

//        if Configuration.collapseCollectionViewWhileShot {
//            collapseGalleryView(action)
//        } else {
//            action()
//        }
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

extension ImagePickerGalleryController: BottomContainerViewDelegate {

    func pickerButtonDidPress() {
        print("ImagePickerGalleryController pickerButtonDidPress")
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

        //delegate?.doneButtonDidPress(self, images: images)
    }

    func cancelButtonDidPress() {
        dismiss(animated: true, completion: nil)
        //delegate?.cancelButtonDidPress(self)
    }

    func imageStackViewDidPress() {
        var images: [UIImage]
        if let preferredImageSize = preferredImageSize {
            images = AssetManager.resolveAssets(stack.assets, size: preferredImageSize)
        } else {
            images = AssetManager.resolveAssets(stack.assets)
        }

     


       // delegate?.wrapperDidPress(self, images: images)
    }
}

extension ImagePickerGalleryController: CameraViewDelegate {
   
    func cameraManDidPhoto(_ photo: AVCapturePhoto) {
                print("Image captured.")
                    if let imageData = photo.fileDataRepresentation() {
                        if let uiImage = UIImage(data: imageData){
                            // do stuff to UIImage
                            let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))

                            //PhotoEditorDelegate

                            //The image to be edited
                            photoEditor.image = uiImage
                            photoEditor.modalPresentationStyle = .fullScreen

                            present(photoEditor, animated: false, completion: nil)


                        }
                    }
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
//        guard let collectionSize = galleryView.collectionSize else { return }
//
//
//
//        galleryView.shouldTransform = true
//        bottomContainer.pickerButton.isEnabled = true
//
//        UIView.animate(withDuration: 0.3, animations: {
//            self.galleryView.collectionView.transform = CGAffineTransform(translationX: collectionSize.width, y: 0)
//        }, completion: { _ in
//            self.galleryView.collectionView.transform = CGAffineTransform.identity
//
//
//            self.resetAssets()
//
//        })



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

        //    self.galleryView.collectionViewLayout.invalidateLayout()

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

extension ImagePickerGalleryController: TopViewDelegate {

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

extension ImagePickerGalleryController: ImageGalleryPanGestureDelegate {

    func panGestureDidStart() {
        print("panGestureDidStart")
//        guard let collectionSize = galleryView.collectionSize else { return }
//
        initialFrame = galleryView1.frame
        initialContentOffset = collectionView.contentOffset
        
        
        guard let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            print ("return ")
            return
        }
      //  initialContentSize = flowLayout.collectionViewContentSize
        
       // initialContentInset = flowLayout.sectionInset.left

        
        numberOfCells = Int(initialContentOffset!.x / CGFloat(imageSize.width))
        startingImageSize = imageSize.width
       
//        collectionView.indexPathsForVisibleItems.forEach { indPath in
//            if (indPath.item > maxPath){
//            maxPath = indPath.item
//            }
//        }

    }

    @objc func panGestureRecognizerHandler(_ gesture: UIPanGestureRecognizer) {
        //print("panGestureRecognizerHandler")

        let translation = gesture.translation(in: view)
                let velocity = gesture.velocity(in: view)
        
                if gesture.location(in: view).y > galleryView1.frame.origin.y - 20 {
                    gesture.state == .began ? panGestureDidStart() : panGestureDidChange(translation)
                }

        panGestureDidChange(translation)


                if gesture.state == .ended {
                    panGestureDidEnd(translation, velocity: velocity)
                }
    }

    func panGestureDidChange(_ translation: CGPoint) {

        guard let initialFrame = initialFrame else { return }
        let galleryHeight = initialFrame.height - translation.y
        
        guard let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            print ("return ")
            return
        }
      
        if galleryHeight >= 130 { return }
        print("galleryHeight \(galleryHeight)")
        
        galleryView1.snp.updateConstraints { (make) in
            make.height.equalTo(galleryHeight)
        }
        

        if galleryHeight <= 71 {
           
                }
        
        else {
            
          // MARK: Logic by moving offset during expanding of gallery
           
            collectionView.snp.updateConstraints { (make) in
                make.height.equalTo(galleryHeight - 10)
                    //make.height.equalTo(40)
                }
            imageSize = CGSize(width: galleryHeight - 20, height: galleryHeight - 20)
            
                flowLayout.itemSize = imageSize
            
            print("()---- initialContentOffset!.x  \(initialContentOffset!.x)")
            print("()---- translation.y            \(translation.y)")
            print("()---- numberOfCells            \(numberOfCells)")
 
            var offset = initialContentOffset!.x - translation.y
            offset = offset - (startingImageSize - imageSize.width) * CGFloat(numberOfCells)
            self.collectionView.setContentOffset(CGPoint(x: offset, y: initialContentOffset!.y), animated: false)

        }
    }

    
   


    func panGestureDidEnd(_ translation: CGPoint, velocity: CGPoint) {
        print("panGestureDidEnd")
        //initialFrame = galleryView1.frame
        initialContentOffset = collectionView.contentOffset
        numberOfCells = Int(initialContentOffset!.x / CGFloat(imageSize.width))

        guard let initialFrame = initialFrame else { return }
        let galleryHeight = initialFrame.height - translation.y
//
//        //if (self.galleryView.topSeparator.frame.height )
//
//        if galleryView.frame.height < GestureConstants.minimumHeight && velocity.y < 0 {
//            //print ("showGalleryView")
//            collapseGalleryView(nil)
//
//            showGalleryView()
//        } else if velocity.y < -GestureConstants.velocity {
//            print ("expandGalleryView")
//            // expandGalleryView(nil)
//        } else if velocity.y > GestureConstants.velocity || galleryHeight < GestureConstants.minimumHeight {
//            print ("collapseGalleryView")
//            //collapseGalleryView(nil)
//        }
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

//    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        if UIDevice.current.orientation.isLandscape {
//            print("Landscape")
//        } else {
//            print("Portrait")
//        }
//    }

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

extension ImagePickerGalleryController {
    
    func setupCommon() {
        view.backgroundColor = .clear
       
        
    }
    
    func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = cancelButtonItem
        //navigationItem.rightBarButtonItem = doneButtonItem
        //doneButtonItem.isEnabled = false
    }
    
    func setupGalleryView() {
        
        galleryView1.snp.makeConstraints { (make) in
            //make.top.equalToSuperview()
            
            make.height.equalTo(90)
            if #available(iOS 11.0, *) {
                leadingConstraint = make.leading.equalToSuperview().inset(view.safeAreaInsets.left).constraint.layoutConstraints.first
                trailingConstraint = make.trailing.equalToSuperview().inset(view.safeAreaInsets.right).constraint.layoutConstraints.first
            } else {
                leadingConstraint = make.leading.equalToSuperview().constraint.layoutConstraints.first
                trailingConstraint = make.trailing.equalToSuperview().constraint.layoutConstraints.first
            }
            
            make.bottom.equalToSuperview().inset(200)
        }
        
    }
    
    
    func setupCollectionView() {
        
        collectionView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(80)
            
                //make.height.equalTo(40)
            }

       
//        collectionView.snp.makeConstraints { (make) in
//            //make.top.equalToSuperview()
//
//            make.height.equalTo(100)
//            if #available(iOS 11.0, *) {
//                leadingConstraint = make.leading.equalToSuperview().inset(view.safeAreaInsets.left).constraint.layoutConstraints.first
//                trailingConstraint = make.trailing.equalToSuperview().inset(view.safeAreaInsets.right).constraint.layoutConstraints.first
//            } else {
//                leadingConstraint = make.leading.equalToSuperview().constraint.layoutConstraints.first
//                trailingConstraint = make.trailing.equalToSuperview().constraint.layoutConstraints.first
//            }
//
//            make.bottom.equalToSuperview().inset(0)
//        }
//
//        emptyView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//
//        noPermissionView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
    }
    
    func setupAssets() {
        let manager = AssetsManager.shared
        manager.subscribe(subscriber: self)
        manager.fetchAlbums()
        manager.fetchAssets() { [weak self] photos in
            
            guard let `self` = self else { return }
            
            self.updateEmptyView(count: photos.count)
            self.title = self.title(forAlbum: manager.selectedAlbum)
            
            if self.selectedArray.count > 0 {
                self.collectionView.performBatchUpdates({ [weak self] in
                    self?.collectionView.reloadData()
                    }, completion: { [weak self] (finished) in
                        guard let `self` = self else { return }
                        // initialize preselected assets
                        self.selectedArray.forEach({ [weak self] (asset) in
                            if let row = photos.firstIndex(of: asset) {
                                let indexPathToSelect = IndexPath(row: row, section: 0)
                                self?.collectionView.selectItem(at: indexPathToSelect, animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
                            }
                        })
                        self.updateSelectionCount()
                })
            }
        }
    }
    
    func setupGestureRecognizer() {
        if let _ = self.tapGesture {
            // ignore
        } else {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(pressedTitle))
            navigationController?.navigationBar.addGestureRecognizer(gesture)
            gesture.delegate = self
            tapGesture = gesture
        }
        
//        if let _ = self.longTapGesture {
//            // ignore
//        } else {
//            let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//            lpgr.minimumPressDuration = 0.5
//            lpgr.delegate = self
//            lpgr.delaysTouchesBegan = true
//            self.collectionView.addGestureRecognizer(lpgr)
//            longTapGesture = lpgr
//        }
    }
    
//    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
//
//
//
//        if (gestureRecognizer.state != UIGestureRecognizer.State.ended){
//            return
//        }
//
//        let p = gestureRecognizer.location(in: self.collectionView)
//
//        print("handle long press")
//        if let indexPath = (self.collectionView.indexPathForItem(at: p)){
//
//
//            var picture:UIImage?
//                    self.image(forAsset: AssetsManager.shared.assetArray[indexPath.row], completion: { (image) in
//                        picture = image
//                    })
//
//
//
//
////                    let photo1:AXPhotoProtocol = AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageAsset:AssetsManager.shared.assetArray[indexPath.row],  imageData: nil, image: nil, url: nil)
////                    let photo2:AXPhotoProtocol = AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageAsset: AssetsManager.shared.assetArray[indexPath.row], imageData: nil, image: nil, url: nil)
////                    let photos = [photo1, photo2]
//
//                    let dataSource = AXPhotosDataSource(photos: AssetsManager.shared.photoArray, initialPhotoIndex: indexPath.row, prefetchBehavior: .aggressive)
//
//
//
//            let cell = self.collectionView.cellForItem(at: indexPath) as! AssetsPhotoCellProtocol
////
////
//            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: false, startingView: cell.imageView) { [weak self] (photo, index) -> UIImageView? in
//                // this closure can be used to adjust your UI before returning an `endingImageView`.
//                let endingIndexPath = IndexPath(item: index, section: 0)
//                self?.collectionView.scrollToItem(at: endingIndexPath, at: [.centeredVertically], animated: false)
//
//                if let endingCell = self?.collectionView.cellForItem(at: endingIndexPath) {
//                return (endingCell as! AssetsPhotoCellProtocol).imageView
//                }
//                return nil
//            }
//
//
//            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)
//
//            photosViewController.delegate = self
//
//
//
//
//            self.present(photosViewController, animated: true, completion: {})
//
//
//
//
//        }
//
//    }
    
    public func photosViewController(_ photosViewController: AXPhotosViewController, didNavigateTo photo: AXPhotoProtocol, at index: Int) {
        let endingIndexPath = IndexPath(item: index, section: 0)
        //self.globalIndexPath = endingIndexPath
        self.collectionView.scrollToItem(at: endingIndexPath, at: [.centeredVertically], animated: false)
    }
    
    public func photosViewController(_ photosViewController: AXPhotosViewController, didSelectPhoto photo: AXPhotoProtocol, at index: Int) {
        print("photoIndex in didSelectPhoto - \(index)")
        let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0))
        guard let indexPath = self.collectionView.indexPath(for: cell!) else {print ("ex2"); return}
        let asset = AssetsManager.shared.assetArray[indexPath.row]
        if selectedArray.contains(asset) {
            //cell!.isSelected = false
            print("hey2")

            deselect(asset: asset, at: indexPath)
            updateNavigationStatus()
            delegate?.assetsPicker?(controller: picker, didDeselect: asset, at: indexPath)
        }
        else {

            //cell?.isSelected = true
            select(asset: asset, at: indexPath)
            updateNavigationStatus()
            delegate?.assetsPicker?(controller: picker, didSelect: asset, at: indexPath)
        }
        
        self.collectionView.reloadData() //!!! do not remove
        
        
        
    }
    
    func removeGestureRecognizer() {
        if let tapGesture = self.tapGesture {
            navigationController?.navigationBar.removeGestureRecognizer(tapGesture)
            self.tapGesture = nil
        }
        if let longTapGesture = self.longTapGesture {
             self.collectionView.removeGestureRecognizer(longTapGesture)
            self.longTapGesture = nil
        }
    }
}

// MARK: - Internal APIs for UI
extension ImagePickerGalleryController {
    
    func updateEmptyView(count: Int) {
        if emptyView.isHidden {
            if count == 0 {
                emptyView.isHidden = false
            }
        } else {
            if count > 0 {
                emptyView.isHidden = true
            }
        }
        
        
        logi("emptyView.isHidden: \(emptyView.isHidden), count: \(count)")
    }
    
    func updateNoPermissionView() {
        noPermissionView.isHidden = PHPhotoLibrary.authorizationStatus() == .authorized
        logi("isHidden: \(noPermissionView.isHidden)")
    }
    
    func updateLayout(layout: UICollectionViewLayout, isPortrait: Bool? = nil) {
        guard let flowLayout = layout as? UICollectionViewFlowLayout else {
            print ("return ")
            return }
       
        flowLayout.itemSize = imageSize
  
        flowLayout.minimumLineSpacing = 3
        flowLayout.minimumInteritemSpacing = 3
        
        print ("flowLayout.itemSize \(flowLayout.itemSize) ")
        print ("flowLayout.minimumLineSpacing  \(flowLayout.minimumLineSpacing ) ")
        print ("flowLayout.minimumInteritemSpacing \(flowLayout.minimumInteritemSpacing ) ")

    }
    
    func setSelectedAssets(assets: [PHAsset]) {
        selectedArray.removeAll()
        selectedMap.removeAll()
        
        _ = assets.filter { AssetsManager.shared.isExist(asset: $0) }
            .map { [weak self] asset in
                guard let `self` = self else { return }
                self.selectedArray.append(asset)
                self.selectedMap.updateValue(asset, forKey: asset.localIdentifier)
        }
    }
    
    func select(album: PHAssetCollection) {
        if AssetsManager.shared.select(album: album) {
            // set title with selected count if exists
            if selectedArray.count > 0 {
                updateNavigationStatus()
            } else {
                title = title(forAlbum: album)
            }
            collectionView.reloadData()
            
            for asset in selectedArray {
                if let index = AssetsManager.shared.assetArray.firstIndex(of: asset) {
                    logi("reselecting: \(index)")
                    collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .init(rawValue: 0))
                }
            }
            if AssetsManager.shared.assetArray.count > 0 {
                if pickerConfig.assetsIsScrollToBottom == true {
                    collectionView.scrollToItem(at: IndexPath(row: AssetsManager.shared.assetArray.count - 1, section: 0), at: .bottom, animated: false)
                } else {
                    collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                }
            }
        }
    }
    
    func select(asset: PHAsset, at indexPath: IndexPath) {
        if let _ = selectedMap[asset.localIdentifier] {
            logw("Invalid status.")
            return
        }
        selectedArray.append(asset)
        selectedMap[asset.localIdentifier] = asset
        
        // update selected UI
        guard var photoCell = collectionView.cellForItem(at: indexPath) as? AssetsPhotoCellProtocol else {
            logw("Invalid status.")
            return
        }
        photoCell.count = selectedArray.count
        updateStatusButton()
        
        //self.collectionView.layoutSubviews()

    }
    
    func deselect(asset: PHAsset, at indexPath: IndexPath) {
        guard let targetAsset = selectedMap[asset.localIdentifier] else {
            print("Invalid status in deselect1.")
            return
        }
        guard let targetIndex = selectedArray.firstIndex(of: targetAsset) else {
            print("Invalid status in deselect2.")
            return
        }
        selectedArray.remove(at: targetIndex)
        selectedMap.removeValue(forKey: targetAsset.localIdentifier)
        updateStatusButton()
        updateSelectionCount()
        
        //self.collectionView.layoutSubviews()

    }
    
    
    func updateStatusButton() {
        
       // self.statusView.updateStatusView(count: selectedArray.count, animated: true)

    }
    
    func updateSelectionCount() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for visibleIndexPath in visibleIndexPaths {
            //print("visibleIndexPath in visibleIndexPaths")
            guard AssetsManager.shared.assetArray.count > visibleIndexPath.row else {
                logw("Referred wrong index\(visibleIndexPath.row) while asset count is \(AssetsManager.shared.assetArray.count).")
                break
            }
            if let selectedAsset = selectedMap[AssetsManager.shared.assetArray[visibleIndexPath.row].localIdentifier], var photoCell = collectionView.cellForItem(at: visibleIndexPath) as? AssetsPhotoCellProtocol {
                if let selectedIndex = selectedArray.firstIndex(of: selectedAsset) {
                    photoCell.count = selectedIndex + 1
                }
            }
        }

    }
    
    func updateNavigationStatus() {
        
        doneButtonItem.isEnabled = selectedArray.count >= (pickerConfig.assetsMinimumSelectionCount > 0 ? pickerConfig.assetsMinimumSelectionCount : 1)
        
        let counts: (imageCount: Int, videoCount: Int) = selectedArray.reduce((0, 0)) { (result, asset) -> (Int, Int) in
            let imageCount = asset.mediaType == .image ? 1 : 0
            let videoCount = asset.mediaType == .video ? 1 : 0
            return (result.0 + imageCount, result.1 + videoCount)
        }
        
        let imageCount = counts.imageCount
        let videoCount = counts.videoCount
        
        var titleString: String = title(forAlbum: AssetsManager.shared.selectedAlbum)
        
//        if imageCount > 0 && videoCount > 0 {
//            titleString = String(format: String(key: "Title_Selected_Items"), NumberFormatter.decimalString(value: imageCount + videoCount))
//        } else {
//            if imageCount > 0 {
//                if imageCount > 1 {
//                    titleString = String(format: String(key: "Title_Selected_Photos"), NumberFormatter.decimalString(value: imageCount))
//                } else {
//                    titleString = String(format: String(key: "Title_Selected_Photo"), NumberFormatter.decimalString(value: imageCount))
//                }
//            } else if videoCount > 0 {
//                if videoCount > 1 {
//                    titleString = String(format: String(key: "Title_Selected_Videos"), NumberFormatter.decimalString(value: videoCount))
//                } else {
//                    titleString = String(format: String(key: "Title_Selected_Video"), NumberFormatter.decimalString(value: videoCount))
//                }
//            }
//        }
//        title = titleString
    }
    
    func updateFooter() {
        guard let footerView = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).last as? AssetsPhotoFooterView else {
            return
        }
        footerView.set(imageCount: AssetsManager.shared.count(ofType: .image), videoCount: AssetsManager.shared.count(ofType: .video))
    }
    
    
    func presentAlbumController(animated: Bool = true) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        let navigationController = UINavigationController()
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = false
        }
        let controller = AssetsAlbumViewController(pickerConfig: self.pickerConfig)
        controller.delegate = self
        //navigationController.viewControllers = [controller]
        
        
       // self.navigationController?.present(navigationController, animated: animated, completion: nil)
        
        
         self.navigationController?.pushViewController(controller, animated: true)
        
        
        
        ////  self.navigationController?.popViewController(animated: true)
        
        
        //self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
        
    }
    
    
    func presentAlbumControllerBackButton(animated: Bool = true) {
        self.navigationController?.popToRootViewController(animated: true)
    

    }
    
    func title(forAlbum album: PHAssetCollection?) -> String {
        var titleString: String!
        if let albumTitle = album?.localizedTitle {
            titleString = "\(albumTitle)"
        } else {
            titleString = ""
        }
        return titleString
    }
}

// MARK: - UI Event Handlers
extension ImagePickerGalleryController {
    
    @objc func pressedCancel(button: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: {
            self.delegate?.assetsPicker?(controller: self.picker, didDismissByCancelling: true)
        })
        delegate?.assetsPickerDidCancel?(controller: picker)
    }
    
    @objc func pressedDone(button: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: {
            self.delegate?.assetsPicker?(controller: self.picker, didDismissByCancelling: false)
        })
        delegate?.assetsPicker(controller: picker, selected: selectedArray)
    }
    
    @objc func pressedTitle(gesture: UITapGestureRecognizer) {
       // presentAlbumController()
        presentAlbumControllerBackButton()

    }
    
    @objc func pressedBackToAlbumsButton(gesture: UITapGestureRecognizer) {
        presentAlbumControllerBackButton()
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension ImagePickerGalleryController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let navigationBar = navigationController?.navigationBar else { return false }
        let point = touch.location(in: navigationBar)
        // Ignore touches on navigation buttons on both sides.
        return point.x > navigationBar.bounds.width / 4 && point.x < navigationBar.bounds.width * 3 / 4
    }
}

// MARK: - UIScrollViewDelegate
extension ImagePickerGalleryController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        logi("contentOffset: \(scrollView.contentOffset)")
    }
}

// MARK: - UICollectionViewDelegate
extension ImagePickerGalleryController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let delegate = self.delegate {
            return delegate.assetsPicker?(controller: picker, shouldSelect: AssetsManager.shared.assetArray[indexPath.row], at: indexPath) ?? true
        } else {
            return true
        }
    }
    

    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        initialContentOffset = self.collectionView.contentOffset
        numberOfCells = Int(initialContentOffset!.x / CGFloat(imageSize.width))

    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")

        initialContentOffset = self.collectionView.contentOffset
        numberOfCells = Int(initialContentOffset!.x / CGFloat(imageSize.width))

    }
    
        
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        let asset = AssetsManager.shared.assetArray[indexPath.row]
//
//        select(asset: asset, at: indexPath)
//        updateNavigationStatus()
//        delegate?.assetsPicker?(controller: picker, didSelect: asset, at: indexPath)
        
        print("didSelectItemAt --> select")
        
        let dataSource = AXPhotosDataSource(photos: AssetsManager.shared.photoArray, selectedPhotos: selectedArray, initialPhotoIndex: indexPath.row, prefetchBehavior: .aggressive)
        
        
        
        let cell = self.collectionView.cellForItem(at: indexPath) as! AssetsPhotoCellProtocol
        //cell.isSelected  = false

//        self.collectionView.cellForItem(at: indexPath)?.isSelected  = false

        //
        //
        let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: false, startingView: cell.imageView) { [weak self] (photo, index) -> UIImageView? in
            // this closure can be used to adjust your UI before returning an `endingImageView`.
//            print("<><><><>self?.isPortrait \(self?.isPortrait)")
//            print("<><><><>self?.contentSize \(self?.contentSize)")

            let layout = self?.collectionView.collectionViewLayout;
            self?.updateLayout(layout: layout! , isPortrait: self?.isPortrait)

//            print("<><><><>self?.collectionView1 \(self?.collectionView)")
//            print("<><><><>self?.collectionView2 \(self?.collectionView)")
//            print("<><>index \(index)")
            let endingIndexPath = IndexPath(item: index, section: 0)
           
            self?.collectionView.scrollToItem(at: endingIndexPath, at: [.centeredVertically], animated: false)
            
            if let endingCell = self?.collectionView.cellForItem(at: endingIndexPath) {
                let endingCellT = endingCell as! AssetsPhotoCell
                endingCellT.selectButton.alpha = 0
                endingCellT.emptyButton.alpha = 0
                UIView.animate(withDuration: 0.2, delay: 0.5, options: [.allowUserInteraction, .curveEaseIn], animations: {
                           endingCellT.emptyButton.alpha = 1
                         endingCellT.selectButton.alpha = 1
                       }
                )
                
                return (endingCell as! AssetsPhotoCellProtocol).imageView
            }
            
            return nil
        }
        
        self.collectionView.deselectItem(at: indexPath, animated: false)
        
        let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)
        
        photosViewController.delegate = self
        
    //    self.globalIndexPath = indexPath
        self.viewerPresented = true
        //photosViewController.modalPresentationStyle = .fullScreen
        photosViewController.modalPresentationStyle = .overCurrentContext
        //photosViewController.view.backgroundColor = UIColor.clear
        //self.definesPresentationContext = true
        self.present(photosViewController, animated: true, completion: {})
        
        

        
    }
    
//    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        if let delegate = self.delegate {
//            return delegate.assetsPicker?(controller: picker, shouldDeselect: AssetsManager.shared.assetArray[indexPath.row], at: indexPath) ?? true
//        } else {
//            return true
//        }
//    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        print("didSelectItemAt --> deselect")

        
//        self.collectionView.cellForItem(at: indexPath)?.isSelected  = false

//        let asset = AssetsManager.shared.assetArray[indexPath.row]
//        deselect(asset: asset, at: indexPath)
//        updateNavigationStatus()
//        delegate?.assetsPicker?(controller: picker, didDeselect: asset, at: indexPath)
    }
}

// MARK: - UICollectionViewDataSource
extension ImagePickerGalleryController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = AssetsManager.shared.assetArray.count
        updateEmptyView(count: count)
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        guard let cellDelegate = cell as? AssetsPhotoCell else {
            logw("Failed to cast AssetsPhotoCellProtocolDelegate.")
            return cell
        }
        guard var photoCell = cell as? AssetsPhotoCellProtocol else {
            logw("Failed to cast UICollectionViewCell.")
            return cell
        }
       
        
        photoCell.isVideo = AssetsManager.shared.assetArray[indexPath.row].mediaType == .video
        photoCell.markedSelected = selectedArray.contains(AssetsManager.shared.assetArray[indexPath.row])
        cellDelegate.delegate = self
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()

        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard var photoCell = cell as? AssetsPhotoCellProtocol else {
            logw("Failed to cast UICollectionViewCell.")
            return
        }
        
        let asset = AssetsManager.shared.assetArray[indexPath.row]
        photoCell.asset = asset
        photoCell.isVideo = asset.mediaType == .video
        if photoCell.isVideo {
            photoCell.duration = asset.duration
        }
        
        if let selectedAsset = selectedMap[asset.localIdentifier] {
            // update cell UI as selected
            if let targetIndex = selectedArray.firstIndex(of: selectedAsset) {
                photoCell.count = targetIndex + 1
            }
        }
        
        cancelFetching(at: indexPath)
        let requestId = AssetsManager.shared.image(at: indexPath.row, size: pickerConfig.assetCacheSize, completion: { [weak self] (image, isDegraded) in
            if self?.isFetching(indexPath: indexPath) ?? true {
                if !isDegraded {
                    self?.removeFetching(indexPath: indexPath)
                }
                UIView.transition(
                    with: photoCell.imageView,
                    duration: 0.125,
                    options: .transitionCrossDissolve,
                    animations: {
                        photoCell.imageView.image = image
                },
                    completion: nil
                )
            }
        })
        registerFetching(requestId: requestId, at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelFetching(at: indexPath)
    }
    
//    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as? AssetsPhotoFooterView else {
//            logw("Failed to cast AssetsPhotoFooterView.")
//            return AssetsPhotoFooterView()
//        }
//        footerView.setNeedsUpdateConstraints()
//        footerView.updateConstraintsIfNeeded()
//        footerView.set(imageCount: AssetsManager.shared.count(ofType: .image), videoCount: AssetsManager.shared.count(ofType: .video))
//        return footerView
//    }
}

// MARK: - Image Fetch Utility
extension ImagePickerGalleryController {
    
    func cancelFetching(at indexPath: IndexPath) {
        if let requestId = requestIdMap[indexPath] {
            requestIdMap.removeValue(forKey: indexPath)
            AssetsManager.shared.cancelRequest(requestId: requestId)
        }
    }
    
    func registerFetching(requestId: PHImageRequestID, at indexPath: IndexPath) {
        requestIdMap[indexPath] = requestId
    }
    
    func removeFetching(indexPath: IndexPath) {
        if let _ = requestIdMap[indexPath] {
            requestIdMap.removeValue(forKey: indexPath)
        }
    }
    
    func isFetching(indexPath: IndexPath) -> Bool {
        if let _ = requestIdMap[indexPath] {
            return true
        } else {
            return false
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagePickerGalleryController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        if collectionView.numberOfSections - 1 == section {
//            if collectionView.bounds.width > collectionView.bounds.height {
//                return CGSize(width: collectionView.bounds.width, height: 80 * 2/3)
//            } else {
//                return CGSize(width: collectionView.bounds.width, height: 80 * 2/3)
//            }
//        } else {
            return .zero
       // }
    }
}

extension ImagePickerGalleryController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationController_forPresented2");

        //        let cell = self.collectionView.cellForItem(at: globalIndexPath!) as! AssetsPhotoCellProtocol
        //
        //
        //        let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: false, startingView: cell.imageView) { [weak self] (photo, index) -> UIImageView? in
        //            // this closure can be used to adjust your UI before returning an `endingImageView`.
        //            return cell.imageView
        //        }
        //        let animator =  AXPhotosPresentationAnimator(transitionInfo: transitionInfo)
        //        return animator;
        return nil;
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationController_forDismissed2");
        //        let cell = self.collectionView.cellForItem(at: globalIndexPath!) as! AssetsPhotoCellProtocol
        //
        //
        //        let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: false, startingView: cell.imageView) { [weak self] (photo, index) -> UIImageView? in
        //            // this closure can be used to adjust your UI before returning an `endingImageView`.
        //            return cell.imageView
        //        }
        //        let animator =  AXPhotosPresentationAnimator(transitionInfo: transitionInfo)
        //        return animator;
        return nil;
    }
    
//    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        print("animationControllerFor navigationController2");
//        return nil;
//    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension ImagePickerGalleryController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var assets = [PHAsset]()
        for indexPath in indexPaths {
            assets.append(AssetsManager.shared.assetArray[indexPath.row])
        }
        AssetsManager.shared.cache(assets: assets, size: pickerConfig.assetCacheSize)
    }
}

// MARK: - AssetsAlbumViewControllerDelegate
extension ImagePickerGalleryController: AssetsAlbumViewControllerDelegate {
    
    public func assetsAlbumViewControllerCancelled(controller: AssetsAlbumViewController) {
        logi("Cancelled.")
    }
    
    public func assetsAlbumViewController(controller: AssetsAlbumViewController, selected album: PHAssetCollection) {
        select(album: album)
    }
}

// MARK: - AssetsManagerDelegate
extension ImagePickerGalleryController: AssetsManagerDelegate {
    
    public func assetsManager(manager: AssetsManager, authorizationStatusChanged oldStatus: PHAuthorizationStatus, newStatus: PHAuthorizationStatus) {
        if oldStatus != .authorized {
            if newStatus == .authorized {
                updateNoPermissionView()
                AssetsManager.shared.fetchAssets(isRefetch: true, completion: { [weak self] (_) in
                    self?.collectionView.reloadData()
                })
            }
        } else {
            updateNoPermissionView()
        }
    }
    
    public func assetsManager(manager: AssetsManager, reloadedAlbumsInSection section: Int) {}
    public func assetsManager(manager: AssetsManager, insertedAlbums albums: [PHAssetCollection], at indexPaths: [IndexPath]) {}
    
    public func assetsManager(manager: AssetsManager, removedAlbums albums: [PHAssetCollection], at indexPaths: [IndexPath]) {
        logi("removedAlbums at indexPaths: \(indexPaths)")
        guard let selectedAlbum = manager.selectedAlbum else {
            logw("selected album is nil.")
            return
        }
        if albums.contains(selectedAlbum) {
            select(album: manager.defaultAlbum ?? manager.cameraRollAlbum)
        }
    }
    
    public func assetsManager(manager: AssetsManager, updatedAlbums albums: [PHAssetCollection], at indexPaths: [IndexPath]) {}
    public func assetsManager(manager: AssetsManager, reloadedAlbum album: PHAssetCollection, at indexPath: IndexPath) {}
    
    public func assetsManager(manager: AssetsManager, insertedAssets assets: [PHAsset], at indexPaths: [IndexPath]) {
        logi("insertedAssets at: \(indexPaths)")
        collectionView.insertItems(at: indexPaths)
        updateFooter()
    }
    
    public func assetsManager(manager: AssetsManager, removedAssets assets: [PHAsset], at indexPaths: [IndexPath]) {
        logi("removedAssets at: \(indexPaths)")
        for removedAsset in assets {
            if let index = selectedArray.firstIndex(of: removedAsset) {
                selectedArray.remove(at: index)
                selectedMap.removeValue(forKey: removedAsset.localIdentifier)
            }
        }
        collectionView.deleteItems(at: indexPaths)
        updateSelectionCount()
        updateNavigationStatus()
        updateFooter()
    }
    
    public func assetsManager(manager: AssetsManager, updatedAssets assets: [PHAsset], at indexPaths: [IndexPath]) {
        logi("updatedAssets at: \(indexPaths)")
        collectionView.reloadItems(at: indexPaths)
        updateNavigationStatus()
        updateFooter()
    }
    
    //added here
    open func image(forAsset asset: PHAsset, isNeedDegraded: Bool = true, completion: @escaping ((UIImage?) -> Void)) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        //options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        PHCachingImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFit,
            options: options,
            resultHandler: { (image, info) in
                if !isNeedDegraded {
                    if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                        print("isDegraded")
                        return
                    }
                }
                completion(image)
        })
    }
    
   
    
}


