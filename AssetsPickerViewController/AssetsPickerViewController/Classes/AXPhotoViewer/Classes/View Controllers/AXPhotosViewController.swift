//
//  AXPhotosViewController.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/7/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

import AVFoundation
import CoreMedia
import AssetsLibrary

#if os(iOS)
import FLAnimatedImage
#elseif os(tvOS)
import FLAnimatedImage_tvOS
#endif

@objc open class AXPhotosViewController: UIViewController, UIPageViewControllerDelegate,
    UIPageViewControllerDataSource,
    UIGestureRecognizerDelegate,
    AXPhotoViewControllerDelegate,
    AXNetworkIntegrationDelegate,
    AXPhotosTransitionControllerDelegate,
    ABVideoRangeSliderDelegate
    
{
    public func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        
        self.attributedText2 = NSAttributedString(string: self.videoRangeSlider.secondsToFormattedString(totalSeconds: self.videoRangeSlider.secondsFromValue(value: self.videoRangeSlider.startPercentage)) + " / " +
        self.videoRangeSlider.secondsToFormattedString(totalSeconds: self.videoRangeSlider.secondsFromValue(value: self.videoRangeSlider.endPercentage)), attributes: self.defaultAttributes())
        
          self.countLabel.attributedText = self.attributedText2
        
    }
    
    
    public func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
           print("indicator changed position \(position)")
           //
           let tm = CMTimeMake(value: Int64(position*100), timescale: 100)
        
        
           player.seek(to: tm)
           
        

           
           
   }
       
   
    
    public func sliderGesturesBegan() {
        canUpdateProgressIndicator = false
        player.pause()
    }
    
    public func sliderGesturesEnded() {
        // player.playFromCurrentTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.canUpdateProgressIndicator = true
        })
        
    }
    
    
   
    
    
    
    #if os(iOS)
    /// The close bar button item that is initially set in the overlay's toolbar. Any 'target' or 'action' provided to this button will be overwritten.
    /// Overriding this is purely for customizing the look and feel of the button.
    /// Alternatively, you may create your own `UIBarButtonItem`s and directly set them _and_ their actions on the `overlayView` property.
    //    @objc open var closeBarButtonItem: UIBarButtonItem {
    //        get {
    //            return UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
    //        }
    //    }
    
    /// The action bar button item that is initially set in the overlay's toolbar. Any 'target' or 'action' provided to this button will be overwritten.
    /// Overriding this is purely for customizing the look and feel of the button.
    /// Alternatively, you may create your own `UIBarButtonItem`s and directly set them _and_ their actions on the `overlayView` property.
    @objc open var actionBarButtonItem: UIBarButtonItem {
        get {
            //let barButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            let buttonIcon = UIImage(named: "button_send_white", in: AXBundle.frameworkBundle, compatibleWith: nil)
            let buttonView = UIImageView(image: buttonIcon)
            let barButtonItem = UIBarButtonItem(customView: buttonView)
            
            barButtonItem.image = buttonIcon
            //return UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            return barButtonItem
        }
    }
    
    @objc open var closeBarButtonItem: UIBarButtonItem {
        get {
            //let barButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            let buttonIcon = UIImage(named: "button_cross_new", in: AXBundle.frameworkBundle, compatibleWith: nil)
            let buttonView = UIImageView(image: buttonIcon)
            // buttonView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            
            let barButtonItem = UIBarButtonItem(customView: buttonView)
            
            let tap  = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
            buttonView.addGestureRecognizer(tap)
            
            //constraints
            //            if #available(iOS 9.0, *) {
            //                let widthConstraint = buttonView.widthAnchor.constraint(equalToConstant: 20)
            //                let heightConstraint = buttonView.heightAnchor.constraint(equalToConstant: 20)
            //
            //                heightConstraint.isActive = true
            //                widthConstraint.isActive = true
            //
            //
            //            } else {
            //                // Fallback on earlier versions
            //            }
            
            
            // barButtonItem.image = buttonIcon
            //return UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            return barButtonItem
        }
    }
    
    
    
    let statusButtonTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(statusViewButtonClicked))
    
    @objc func statusViewButtonClicked() {
        print("buttonClicked")
        
    }
    
    @objc open var actionBarButtonItemTop: UIBarButtonItem {
        get {
            //let barButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            let buttonIcon = UIImage(named: "button_send_white", in: AXBundle.frameworkBundle, compatibleWith: nil)
            let buttonView = UIImageView(image: buttonIcon)
            let barButtonItem = UIBarButtonItem(customView: buttonView)
            
            barButtonItem.image = buttonIcon
            //return UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            return barButtonItem
        }
    }
    
    @objc open var closeBarButtonItemTop: UIBarButtonItem {
        get {
            //let barButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            //            let buttonIcon = UIImage(named: "button_cross", in: AXBundle.frameworkBundle, compatibleWith: nil)
            //            let buttonView = UIImageView(image: buttonIcon)
            //            let barButtonItem = UIBarButtonItem(customView: buttonView)
            //
            //            barButtonItem.image = buttonIcon
            //return UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
            
            let barButtonItem = UIBarButtonItem(title: "Username", style: .plain, target: nil, action: nil)
            
            
            return barButtonItem
        }
    }
    
    /// The internal tap gesture recognizer that is used to initiate and pan interactive dismissals.
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    
    fileprivate var ax_prefersStatusBarHidden: Bool = false
    open override var prefersStatusBarHidden: Bool {
        // get {
        //     return super.prefersStatusBarHidden || self.ax_prefersStatusBarHidden
        // }
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    #endif
    
    @objc open weak var delegate: AXPhotosViewControllerDelegate?
    
    /// The underlying `OverlayView` that is used for displaying photo captions, titles, and actions.
    @objc public let overlayView = AXOverlayView()
    
    // @objc public let overlayTopView = AXOverlayTopView()
    
    
    /// The photos to display in the PhotosViewController.
    @objc open var dataSource = AXPhotosDataSource() {
        didSet {
            // this can occur during `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`
            // if that's the case, this logic will be applied in `viewDidLoad()`
            if self.pageViewController == nil || self.networkIntegration == nil {
                return
            }
            
            self.pageViewController.dataSource = (self.dataSource.numberOfPhotos > 1) ? self : nil
            self.networkIntegration.cancelAllLoads()
            self.configurePageViewController()
        }
    }
    
    /// The configuration object applied to the internal pager at initialization.
    @objc open fileprivate(set) var pagingConfig = AXPagingConfig()
    
    /// The `AXTransitionInfo` passed in at initialization. This object is used to define functionality for the presentation and dismissal
    /// of the `PhotosViewController`.
    @objc open fileprivate(set) var transitionInfo = AXTransitionInfo()
    
    /// The `NetworkIntegration` passed in at initialization. This object is used to fetch images asynchronously from a cache or URL.
    /// - Initialized by the end of `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`.
    @objc public fileprivate(set) var networkIntegration: AXNetworkIntegrationProtocol!
    
    /// The underlying UIPageViewController that is used for swiping horizontally and vertically.
    /// - Important: `AXPhotosViewController` is this page view controller's `UIPageViewControllerDelegate`, `UIPageViewControllerDataSource`.
    ///              Changing these values will result in breakage.
    /// - Note: Initialized by the end of `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`.
    @objc public fileprivate(set) var pageViewController: UIPageViewController!
    
    /// The internal tap gesture recognizer that is used to hide/show the overlay interface.
    @objc public let singleTapGestureRecognizer = UITapGestureRecognizer()
    
    
    @objc public var currentPhotoViewControllerForPlayer: AXPhotoViewController?
    
    /// The view controller containing the photo currently being shown.
    @objc public var currentPhotoViewController: AXPhotoViewController? {
        get {
            return self.orderedViewControllers.filter({ $0.pageIndex == currentPhotoIndex }).first
        }
    }
    
    /// The index of the photo currently being shown.
    @objc public fileprivate(set) var currentPhotoIndex: Int = 0 {
        didSet {
            self.updateOverlay(for: currentPhotoIndex)
        }
    }
    
    // MARK: - Private/internal variables
    fileprivate enum SwipeDirection {
        case none, left, right
    }
    
    /// If the `PhotosViewController` is being presented in a fullscreen container, this value is set when the `PhotosViewController`
    /// is added to a parent view controller to allow `PhotosViewController` to be its transitioning delegate.
    fileprivate weak var containerViewController: UIViewController? {
        didSet {
            oldValue?.transitioningDelegate = nil
            
            if let containerViewController = self.containerViewController {
                containerViewController.transitioningDelegate = self.transitionController
                self.transitioningDelegate = nil
            } else {
                self.transitioningDelegate = self.transitionController
            }
        }
    }
    
    fileprivate var isSizeTransitioning = false
    fileprivate var isFirstAppearance = true
    
    fileprivate var orderedViewControllers = [AXPhotoViewController]()
    fileprivate var recycledViewControllers = [AXPhotoViewController]()
    
    fileprivate var transitionController: AXPhotosTransitionController?
    fileprivate let notificationCenter = NotificationCenter()
    
    
    //Player
    
    @objc public var player = Player()
    var canUpdateProgressIndicator = true
    @objc public var videoRangeSlider = ABVideoRangeSlider()
    
    
    //    open var  emptyButton: UIButton = {
    //           let button = UIButton(type: .custom)
    //           button.frame = CGRect(x: 100, y: 100, width: 34, height: 34)
    //           button.layer.cornerRadius = 0.5 * button.bounds.size.width
    //           button.layer.borderWidth = 1.5
    //           button.layer.borderColor = UIColor.white.cgColor
    //           //button.backgroundColor = UIColor(red: 90/255, green: 119/255, blue: 236/255, alpha: 1)
    //           button.backgroundColor = .clear
    //           button.contentMode = .center
    //           button.clipsToBounds = true
    //           return button
    //       }()
    
    var selectButton = AXButtonStatusView(frame: CGRect(x: 100, y:100, width: 34, height: 34))
    
    //    let selectButton: UIButton = {
    //
    //
    //
    //        let button = UIButton(type: .custom)
    //        button.frame = CGRect(x: 100, y: 100, width: 32, height: 32)
    //        button.layer.cornerRadius = 0.5 * button.bounds.size.width
    //        //button.layer.borderWidth = 1.5
    //        //button.layer.borderColor = UIColor.white.cgColor
    //        //button.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
    //        button.backgroundColor = .clear
    //        button.clipsToBounds = true
    //        button.setTitleColor(UIColor.white, for: .normal)
    //        button.contentMode = .center
    //
    //        var layer: CALayer {
    //          return button.layer
    //        }
    //
    //        var backView: UIView {
    //            let view = UIView()
    //            return view
    //        }
    //
    //        backView.frame = button.frame
    //        backView.backgroundColor = .yellow
    //        backView.layer.cornerRadius = 0.5 * button.bounds.size.width
    //
    //        button.addSubview(backView)
    //        //backView.sendSubviewToBack(button)
    //
    //        return button
    //    }()
    
    // let statusView = AXButtonStatusView(frame: CGRect(x: 320, y: 650, width: 60, height: 60),count: 0)
    
    
    //--
    //    var cache:NSCache<AnyObject, AnyObject>!
    //    var startTime: CGFloat = 0.0
    //    var stopTime: CGFloat  = 0.0
    //    var thumbTime: CMTime!
    //    var thumbtimeSeconds: Int!
    //
    //    var videoPlaybackPosition: CGFloat = 0.0
    //    var rangSlider: RangeSlider! = nil
    //    var isSliderEnd = true
    //
    //    var startTimestr = ""
    //    var endTimestr = ""
    //
    //
    //    var frameContainerView: UIView = {
    //        let view =  UIView()
    //        view.frame = CGRect(x: 10, y:50, width: 300, height: 50)
    //
    //        return view
    //    }()
    //
    //    var imageFrameView: UIView = {
    //        let view =  UIView()
    //        view.frame = CGRect(x: 0, y:0, width: 300, height: 50)
    //
    //        return view
    //    }()
    
    
    
    
    // MARK: - Initialization
    @objc public init() {
        super.init(nibName: nil, bundle: nil)
        self.commonInit()
    }
    
    @objc public init(dataSource: AXPhotosDataSource?) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource)
    }
    
    @objc public init(dataSource: AXPhotosDataSource?,
                      pagingConfig: AXPagingConfig?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig)
    }
    
    @objc public init(pagingConfig: AXPagingConfig?,
                      transitionInfo: AXTransitionInfo?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo)
    }
    
    @objc public init(dataSource: AXPhotosDataSource?,
                      pagingConfig: AXPagingConfig?,
                      transitionInfo: AXTransitionInfo?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo)
    }
    
    @objc public init(networkIntegration: AXNetworkIntegrationProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(networkIntegration: networkIntegration)
    }
    
    @objc public init(dataSource: AXPhotosDataSource?,
                      networkIntegration: AXNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        networkIntegration: networkIntegration)
    }
    
    @objc public init(dataSource: AXPhotosDataSource?,
                      pagingConfig: AXPagingConfig?,
                      networkIntegration: AXNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        networkIntegration: networkIntegration)
    }
    
    @objc public init(pagingConfig: AXPagingConfig?,
                      transitionInfo: AXTransitionInfo?,
                      networkIntegration: AXNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration)
    }
    
    @objc public init(dataSource: AXPhotosDataSource?,
                      pagingConfig: AXPagingConfig?,
                      transitionInfo: AXTransitionInfo?,
                      networkIntegration: AXNetworkIntegrationProtocol) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration)
    }
    
    #if os(iOS)
    @objc(initFromPreviewingPhotosViewController:)
    public init(from previewingPhotosViewController: AXPreviewingPhotosViewController) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        networkIntegration: previewingPhotosViewController.networkIntegration)
        
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            let _ = self.view
        }
        
        self.currentPhotoViewController?.zoomingImageView.imageView.ax_syncFrames(with: previewingPhotosViewController.imageView)
    }
    
    @objc(initFromPreviewingPhotosViewController:pagingConfig:)
    public init(from previewingPhotosViewController: AXPreviewingPhotosViewController,
                pagingConfig: AXPagingConfig?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        pagingConfig: pagingConfig,
                        networkIntegration: previewingPhotosViewController.networkIntegration)
        
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            let _ = self.view
        }
        
        self.currentPhotoViewController?.zoomingImageView.imageView.ax_syncFrames(with: previewingPhotosViewController.imageView)
    }
    
    @objc(initFromPreviewingPhotosViewController:pagingConfig:transitionInfo:)
    public init(from previewingPhotosViewController: AXPreviewingPhotosViewController,
                pagingConfig: AXPagingConfig?,
                transitionInfo: AXTransitionInfo?) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: previewingPhotosViewController.networkIntegration)
        
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            let _ = self.view
        }
        
        self.currentPhotoViewController?.zoomingImageView.imageView.ax_syncFrames(with: previewingPhotosViewController.imageView)
    }
    #endif
    
    @objc public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // init to be used internally by the library
    @nonobjc init(dataSource: AXPhotosDataSource? = nil,
                  pagingConfig: AXPagingConfig? = nil,
                  transitionInfo: AXTransitionInfo? = nil,
                  networkIntegration: AXNetworkIntegrationProtocol? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration)
    }
    
    @objc  public func didPressButt(sender: Any) {
        print("didPressButt")
    }
    
    var selectButtonBottomConstraint: NSLayoutConstraint?
    
    fileprivate func commonInit(dataSource: AXPhotosDataSource? = nil,
                                pagingConfig: AXPagingConfig? = nil,
                                transitionInfo: AXTransitionInfo? = nil,
                                networkIntegration: AXNetworkIntegrationProtocol? = nil) {
        
        if let dataSource = dataSource {
            self.dataSource = dataSource
        }
        
        if let pagingConfig = pagingConfig {
            self.pagingConfig = pagingConfig
        }
        
        if let transitionInfo = transitionInfo {
            self.transitionInfo = transitionInfo
            
            #if os(iOS)
            if transitionInfo.interactiveDismissalEnabled {
                self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWithGestureRecognizer(_:)))
                self.panGestureRecognizer?.maximumNumberOfTouches = 1
                self.panGestureRecognizer?.delegate = self
            }
            #endif
        }
        
        var `networkIntegration` = networkIntegration
        if networkIntegration == nil {
            #if canImport(SDWebImage)
            networkIntegration = SDWebImageIntegration()
            #elseif canImport(PINRemoteImage)
            networkIntegration = PINRemoteImageIntegration()
            #elseif canImport(AFNetworking)
            networkIntegration = AFNetworkingIntegration()
            #elseif canImport(Kingfisher)
            networkIntegration = KingfisherIntegration()
            #elseif canImport(Nuke)
            networkIntegration = NukeIntegration()
            #else
            networkIntegration = SimpleNetworkIntegration()
            #endif
        }
        
        self.networkIntegration = networkIntegration
        self.networkIntegration.delegate = self
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: self.pagingConfig.navigationOrientation,
                                                       options: [.interPageSpacing: self.pagingConfig.interPhotoSpacing])
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = (self.dataSource.numberOfPhotos > 1) ? self : nil
        self.pageViewController.scrollView.addContentOffsetObserver(self)
        self.configurePageViewController()
        
        self.singleTapGestureRecognizer.numberOfTapsRequired = 1
        self.singleTapGestureRecognizer.addTarget(self, action: #selector(didSingleTapWithGestureRecognizer(_:)))
        
        
        
        //        imageFrameView.layer.cornerRadius = 5.0
        //        imageFrameView.layer.borderWidth  = 1.0
        //        imageFrameView.layer.borderColor  = UIColor.white.cgColor
        //        imageFrameView.layer.masksToBounds = true
        //
        
        
        
        
        //videoRangeSlider.startTimeView.removeFromSuperview()
        //videoRangeSlider.endTimeView.removeFromSuperview()
        
        
        //        let bundle = Bundle(for: AXPhotosViewController.self)
        //
        //        let customStartIndicator =  UIImage(named: "CustomStartIndicator", in: bundle, compatibleWith: nil)
        //        videoRangeSlider.setStartIndicatorImage(image: customStartIndicator!)
        //
        //        let customEndIndicator =  UIImage(named: "CustomEndIndicator", in: bundle, compatibleWith: nil)
        //        videoRangeSlider.setEndIndicatorImage(image: customEndIndicator!)
        //
        //        let customBorder =  UIImage(named: "CustomBorder", in: bundle, compatibleWith: nil)
        //        videoRangeSlider.setBorderImage(image: customBorder!)
        //
        //        let customProgressIndicator =  UIImage(named: "CustomProgress", in: bundle, compatibleWith: nil)
        //        videoRangeSlider.setProgressIndicatorImage(image: customProgressIndicator!)
        //
        
        // statusView.button.addGestureRecognizer(self.statusButtonTap)
        if (view.frame.height > view.frame.width) {
            videoRangeSlider.frame = CGRect(x: 30, y:60, width: view.frame.width - 60, height: 35)
            //                   statusView.frame = CGRect(x: view.frame.width - 55, y: view.frame.height - 125, width: 60, height: 60)
            //  selectButton.frame = CGRect(x: view.frame.width - 49.5, y: view.frame.height - 93, width: 31, height: 31)
            // emptyButton.frame = CGRect(x: view.frame.width - 49.5, y: view.frame.height - 93, width: 34, height: 34)
            
        } else {
            videoRangeSlider.frame = CGRect(x: 40, y:30, width: view.frame.width - 80, height: 35)
            // statusView.frame = CGRect(x: view.frame.width - 95, y: view.frame.height - 100, width: 60, height: 60)
            // selectButton.frame = CGRect(x: view.frame.width - 93, y: view.frame.height - 74, width: 31, height: 31)
            // emptyButton.frame = CGRect(x: view.frame.width - 93, y: view.frame.height - 74, width: 34, height: 34)
        }
        
        
        
        
        
        //        videoRangeSlider.frame = CGRect(x: 0, y:0, width: 300, height: 40)
        //        videoRangeSlider.translatesAutoresizingMaskIntoConstraints = true
        //        videoRangeSlider.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        //        videoRangeSlider.autoresizingMask = [UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin]
        
        
        videoRangeSlider.minSpace = 5.0
        
        
        videoRangeSlider.contentMode = .scaleToFill
        videoRangeSlider.delegate = self
        self.view.addSubview(videoRangeSlider)
        
        
        //        emptyButton.frame = CGRect(x: 100, y:100, width: 34, height: 34)
        //        emptyButton.addTarget(self, action: #selector(selectPhotoButtonClicked), for: .touchUpInside)
        //         self.view.addSubview(emptyButton)
        
        
        //selectButton = AXButtonStatusView(frame: CGRect(x: 100, y:100, width: 31, height: 31))
        //selectButton.frame = CGRect(x: 100, y:100, width: 36, height: 36)
        selectButton.selectButton.addTarget(self, action: #selector(selectPhotoButtonClicked), for: .touchUpInside)
        self.view.addSubview(selectButton)
        
        //  statusView.button.addTarget(self, action: #selector(statusViewButtonClicked), for: .touchUpInside)
        //  self.view.addSubview(self.statusView)
        
        
        //        let videoRangeSliderWidth = view.frame.width - 60
        //        let videoRangeSliderHeight:CGFloat = 40
        //        let videoRangeSliderLeftMargin:CGFloat = 30
        //
                selectButton.translatesAutoresizingMaskIntoConstraints = false
                selectButtonBottomConstraint = NSLayoutConstraint(item: selectButton, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: overlayView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -100)
                let rightConstraint = NSLayoutConstraint(item: selectButton, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -10)
        //
                let widthConstraint = NSLayoutConstraint(item: selectButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 36)
                let heightConstraint = NSLayoutConstraint(item: selectButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 36)
        NSLayoutConstraint.activate([heightConstraint, widthConstraint, selectButtonBottomConstraint!, rightConstraint])
        //
        //
        //
        //        frameContainerView.addSubview(imageFrameView)
        
        self.overlayView.tintColor = .white
        self.overlayView.setShowInterface(false, animated: false)
        self.overlayView.layer.zPosition = 1;
        
        #if os(iOS)
        let closeBarButtonItem1 = self.closeBarButtonItem
        closeBarButtonItem1.target = self
        closeBarButtonItem1.action = #selector(closeAction(_:))
        self.overlayView.leftBarButtonItem = closeBarButtonItem1
        //
        let actionBarButtonItem = self.actionBarButtonItem
        actionBarButtonItem.target = self
        actionBarButtonItem.action = #selector(shareAction(_:))
        self.overlayView.rightBarButtonItem = actionBarButtonItem
        #endif
        
        //        self.overlayTopView.tintColor = .white
        //        self.overlayTopView.setShowInterface(false, animated: false)
        //        self.overlayTopView.layer.zPosition = 1;
        
        
        
        #if os(iOS)
        let closeBarButtonItemTop = self.closeBarButtonItemTop
        closeBarButtonItemTop.target = self
        //closeBarButtonItemTop.action = #selector(closeAction(_:))
        //        self.overlayTopView.leftBarButtonItem = closeBarButtonItemTop
        
        
        /// valid send and close buttons
        //        let buttonCancelIcon = UIImage(named: "button_cross", in: AXBundle.frameworkBundle, compatibleWith: nil)
        //                      let buttonCancel  = UIButton(type: .custom)
        //                      buttonCancel.setImage(buttonCancelIcon, for: .normal)
        //        buttonCancel.addTarget(self, action: #selector(closeAction(_:)), for: UIControl.Event.touchDown)
        //        self.overlayView.buttonCancel = buttonCancel
        //
        //        let buttonSendIcon = UIImage(named: "button_send_white", in: AXBundle.frameworkBundle, compatibleWith: nil)
        //                      let buttonSend  = UIButton(type: .custom)
        //                      buttonSend.setImage(buttonSendIcon, for: .normal)
        //        buttonSend.addTarget(self, action: #selector(closeAction(_:)), for: UIControl.Event.touchDown)
        //        self.overlayView.buttonSend = buttonSend
        
        self.overlayView.buttonCancel.addTarget(self, action: #selector(closeAction(_:)), for: [UIControl.Event.touchDown,UIControl.Event.touchUpInside,UIControl.Event.touchUpOutside])
        
        self.overlayView.buttonSend.addTarget(self, action: #selector(closeAction(_:)), for: [UIControl.Event.touchDown,UIControl.Event.touchUpInside,UIControl.Event.touchUpOutside ])
        
        
        ///
        
        
        
        //
        //        let actionBarButtonItemTop = self.actionBarButtonItemTop
        //        actionBarButtonItemTop.target = self
        //        actionBarButtonItemTop.action = #selector(shareAction(_:))
        //        self.overlayTopView.rightBarButtonItem = actionBarButtonItemTop
        #endif
    }
    
    deinit {
        self.recycledViewControllers.removeLifeycleObserver(self)
        self.orderedViewControllers.removeLifeycleObserver(self)
        self.pageViewController.scrollView.removeContentOffsetObserver(self)
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.recycledViewControllers.removeLifeycleObserver(self)
        self.recycledViewControllers.removeAll()
        
        self.reduceMemoryForPhotos(at: self.currentPhotoIndex)
    }
    
    let topView = UIView()
    let topMaskedView = UIView()
    
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            } else {
                // Fallback on earlier versions
            }
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        
        self.view.backgroundColor = .black
        
        self.transitionController = AXPhotosTransitionController(transitionInfo: self.transitionInfo)
        self.transitionController?.delegate = self
        
        #if os(iOS)
        if let panGestureRecognizer = self.panGestureRecognizer {
            self.pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        }
        #endif
        
        if let containerViewController = self.containerViewController {
            containerViewController.transitioningDelegate = self.transitionController
        } else {
            self.transitioningDelegate = self.transitionController
        }
        
        if self.pageViewController.view.superview == nil {
            self.pageViewController.view.addGestureRecognizer(self.singleTapGestureRecognizer)
            
            self.addChild(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            self.pageViewController.didMove(toParent: self)
        }
        
        if self.overlayView.superview == nil {
            self.view.addSubview(self.overlayView)
        }
        
        //        if self.overlayTopView.superview == nil {
        //            self.view.addSubview(self.overlayTopView)
        //        }
        
        
        
        //        if #available(iOS 11.0, *) {
        //            topView.frame = CGRect(x:0, y:self.view.safeAreaInsets.top, width: self.view.frame.width, height: 70)
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
        
        
        
        
        player.playerDelegate = self
        player.playbackDelegate = self
        //        if self.playButton.superview == nil {
        //            self.view.addSubview(self.playButton)
        //        }
        
    }
    
    func defaultAttributes() -> [NSAttributedString.Key: Any] {
        let pointSize: CGFloat = 15.0
        var font: UIFont
        //            if #available(iOS 8.2, *) {
        //                font = UIFont.systemFont(ofSize: pointSize, weight: UIFont.Weight.semibold)
        //            } else {
        //                font = UIFont(name: "HelveticaNeue-Medium", size: pointSize)!
        //            }
        
        font = UIFont(name: "Verdana", size: pointSize)!
        
        
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    var attributedText2: NSAttributedString?
     let countLabel = UILabel()
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isFirstAppearance {
            let visible: Bool = true
            self.overlayView.setShowInterface(visible, animated: true, alongside: { [weak self] in
                guard let `self` = self else { return }
                
                #if os(iOS)
                self.updateStatusBarAppearance(show: visible)
                #endif
                
                self.overlayView(self.overlayView, visibilityWillChange: visible)
            })
            
            //            self.overlayTopView.setShowInterface(visible, animated: true, alongside: { [weak self] in
            //                guard let `self` = self else { return }
            //
            //                #if os(iOS)
            //                self.updateStatusBarAppearance(show: visible)
            //                #endif
            //
            //                self.overlayTopView(self.overlayTopView, visibilityWillChangeTop: visible)
            //            })
            
            
            
            self.isFirstAppearance = false
            enableKeyboardHideOnTap()
        }
        
        
        
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        topView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(topView)
        topMaskedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        topMaskedView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(topMaskedView)
        
        let attributedText = NSAttributedString(string: "Username", attributes: defaultAttributes())
        
        let usernameLabel = UILabel()
        usernameLabel.attributedText = attributedText
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        //                if #available(iOS 11.0, *) {
        //                    usernameLabel.frame = CGRect(x:10, y:10, width: 100, height: 30)
        //                } else {
        //                    // Fallback on earlier versions
        //                }
        topView.addSubview(usernameLabel)
        
        
       // let attributedText2 = NSAttributedString(string: "100 / 102", attributes: defaultAttributes())
        self.attributedText2 = NSAttributedString(string: "100 / 102", attributes: defaultAttributes())

               
        

       
        countLabel.attributedText = self.attributedText2
               countLabel.translatesAutoresizingMaskIntoConstraints = false
               //                if #available(iOS 11.0, *) {
               //                    usernameLabel.frame = CGRect(x:10, y:10, width: 100, height: 30)
               //                } else {
               //                    // Fallback on earlier versions
               //                }
               topView.addSubview(countLabel)
        
        
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            
            print("self.view.safeAreaInsets \(self.view.safeAreaInsets)")
            print("self.view.safeAreaInsets.bottom \(self.view.safeAreaInsets.bottom)");
            // topView.frame = CGRect(x:0, y:self.view.safeAreaInsets.top, width: self.view.frame.width, height: 70)
            
            let topConstraint = NSLayoutConstraint(item: topView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            
            let rightConstraint = NSLayoutConstraint(item: topView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            
            let leftConstraint = NSLayoutConstraint(item: topView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant:  0)
            
            let heightConstraint = NSLayoutConstraint(item: topView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 30)
            
            
            let topMaskedConstraint = NSLayoutConstraint(item: topMaskedView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            
            let rightMaskedConstraint = NSLayoutConstraint(item: topMaskedView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            
            let leftMaskedConstraint = NSLayoutConstraint(item: topMaskedView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant:  0)
            
            let bottomMaskedConstraint = NSLayoutConstraint(item: topMaskedView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            
            let usernameCenterConstraint = NSLayoutConstraint(item: usernameLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: topView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            //  let usernameHeightConstraint = NSLayoutConstraint(item: usernameLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 20)
            let usernameWidthConstraint = NSLayoutConstraint(item: usernameLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
            
            let usernameleftConstraint = NSLayoutConstraint(item: usernameLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant:  12)
            
            let countCenterConstraint = NSLayoutConstraint(item: countLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: topView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
                      //  let usernameHeightConstraint = NSLayoutConstraint(item: usernameLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 20)
                      let countWidthConstraint = NSLayoutConstraint(item: countLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
                      
                      let countRightConstraint = NSLayoutConstraint(item: countLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant:  -12)
                      
                      
            
            
            NSLayoutConstraint.activate([topConstraint, rightConstraint, leftConstraint, heightConstraint,
                                         usernameCenterConstraint, usernameWidthConstraint,usernameleftConstraint,
                                         topMaskedConstraint, bottomMaskedConstraint,rightMaskedConstraint, leftMaskedConstraint,
                                        countCenterConstraint, countWidthConstraint, countRightConstraint]);
        } else {
            // Fallback on earlier versions
        };
        
        self.view.setNeedsLayout()
        
    }
    
    private func enableKeyboardHideOnTap(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        //  self.overlayView.descriptionTextField.inputAccessoryView = self.overlayView
        
        
        // 3.1
        //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        //
        //        self.overlayView.addGestureRecognizer(tap)
    }
    
    //3.1
    @objc func hideKeyboard() {
        self.overlayView.textView.endEditing(true)
        
        
        
        //       self.overlayView.descriptionTextField.endEditing(true)
        //        self.view.endEditing(true)
        //        self.overlayView.endEditing(true)
        
        //  self.overlayView.descriptionTextField.resignFirstResponder()
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        self.overlayView.isKeyboardShown  = true
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        self.overlayView.isKeyboardShown  = false
        
    }
    

    //4.1
    @objc func keyboardWillShow(notification: NSNotification) {
        
        print("<><>keyboardWillShow")
        
        self.currentPhotoViewController?.playButton.isHidden = true
                             self.videoRangeSlider.isHidden = true
//        UIView.animate(
//            withDuration: 0.05,
//            animations: {
                self.currentPhotoViewController?.playButton.alpha = 0.0
                self.videoRangeSlider.alpha = 0.0
        
        
       // })
        
        
        let info = notification.userInfo!
        
        self.overlayView.textView.becomeFirstResponder()
        
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        print("duration keyboardWillShow \(duration)")
        
        if (self.overlayView.textView.text == "Add description...") {
            self.overlayView.textView.text = ""
        }
        
        
        UIView.animate(withDuration: duration) { () -> Void in
            
            //            var contentInset: UIEdgeInsets
            //
            //                       contentInset = UIEdgeInsets(
            //                           top:  0,
            //                           left: 0,
            //                           bottom: keyboardFrame.size.height + 200,
            //                           right: 0
            //                       )
            //
            //
            //
            //                   self.overlayView.contentInset = contentInset
            //
            let screenSize = self.view.frame.size.height
            let imageSize = self.currentPhotoViewController?.zoomingImageView.imageView.frame.height
            
            var koeff = CGFloat(1)
            var translationKoeff = CGFloat(0)
            if (screenSize/2 > imageSize!) {
                koeff =  0.9
                translationKoeff = -screenSize / 4
            } else {
                koeff =  screenSize / 2 / imageSize!
                if (koeff < 1) {
                    
                }
                else {
                    koeff = 1 / koeff
                }
                translationKoeff = -screenSize / 3
            }
            
            print(" full view size \(screenSize)")
            print(" image view size \(imageSize)")
            
            
            
            let scale =  CGAffineTransform(scaleX: koeff, y: koeff)
            let translation = CGAffineTransform(translationX: 0, y: translationKoeff)
            
            self.currentPhotoViewController?.zoomingImageView.transform = translation.concatenating(scale)
            
            
            
            
            //            for constraint in self.overlayView.constraints {
            //                print("constraint \(constraint)")
            //
            //                if constraint.identifier == "bottomC" {
            //                    print("constarinttttttt")
            //                    constraint.constant = -keyboardFrame.size.height + 35
            //                }
            //            }
            
            
            //  self.currentPhotoViewController?.zoomingImageView.contentInset = contentInset
            
            
            
            
        //    self.view.layoutIfNeeded()
            
        }
        
     //   keyboardIsChangingFrame = false
        
        
    }
    
    private var constraintHeightSize:CGFloat = 0
    
    //private var keyboardIsChangingFrame: Bool = false;
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        print("keyboard will change frame")
        

        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
//        if (keyboardScreenEndFrame.origin.y != self.view.frame.height) {
//            //keyboardIsChangingFrame = true
//        } else {
//            //self.overlayView.textView.resignFirstResponder()
//        }
        
        
        //let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        self.selectButtonBottomConstraint?.constant = -keyboardScreenEndFrame.height - 100

        //            print("keyboardScreenEndFrame.origin.y \(keyboardScreenEndFrame.origin.y)")
        //            print("self.view.frame.height \(self.view.frame.height)")
        //
        //        print("keyboardScreenEndFrame \(keyboardScreenEndFrame)")
        //            print("keyboardViewEndFrame \(keyboardViewEndFrame)")
        
        
        
        for constraint in self.overlayView.constraints {
            // print("constraint \(constraint)")
            
            if constraint.identifier == "bottomC" {
                
                constraint.constant = -keyboardScreenEndFrame.height + 32
                // constraintHeightSize = -keyboardScreenEndFrame.height + 35
                //  print("constarinttttttt  ---> \(constraint.constant) --  \(constraintHeightSize)")
            }
        }
        
        self.view.layoutIfNeeded()
        
        
        
    }
    
    //4.2
    @objc func keyboardWillHide(notification: NSNotification) {
        
        self.currentPhotoViewController?.playButton.isHidden = false
        self.videoRangeSlider.isHidden = false
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.currentPhotoViewController?.playButton.alpha = 1.0
                self.videoRangeSlider.alpha = 1.0
        })
        

        print("<><>keyboardWillHide 0")
//        if(keyboardIsChangingFrame) {
//
//            keyboardIsChangingFrame  = false
//            return
//        }
        
        print("<><>keyboardWillHide")
        
        
        
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        print("duration keyboardWillHide \(duration)")
        
        UIView.animate(withDuration: duration) { () -> Void in
            self.selectButtonBottomConstraint?.constant = -100

            let scale =  CGAffineTransform(scaleX: 1.0, y: 1.0)
            //let translation = CGAffineTransform(translationX: 0, y: 200)
            
            self.currentPhotoViewController?.zoomingImageView.transform = scale
            
            for constraint in self.overlayView.constraints {
                //print("constraint \(constraint)")
                
                if constraint.identifier == "bottomC" {
                   // print("constarinttttttt")
                    constraint.constant = 0
                }
            }
            // self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
            
            //                 var contentInset: UIEdgeInsets
            //                      if #available(iOS 11.0, tvOS 11.0, *) {
            //                          contentInset = self.view.safeAreaInsets
            //                      } else {
            //                          #if os(iOS)
            //                          contentInset = UIEdgeInsets(
            //                              top: (UIApplication.shared.statusBarFrame.size.height > 0) ? 20 : 0,
            //                              left: 0,
            //                              bottom: 0,
            //                              right: 0
            //                          )
            //                          #else
            //                          contentInset = UIEdgeInsets(
            //                              top: 60,
            //                              left: 90,
            //                              bottom: 60,
            //                              right: 90
            //                          )
            //                          #endif
            //                      }
            //
            //                      self.overlayView.contentInset = contentInset
            //
            //                self.currentPhotoViewController?.zoomingImageView.contentInset = contentInset
            
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    //    override open var inputAccessoryView: UIView{
    //           get{
    //            return self.overlayView
    //           }
    //       }
    
    
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //self.player.view.frame =  CGRect(x:0, y:0, width: size.width, height: size.height)
        
        let scale =  CGAffineTransform(scaleX: 1.0, y: 1.0)
        //let translation = CGAffineTransform(translationX: 0, y: 200)
        self.currentPhotoViewController?.zoomingImageView.transform = scale
        
        
        //print("viewWillTransition constarint is \(constraintHeightSize)")
        
        //        for constraint in self.overlayView.constraints {
        //                              print("constraint \(constraint)")
        //
        //                              if constraint.identifier == "bottomC" {
        //                                  print("constarinttttttt")
        //                             //  constraint.constant = 0
        //                              }
        //                          }
        
        
        self.isSizeTransitioning = true
        
        coordinator.animate(alongsideTransition: { (_) in
            self.isSizeTransitioning = false
            
        }, completion: { (_) in
            
            
        })
        
        //  coordinator.animate(alongsideTransition: nil) { [weak self] (context) in
        
        
        //self?.player.view.frame =  CGRect(x:0, y:0, width: size.width, height: size.height)
        
        
        //             UIView.animate(withDuration: 0.7, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
        //
        //                for constraint in self!.overlayView.constraints {
        //                                              print("constraint \(constraint)")
        //
        //                                              if constraint.identifier == "bottomC" {
        //                                                  print("constarinttttttt")
        //                                               constraint.constant = self!.constraintHeightSize
        //                                              }
        //                                          }
        //
        //                self!.view.layoutSubviews()
        //
        ////
        //                                            }, completion: { _ in
        //
        //                                            })
        
        
        
        
        //     }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.pageViewController.view.frame = self.view.bounds
        self.overlayView.frame = self.view.bounds
        //   self.overlayTopView.frame = self.view.bounds
        
        self.player.view.frame = self.view.bounds
        
        
  
        
        if (view.frame.height > view.frame.width) {
            videoRangeSlider.frame = CGRect(x: 30, y:79, width: view.frame.width - 60, height: 35)
          
          //  selectButton.frame = CGRect(x: view.frame.width - 44.5, y: view.frame.height - 137, width: 36, height: 36)
            
        } else {
            videoRangeSlider.frame = CGRect(x: 40, y:30, width: view.frame.width - 80, height: 35)
          
          //  selectButton.frame = CGRect(x: view.frame.width - 92, y: view.frame.height - 118, width: 36, height: 36)
            
        }
        
        if(!self.isFirstAppearance) {
     //       videoRangeSlider.updateThumbnails()
        }
        
        
        
        // self.frameContainerView.frame = CGRect(x:0, y: 10, width:self.view.bounds.width - 20, height: 30)
        self.overlayView.performAfterShowInterfaceCompletion { [weak self] in
            // if being dismissed, let's just return early rather than update insets
            guard let `self` = self, !self.isBeingDismissed else { return }
            self.updateOverlayInsets()
        }
        
        //        self.overlayTopView.performAfterShowInterfaceCompletion { [weak self] in
        //            // if being dismissed, let's just return early rather than update insets
        //            guard let `self` = self, !self.isBeingDismissed else { return }
        //            self.updateTopOverlayInsets()
        //        }
        
    }
    
    //    func createImageFrames(url: URL)
    //    {
    //        let asset = AVAsset(url: url)
    //
    //        thumbTime = asset.duration
    //        thumbtimeSeconds      = Int(CMTimeGetSeconds(thumbTime))
    //
    //        //creating assets
    //        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
    //        assetImgGenerate.appliesPreferredTrackTransform = true
    //        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
    //        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
    //
    //
    //        assetImgGenerate.appliesPreferredTrackTransform = true
    //        let thumbTime: CMTime = asset.duration
    //        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
    //        let maxLength         = "\(thumbtimeSeconds)" as NSString
    //
    //        let thumbAvg  = thumbtimeSeconds/6
    //        var startTime = 1
    //        var startXPosition:CGFloat = 0.0
    //
    //        //loop for 6 number of frames
    //        for _ in 0...5
    //        {
    //            let imageButton = UIButton()
    //            let xPositionForEach = CGFloat(self.imageFrameView.frame.width)/6
    //            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(self.imageFrameView.frame.height))
    //            do {
    //                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
    //                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
    //                let image = UIImage(cgImage: img)
    //                imageButton.setImage(image, for: .normal)
    //            }
    //            catch
    //                _ as NSError
    //            {
    //                print("Image generation failed with error (error)")
    //            }
    //
    //            startXPosition = startXPosition + xPositionForEach
    //            startTime = startTime + thumbAvg
    //            imageButton.isUserInteractionEnabled = false
    //            imageFrameView.addSubview(imageButton)
    //        }
    //
    //    }
    //
    //    //Create range slider
    //    func createrangSlider()
    //    {
    //        print("createrangSlider")
    //
    //        //Remove slider if already present
    //        let subViews = self.frameContainerView.subviews
    //        for subview in subViews{
    //            if subview.tag == 1000 {
    //                subview.removeFromSuperview()
    //            }
    //
    //        }
    //
    //        rangSlider = RangeSlider(frame: frameContainerView.bounds)
    //        //frameContainerView.frame = CGRect(x: 40, y:80, width: 320, height: 30)
    //
    //        frameContainerView.addSubview(rangSlider)
    //        rangSlider.tag = 1000
    //
    //         print("createrangSlider 2")
    //
    //        //Range slider action
    //        rangSlider.addTarget(self, action: #selector(rangSliderValueChanged(_:)), for: .valueChanged)
    //
    //         print("createrangSlider 3")
    //
    //        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    //        DispatchQueue.main.asyncAfter(deadline: time) {
    //            self.rangSlider.trackHighlightTintColor = UIColor.clear
    //            self.rangSlider.curvaceousness = 1.0
    //        }
    //
    //        print("createrangSlider 4")
    //
    //
    //    }
    //
    //    //MARK: rangSlider Delegate
    //    @objc func rangSliderValueChanged(_ rangSlider: RangeSlider) {
    //        //        self.player.pause()
    //
    //        if(isSliderEnd == true)
    //        {
    //            rangSlider.minimumValue = 0.0
    //            rangSlider.maximumValue = Double(thumbtimeSeconds)
    //
    //            rangSlider.upperValue = Double(thumbtimeSeconds)
    //            isSliderEnd = !isSliderEnd
    //
    //        }
    //
    //        startTimestr = "\(rangSlider.lowerValue)"
    //        endTimestr   = "\(rangSlider.upperValue)"
    //
    //        print(rangSlider.lowerLayerSelected)
    //        if(rangSlider.lowerLayerSelected)
    //        {
    //            self.seekVideo(toPos: CGFloat(rangSlider.lowerValue))
    //
    //        }
    //        else
    //        {
    //            self.seekVideo(toPos: CGFloat(rangSlider.upperValue))
    //
    //        }
    //
    //        print(startTime)
    //    }
    //
    //    //Seek video when slide
    //    func seekVideo(toPos pos: CGFloat) {
    //        self.videoPlaybackPosition = pos
    ////        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: Int32(self.player.currentTime))
    ////        self.player.seekToTime(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    ////
    //
    //        print("pos \(pos)")
    //
    //        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: Int32(self.player.currentTime))
    //        self.player.seek(to: time)
    //                         //toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    //
    //
    ////        if(pos == CGFloat(thumbtimeSeconds))
    ////        {
    ////            self.player.pause()
    ////        }
    //    }
    
    open override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if parent is UINavigationController {
            assertionFailure("Do not embed `PhotosViewController` in a navigation stack.")
            return
        }
        
        self.containerViewController = parent
    }
    
    // MARK: - PhotosViewControllerTransitionAnimatorDelegate
    func transitionController(_ transitionController: AXPhotosTransitionController, didCompletePresentationWith transitionView: UIImageView) {
        guard let photo = self.dataSource.photo(at: self.currentPhotoIndex) else { return }
        
        self.notificationCenter.post(
            name: .photoImageUpdate,
            object: photo,
            userInfo: [
                AXPhotosViewControllerNotification.ReferenceViewKey: transitionView
            ]
        )
    }
    
    func transitionController(_ transitionController: AXPhotosTransitionController, didCompleteDismissalWith transitionView: UIImageView) {
        // empty impl
    }
    
    func transitionControllerDidCancelDismissal(_ transitionController: AXPhotosTransitionController) {
        // empty impl
    }
    
    // MARK: - Dismissal
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }
        
        self.delegate?.photosViewControllerWillDismiss?(self)
        super.dismiss(animated: flag) { [unowned self] in
            let canceled = (self.view.window != nil)
            
            if canceled {
                self.transitionController?.forceNonInteractiveDismissal = false
                #if os(iOS)
                self.panGestureRecognizer?.isEnabled = true
                #endif
            } else {
                self.delegate?.photosViewControllerDidDismiss?(self)
            }
            
            completion?()
        }
    }
    
    // MARK: - Navigation
    
    /// Convenience method to programmatically navigate to a photo
    ///
    /// - Parameters:
    ///   - photoIndex: The index of the photo to navigate to
    ///   - animated: Whether or not to animate the transition
    @objc public func navigateToPhotoIndex(_ photoIndex: Int, animated: Bool) {
        if photoIndex < 0 || photoIndex > (self.dataSource.numberOfPhotos - 1) {
            return
        }
        
        guard let photoViewController = self.makePhotoViewController(for: photoIndex) else { return }
        
        
        let forward = (photoIndex > self.currentPhotoIndex)
        self.pageViewController.setViewControllers([photoViewController],
                                                   direction: forward ? .forward : .reverse,
                                                   animated: animated,
                                                   completion: nil)
        self.loadPhotos(at: photoIndex)
    }
    
    // MARK: - Page VC Configuration
    fileprivate func configurePageViewController() {
        func configure(with viewController: UIViewController, pageIndex: Int) {
            self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
            self.currentPhotoIndex = pageIndex
            
            #if os(iOS)
            self.overlayView.titleView?.tweenBetweenLowIndex?(pageIndex, highIndex: pageIndex + 1, percent: 0)
            //self.overlayTopView.titleView?.tweenBetweenLowIndex?(pageIndex, highIndex: pageIndex + 1, percent: 0)
            
            #endif
        }
        
        guard let photoViewController = self.makePhotoViewController(for: self.dataSource.initialPhotoIndex) else {
            configure(with: UIViewController(), pageIndex: 0)
            return
        }
        
        configure(with: photoViewController, pageIndex: photoViewController.pageIndex)
        self.loadPhotos(at: self.dataSource.initialPhotoIndex)
    }
    
    
    //    let playButton: UIButton = {
    //        let button = UIButton()
    //        button.frame = CGRect(x: 200, y: 200, width: 50, height: 50)
    //        button.contentHorizontalAlignment = .fill
    //        button.contentVerticalAlignment = .fill
    //        button.imageView?.contentMode = .scaleAspectFill
    //        button.setImage(UIImage(named: "button_playvideo", in: AXBundle.frameworkBundle, compatibleWith: nil), for: .normal)
    //
    //
    //
    //        // button.backgroundColor = .green
    //        button.isHidden = true
    //        return button
    //    }()
    
    // MARK: - Overlay
    fileprivate func updateOverlay(for photoIndex: Int) {
        print("photoIndex \(photoIndex)")
        guard let photo = self.dataSource.photo(at: photoIndex) else { return }
        
        //removing player
        self.player.stop()
        self.player.willMove(toParent: nil)
        self.player.view.removeFromSuperview()
        self.player.removeFromParent()
       // self.videoRangeSlider.isHidden = true
        //
        
        if (self.dataSource.selectedPhotos.count > 0) {
            //self.selectButton.selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
            // self.selectButton.setTitle(title: String(self.dataSource.selectedPhotos.count))
            selectButton.currentValue = self.dataSource.selectedPhotos.count
            
        }
        
        
        if (self.dataSource.selectedPhotos.contains(photo.imageAsset!)) {
            //selectButton.selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
            // selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .selected)
            
            selectButton.setBackgroundColor(color: UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1))
            
            
            
            print("String(self.dataSource.selectedPhotos.count) \(String(self.dataSource.selectedPhotos.count))")
            
        } else {
            selectButton.setBackgroundColor(color:.clear)
        }
        
        self.willUpdate(overlayView: self.overlayView, for: photo, at: photoIndex, totalNumberOfPhotos: self.dataSource.numberOfPhotos)
        //self.willUpdateTop(overlayTopView: self.overlayTopView, for: photo, at: photoIndex, totalNumberOfPhotos: self.dataSource.numberOfPhotos)
        
        #if os(iOS)
        if self.dataSource.numberOfPhotos > 1 {
            //self.overlayView.internalTitle = String.localizedStringWithFormat(NSLocalizedString("%d of %d", comment: ""), photoIndex + 1, self.dataSource.numberOfPhotos)
            // self.overlayTopView.internalTitle = String.localizedStringWithFormat(NSLocalizedString("%d of %d", comment: ""), photoIndex + 1, self.dataSource.numberOfPhotos)
        } else {
            self.overlayView.internalTitle = nil
            // self.overlayTopView.internalTitle = nil
        }
        #endif
        
        if(photo.imageAsset?.mediaType == .video) {
            print("video here22")
            
            self.video3(forAsset: photo.imageAsset!, completion: { (assetURL) in
                self.player.url = assetURL
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //!!!    self.videoRangeSlider.isHidden = false
                //                }
                self.videoRangeSlider.setVideoURL(videoURL: assetURL!)
                self.currentPhotoViewController?.zoomingImageView.isVideo = true
                
                
                
                //self.attributedText2 = NSAttributedString(string: "33333", attributes: self.defaultAttributes())
                
                
                
            })
            self.view.layoutSubviews()
            //self.videoRangeSlider.isHidden = false
            
        } else {
            self.videoRangeSlider.isHidden = true
            self.currentPhotoViewController?.zoomingImageView.isVideo = false
        }
      
        
        self.overlayView.updateCaptionView(photo: photo)
    }
    
    open func video3(forAsset asset: PHAsset, isNeedDegraded: Bool = true, completion: @escaping ((URL?) -> Void)) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .mediumQualityFormat
        DispatchQueue.main.async {
            
            PHCachingImageManager.default().requestAVAsset(
                forVideo: asset,
                options: options,
                resultHandler: { (asset, audioMix, info) -> Void in
                    if asset != nil {
                        // let avasset = asset as! AVURLAsset
                        let urlVideo = (asset as! AVURLAsset).url
                        completion(urlVideo)
                    }
                    
            })
        }
    }
    
    fileprivate func updateOverlayInsets() {
        var contentInset: UIEdgeInsets
        if #available(iOS 11.0, tvOS 11.0, *) {
            contentInset = self.view.safeAreaInsets
        } else {
            #if os(iOS)
            contentInset = UIEdgeInsets(
                top: (UIApplication.shared.statusBarFrame.size.height > 0) ? 20 : 0,
                left: 0,
                bottom: 0,
                right: 0
            )
            #else
            contentInset = UIEdgeInsets(
                top: 60,
                left: 90,
                bottom: 60,
                right: 90
            )
            #endif
        }
        
        self.overlayView.contentInset = contentInset
    }
    
    fileprivate func updateTopOverlayInsets() {
        var contentInset: UIEdgeInsets
        if #available(iOS 11.0, tvOS 11.0, *) {
            contentInset = self.view.safeAreaInsets
            print("<><>contentInset0 \(contentInset)")
            
        } else {
            #if os(iOS)
            contentInset = UIEdgeInsets(
                top: (UIApplication.shared.statusBarFrame.size.height > 0) ? 30 : 0,
                left: 0,
                bottom: 0,
                right: 0
            )
            print("<><>contentInset1 \(contentInset)")
            
            #else
            contentInset = UIEdgeInsets(
                top: 10,
                left: 90,
                bottom: 40,
                right: 90
            )
            print("<><>contentInset2 \(contentInset)")
            
            #endif
        }
        
        //self.overlayTopView.contentInset = contentInset
    }
    
    // MARK: - Gesture recognizers
    @objc fileprivate func didSingleTapWithGestureRecognizer(_ sender: UITapGestureRecognizer) {
        
        player.pause()
        hideKeyboard()
        
        //        let show = (self.overlayView.alpha == 0)
        //        self.overlayView.setShowInterface(show, animated: true, alongside: { [weak self] in
        //            guard let `self` = self else { return }
        //
        //            #if os(iOS)
        //            self.updateStatusBarAppearance(show: show)
        //            #endif
        //
        //            self.overlayView(self.overlayView, visibilityWillChange: show)
        //        })
    }
    
    #if os(iOS)
    @objc fileprivate func didPanWithGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.transitionController?.forceNonInteractiveDismissal = false
            self.dismiss(animated: true, completion: nil)
        }
        
        self.transitionController?.didPanWithGestureRecognizer(sender, in: self.containerViewController ?? self)
    }
    
    fileprivate func updateStatusBarAppearance(show: Bool) {
        self.ax_prefersStatusBarHidden = !show
        self.setNeedsStatusBarAppearanceUpdate()
        if show {
            UIView.performWithoutAnimation { [weak self] in
                self?.updateOverlayInsets()
                self?.updateTopOverlayInsets()
                self?.overlayView.setNeedsLayout()
                self?.overlayView.layoutIfNeeded()
                // self?.overlayTopView.setNeedsLayout()
                // self?.overlayTopView.layoutIfNeeded()
            }
        }
    }
    
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
    
    // MARK: - Default bar button actions
    @objc public func shareAction(_ barButtonItem: UIBarButtonItem) {
        guard let photo = self.dataSource.photo(at: self.currentPhotoIndex) else { return }
        
        if self.handleActionButtonTapped(photo: photo) {
            return
        }
        
        var anyRepresentation: Any?
        if let imageAsset = photo.imageAsset {
            anyRepresentation = imageAsset
        } else if let imageData = photo.imageData {
            anyRepresentation = imageData
        } else if let image = photo.image {
            anyRepresentation = image
        }
        
        guard let uAnyRepresentation = anyRepresentation else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [uAnyRepresentation], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, activityError) in
            guard let `self` = self else { return }
            
            if completed, let activityType = activityType {
                self.actionCompleted(activityType: activityType, for: photo)
            }
        }
        
        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        self.present(activityViewController, animated: true)
    }
    
    @objc public func closeAction(_ sender: UIBarButtonItem) {
        print("close button clicked")
        self.transitionController?.forceNonInteractiveDismissal = true
        self.dismiss(animated: true)
    }
    #endif
    
    // MARK: - Loading helpers
    fileprivate func loadPhotos(at index: Int) {
        let numberOfPhotosToLoad = self.dataSource.prefetchBehavior.rawValue
        let startIndex = (((index - (numberOfPhotosToLoad / 2)) >= 0) ? (index - (numberOfPhotosToLoad / 2)) : 0)
        let indexes = startIndex...(startIndex + numberOfPhotosToLoad)
        
        for index in indexes {
            guard let photo = self.dataSource.photo(at: index) else { return }
            
            if photo.ax_loadingState == .notLoaded || photo.ax_loadingState == .loadingCancelled {
                photo.ax_loadingState = .loading
                self.networkIntegration.loadPhoto(photo)
            }
        }
    }
    
    fileprivate func reduceMemoryForPhotos(at index: Int) {
        let numberOfPhotosToLoad = self.dataSource.prefetchBehavior.rawValue
        let lowerIndex = (index - (numberOfPhotosToLoad / 2) - 1 >= 0) ? index - (numberOfPhotosToLoad / 2) - 1: NSNotFound
        let upperIndex = (index + (numberOfPhotosToLoad / 2) + 1 < self.dataSource.numberOfPhotos) ? index + (numberOfPhotosToLoad / 2) + 1 : NSNotFound
        
        weak var weakSelf = self
        func reduceMemory(for photo: AXPhotoProtocol) {
            guard let `self` = weakSelf else { return }
            
            if photo.ax_loadingState == .loading {
                self.networkIntegration.cancelLoad(for: photo)
                photo.ax_loadingState = .loadingCancelled
            } else if photo.ax_loadingState == .loaded && photo.ax_isReducible {
                photo.imageData = nil
                photo.image = nil
                photo.ax_animatedImage = nil
                photo.ax_loadingState = .notLoaded
            }
        }
        
        if lowerIndex != NSNotFound, let photo = self.dataSource.photo(at: lowerIndex) {
            reduceMemory(for: photo)
        }
        
        if upperIndex != NSNotFound, let photo = self.dataSource.photo(at: upperIndex) {
            reduceMemory(for: photo)
        }
    }
    
    // MARK: - Reuse / Factory
    fileprivate func makePhotoViewController(for pageIndex: Int) -> AXPhotoViewController? {
        guard let photo = self.dataSource.photo(at: pageIndex) else { return nil }
        
        var photoViewController: AXPhotoViewController
        
        if self.recycledViewControllers.count > 0 {
            photoViewController = self.recycledViewControllers.removeLast()
            photoViewController.prepareForReuse()
        } else {
            guard let loadingView = self.makeLoadingView(for: pageIndex) else { return nil }
            
            photoViewController = AXPhotoViewController(loadingView: loadingView, notificationCenter: self.notificationCenter)
            photoViewController.addLifecycleObserver(self)
            photoViewController.delegate = self
            
            #if os(iOS)
            self.singleTapGestureRecognizer.require(toFail: photoViewController.zoomingImageView.doubleTapGestureRecognizer)
            #endif
        }
        
        photoViewController.pageIndex = pageIndex
        photoViewController.applyPhoto(photo)
        
        let insertionIndex = self.orderedViewControllers.insertionIndex(of: photoViewController, isOrderedBefore: { $0.pageIndex < $1.pageIndex })
        self.orderedViewControllers.insert(photoViewController, at: insertionIndex.index)
        
        return photoViewController
    }
    
    fileprivate func makeLoadingView(for pageIndex: Int) -> AXLoadingViewProtocol? {
        guard let loadingViewType = self.pagingConfig.loadingViewClass as? UIView.Type else {
            assertionFailure("`loadingViewType` must be a UIView.")
            return nil
        }
        
        return loadingViewType.init() as? AXLoadingViewProtocol
    }
    
    // MARK: - Recycling
    fileprivate func recyclePhotoViewController(_ photoViewController: AXPhotoViewController) {
        if self.recycledViewControllers.contains(photoViewController) {
            return
        }
        
        if let index = self.orderedViewControllers.firstIndex(of: photoViewController) {
            self.orderedViewControllers.remove(at: index)
        }
        
        self.recycledViewControllers.append(photoViewController)
    }
    
    // MARK: - KVO
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &PhotoViewControllerLifecycleContext {
            self.lifecycleContextDidUpdate(object: object, change: change)
        } else if context == &PhotoViewControllerContentOffsetContext {
            self.contentOffsetContextDidUpdate(object: object, change: change)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func lifecycleContextDidUpdate(object: Any?, change: [NSKeyValueChangeKey : Any]?) {
        guard let photoViewController = object as? AXPhotoViewController else { return }
        print("lifecycleContextDidUpdate")
        // photoViewController.didMoveToAnotherAsset()
        if change?[.newKey] is NSNull {
            self.recyclePhotoViewController(photoViewController)
        }
    }
    
    fileprivate func contentOffsetContextDidUpdate(object: Any?, change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = object as? UIScrollView, !self.isSizeTransitioning else { return }
        
        var percent: CGFloat
        if self.pagingConfig.navigationOrientation == .horizontal {
            percent = (scrollView.contentOffset.x - scrollView.frame.size.width) / scrollView.frame.size.width
        } else {
            percent = (scrollView.contentOffset.y - scrollView.frame.size.height) / scrollView.frame.size.height
        }
        
        var horizontalSwipeDirection: SwipeDirection = .none
        if percent > 0 {
            horizontalSwipeDirection = .right
        } else if percent < 0 {
            horizontalSwipeDirection = .left
        }
        
        //print("percent \(percent)")
        videoRangeSlider.alpha = 2 * abs(0.5 - abs(percent));
        
        let layoutDirection: UIUserInterfaceLayoutDirection
        if #available(iOS 9.0, tvOS 9.0, *) {
            layoutDirection = UIView.userInterfaceLayoutDirection(for: self.pageViewController.view.semanticContentAttribute)
        } else {
            layoutDirection = .leftToRight
        }
        
        let swipePercent: CGFloat
        if horizontalSwipeDirection == .left {
            if layoutDirection == .leftToRight {
                swipePercent = 1 - abs(percent)
            } else {
                swipePercent = abs(percent)
            }
        } else {
            if layoutDirection == .leftToRight {
                swipePercent = abs(percent)
            } else {
                swipePercent = 1 - abs(percent)
            }
        }
        
        var lowIndex: Int = NSNotFound
        var highIndex: Int = NSNotFound
        
        let viewControllers = self.computeVisibleViewControllers(in: scrollView)
        if horizontalSwipeDirection == .left {
            guard let viewController = viewControllers.first else { return }
            
            if viewControllers.count > 1 {
                lowIndex = viewController.pageIndex
                if lowIndex < self.dataSource.numberOfPhotos {
                    highIndex = lowIndex + 1
                }
            } else {
                highIndex = viewController.pageIndex
            }
        } else if horizontalSwipeDirection == .right {
            guard let viewController = viewControllers.last else { return }
            
            if viewControllers.count > 1 {
                highIndex = viewController.pageIndex
                if highIndex > 0 {
                    lowIndex = highIndex - 1
                }
            } else {
                lowIndex = viewController.pageIndex
            }
        }
        
        guard lowIndex != NSNotFound && highIndex != NSNotFound else {
            return
        }
        
        if swipePercent < 0.5 && self.currentPhotoIndex != lowIndex  {
            self.currentPhotoIndex = lowIndex
            
            if let photo = self.dataSource.photo(at: lowIndex) {
                self.didNavigateTo(photo: photo, at: lowIndex)
            }
        } else if swipePercent > 0.5 && self.currentPhotoIndex != highIndex {
            self.currentPhotoIndex = highIndex
            
            if let photo = self.dataSource.photo(at: highIndex) {
                self.didNavigateTo(photo: photo, at: highIndex)
            }
        }
        
        #if os(iOS)
        self.overlayView.titleView?.tweenBetweenLowIndex?(lowIndex, highIndex: highIndex, percent: percent)
        #endif
    }
    
    fileprivate func computeVisibleViewControllers(in referenceView: UIScrollView) -> [AXPhotoViewController] {
        var visibleViewControllers = [AXPhotoViewController]()
        
        for viewController in self.orderedViewControllers {
            if viewController.view.frame.equalTo(.zero) {
                continue
            }
            
            let origin = CGPoint(x: viewController.view.frame.origin.x - (self.pagingConfig.navigationOrientation == .horizontal ?
                (self.pagingConfig.interPhotoSpacing / 2) : 0),
                                 y: viewController.view.frame.origin.y - (self.pagingConfig.navigationOrientation == .vertical ?
                                    (self.pagingConfig.interPhotoSpacing / 2) : 0))
            let size = CGSize(width: viewController.view.frame.size.width + ((self.pagingConfig.navigationOrientation == .horizontal) ?
                self.pagingConfig.interPhotoSpacing : 0),
                              height: viewController.view.frame.size.height + ((self.pagingConfig.navigationOrientation == .vertical) ?
                                self.pagingConfig.interPhotoSpacing : 0))
            let conversionRect = CGRect(origin: origin, size: size)
            
            if let fromView = viewController.view.superview, referenceView.convert(conversionRect, from: fromView).intersects(referenceView.bounds) {
                visibleViewControllers.append(viewController)
            }
        }
        
        return visibleViewControllers
    }
    
    // MARK: - UIPageViewControllerDataSource
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? AXPhotoViewController else { return }
        self.loadPhotos(at: viewController.pageIndex)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.first as? AXPhotoViewController else { return }
        self.reduceMemoryForPhotos(at: viewController.pageIndex)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let uViewController = viewController as? AXPhotoViewController else {
            assertionFailure("Paging VC must be a subclass of `AXPhotoViewController`.")
            return nil
        }
        
        return self.pageViewController(pageViewController, viewControllerAt: uViewController.pageIndex - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let uViewController = viewController as? AXPhotoViewController else {
            assertionFailure("Paging VC must be a subclass of `AXPhotoViewController`.")
            return nil
        }
        
        return self.pageViewController(pageViewController, viewControllerAt: uViewController.pageIndex + 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAt index: Int) -> UIViewController? {
        guard index >= 0 && self.dataSource.numberOfPhotos > index else { return nil }
        return self.makePhotoViewController(for: index)
    }
    
    // MARK: - AXPhotoViewControllerDelegate
    public func photoViewController(_ photoViewController: AXPhotoViewController, retryDownloadFor photo: AXPhotoProtocol) {
        guard photo.ax_loadingState != .loading && photo.ax_loadingState != .loaded else { return }
        photo.ax_error = nil
        photo.ax_loadingState = .loading
        self.networkIntegration.loadPhoto(photo)
    }
    
    //    @objc public func selectPhotoButtonClicked() {
    //        print("selectPhotoButtonClicked")
    //        if (selectButton.backgroundColor == .clear) {
    //            if let photo = self.dataSource.photo(at: currentPhotoIndex) {
    //                        print("selectPhotoButtonClicked")
    //                       print("String(self.dataSource.selectedPhotos.count \(self.dataSource.selectedPhotos.count)")
    //
    //                       self.didSelectPhoto(photo: photo, at: currentPhotoIndex)
    //
    //                //photo.imageAsset
    //
    //                self.dataSource.selectedPhotos.append(photo.imageAsset!)
    //
    //
    //                print("String(self.dataSource.selectedPhotos.count \(self.dataSource.selectedPhotos.count)")
    //
    //                      // self.selectButton.setTitle("100", for: .normal)
    //                       //self.selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
    //                     //  selectButton.setTitle(String(self.dataSource.selectedPhotos.count + 1), for: .normal)
    //                       selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
    //
    //                                selectButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    //
    //                selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
    //
    //                                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
    //                                    self.selectButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    //
    //                                }, completion: { _ in
    //
    //                                })
    //
    //
    //                   }
    //        }
    //        else {
    //            selectButton.backgroundColor = .clear
    //            if let photo = self.dataSource.photo(at: currentPhotoIndex) {
    //                        print("selectPhotoButtonClicked")
    //                       print("String(self.dataSource.selectedPhotos.count \(self.dataSource.selectedPhotos.count)")
    //
    //                       self.didSelectPhoto(photo: photo, at: currentPhotoIndex)
    //
    //                if let ind = self.dataSource.selectedPhotos.index(of: photo.imageAsset!){
    //                  self.dataSource.selectedPhotos.remove(at: ind)
    //                }
    //
    //
    //                      // self.selectButton.setTitle("100", for: .normal)
    //                       //self.selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
    //                //selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
    //
    //                if (self.dataSource.selectedPhotos.count > 0) {
    //                      selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
    //                       }
    //                else {
    //                    self.selectButton.setTitle("", for: .normal)
    //
    //                }
    //
    //                selectButton.backgroundColor = UIColor.clear
    //
    //
    //                selectButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    //
    //
    //
    //                                               UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
    //                                                   self.selectButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    //
    //                                               }, completion: { _ in
    //
    //                                               })
    //
    //
    //                   }
    //        }
    //
    //
    //       // updateOverlay(for: currentPhotoIndex)
    //
    //    }
    //
    
    
    @objc public func selectPhotoButtonClicked() {
        print("selectPhotoButtonClicked")
        if (selectButton.getBackgroundColor() == .clear) {
            if let photo = self.dataSource.photo(at: currentPhotoIndex) {
                print("selectPhotoButtonClicked")
                print("String(self.dataSource.selectedPhotos.count \(self.dataSource.selectedPhotos.count)")
                
                self.didSelectPhoto(photo: photo, at: currentPhotoIndex)
                
                //photo.imageAsset
                
                self.dataSource.selectedPhotos.append(photo.imageAsset!)
                
                
                print("String(self.dataSource.selectedPhotos.count \(self.dataSource.selectedPhotos.count)")
                
                
                // selectButton.selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
                selectButton.currentValue = self.dataSource.selectedPhotos.count
                
                selectButton.backgroundView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                selectButton.setBackgroundColor(color: UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1))
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear, .transitionCrossDissolve], animations: {
                    self.selectButton.backgroundView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    
                }, completion: { _ in
                    
                })
                
                
            }
        }
        else {
            if let photo = self.dataSource.photo(at: currentPhotoIndex) {
                print("selectPhotoButtonClicked")
                print("String(self.dataSource.selectedPhotos.count2 \(self.dataSource.selectedPhotos.count)")
                
                self.didSelectPhoto(photo: photo, at: currentPhotoIndex)
                
                if let ind = self.dataSource.selectedPhotos.index(of: photo.imageAsset!){
                    print("removing photo")
                    self.dataSource.selectedPhotos.remove(at: ind)
                }
                print("String(self.dataSource.selectedPhotos.count3 \(self.dataSource.selectedPhotos.count)")
                
                
                // self.selectButton.setTitle("100", for: .normal)
                //self.selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
                //selectButton.setTitle(String(self.dataSource.selectedPhotos.count), for: .normal)
                
                if (self.dataSource.selectedPhotos.count > 0) {
                    selectButton.setBackgroundColor(color: UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1))
                    // selectButton.setTitle(title:String(self.dataSource.selectedPhotos.count))
                    selectButton.currentValue = self.dataSource.selectedPhotos.count
                    
                }
                else {
                    // self.selectButton.setTitle(title: "")
                    selectButton.currentValue = 0
                    
                    
                }
                
                //selectButton.backgroundColor = UIColor.clear
                
                
                selectButton.selectButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear, .transitionCrossDissolve], animations: {
                    self.selectButton.backgroundView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    
                }, completion: { _ in
                    self.selectButton.setBackgroundColor(color: UIColor.clear)
                    self.selectButton.backgroundView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    
                })
                
                
            }
        }
        
        
        // updateOverlay(for: currentPhotoIndex)
        
    }
    
    
    
    public func playButtonPressed(_ photoViewController: AXPhotoViewController) {
        print("playButtonPressed in AXPhotosViewController")
        
        
        self.player.view.frame = photoViewController.zoomingImageView.imageView.frame
        
        
        photoViewController.addChild(self.player)
        
        //photoViewController.zoomingImageView.imageView.isHidden = true
        
        //self.view.addSubview(self.player.view)
        
        //self.view.addSubview(self.player.view)
        
        
        
        //photoViewController.zoomingImageView.imageView.layer.addSublayer(self.player.view.layer)
        
        //photoViewController.zoomingImageView.imageView.addSubview(self.player.view)
        
        photoViewController.view.addSubview(self.player.view)
        
        
        self.player.didMove(toParent: photoViewController)
        player.playFromBeginning()
        currentPhotoViewControllerForPlayer = photoViewController
        
        //        self.createImageFrames(url: self.player.url!)
        //
        //        isSliderEnd = true
        //        startTimestr = "\(0.0)"
        //        endTimestr   = "\(thumbtimeSeconds!)"
        //        self.createrangSlider()
        
        
        
        
    }
    
    public func photoViewController(_ photoViewController: AXPhotoViewController,
                                    maximumZoomScaleForPhotoAt index: Int,
                                    minimumZoomScale: CGFloat,
                                    imageSize: CGSize) -> CGFloat {
        guard let photo = self.dataSource.photo(at: index) else { return .leastNormalMagnitude }
        return self.maximumZoomScale(for: photo, minimumZoomScale: minimumZoomScale, imageSize: imageSize)
    }
    
    // MARK: - AXPhotosViewControllerDelegate calls
    
    /// Called when the `AXPhotosViewController` navigates to a new photo. This is defined as when the swipe percent between pages
    /// is greater than the threshold (>0.5).
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The `AXPhoto` that was navigated to.
    ///   - index: The `index` in the dataSource of the `AXPhoto` being transitioned to.
    @objc(didNavigateToPhoto:atIndex:)
    open func didNavigateTo(photo: AXPhotoProtocol, at index: Int) {
        
        self.delegate?.photosViewController?(self, didNavigateTo: photo, at: index)
        //videoRangeSlider.updateThumbnails()
        
    }
    
    @objc(didSelectPhoto:atIndex:)
    open func didSelectPhoto(photo: AXPhotoProtocol, at index: Int) {
        self.delegate?.photosViewController?(self, didSelectPhoto: photo, at: index)
    }
    
    /// Called when the `AXPhotosViewController` is configuring its `OverlayView` for a new photo. This should be used to update the
    /// the overlay's title or any other overlay-specific properties.
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - overlayView: The `AXOverlayView` that is being updated.
    ///   - photo: The `AXPhoto` the overlay is being configured for.
    ///   - index: The index of the `AXPhoto` that the overlay is being configured for.
    ///   - totalNumberOfPhotos: The total number of photos in the current `dataSource`.
    @objc(willUpdateOverlayView:forPhoto:atIndex:totalNumberOfPhotos:)
    open func willUpdate(overlayView: AXOverlayView, for photo: AXPhotoProtocol, at index: Int, totalNumberOfPhotos: Int) {
        self.delegate?.photosViewController?(self,
                                             willUpdate: overlayView,
                                             for: photo,
                                             at: index,
                                             totalNumberOfPhotos: totalNumberOfPhotos)
    }
    
    //    @objc(willUpdateTopOverlayView:forPhoto:atIndex:totalNumberOfPhotos:)
    //    open func willUpdateTop(overlayTopView: AXOverlayTopView, for photo: AXPhotoProtocol, at index: Int, totalNumberOfPhotos: Int) {
    //        self.delegate?.photosViewController?(self,
    //                                             willUpdateTop: overlayTopView,
    //                                             for: photo,
    //                                             at: index,
    //                                             totalNumberOfPhotos: totalNumberOfPhotos)
    //    }
    
    /// Called when the `AXPhotoViewController` will show/hide its `OverlayView`. This method will be called inside of an
    /// animation context, so perform any coordinated animations here.
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - overlayView: The `AXOverlayView` whose visibility is changing.
    ///   - visible: A boolean that denotes whether or not the overlay will be visible or invisible.
    @objc
    open func overlayView(_ overlayView: AXOverlayView, visibilityWillChange visible: Bool) {
        self.delegate?.photosViewController?(self,
                                             overlayView: overlayView,
                                             visibilityWillChange: visible)
    }
    
    //    @objc
    //    open func overlayTopView(_ overlayTopView: AXOverlayTopView, visibilityWillChangeTop visible: Bool) {
    //        self.delegate?.photosViewController?(self,
    //                                             overlayView: overlayTopView,
    //                                             visibilityWillChangeTop: visible)
    //    }
    
    /// If implemented and returns a valid zoom scale for the photo (valid meaning >= the photo's minimum zoom scale), the underlying
    /// zooming image view will adopt the returned `maximumZoomScale` instead of the default calculated by the library. A good implementation
    /// of this method will use a combination of the provided `minimumZoomScale` and `imageSize` to extrapolate a `maximumZoomScale` to return.
    /// If the `minimumZoomScale` is returned (ie. `minimumZoomScale` == `maximumZoomScale`), zooming will be disabled for this image.
    ///
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The `Photo` that the zoom scale will affect.
    ///   - minimumZoomScale: The minimum zoom scale that is calculated by the library. This value cannot be changed.
    ///   - imageSize: The size of the image that belongs to the `AXPhoto`.
    /// - Returns: A "maximum" zoom scale that >= `minimumZoomScale`.
    @objc(maximumZoomScaleForPhoto:minimumZoomScale:imageSize:)
    open func maximumZoomScale(for photo: AXPhotoProtocol, minimumZoomScale: CGFloat, imageSize: CGSize) -> CGFloat {
        return self.delegate?.photosViewController?(self,
                                                    maximumZoomScaleFor: photo,
                                                    minimumZoomScale: minimumZoomScale,
                                                    imageSize: imageSize) ?? .leastNormalMagnitude
    }
    
    #if os(iOS)
    /// Called when the action button is tapped for a photo. If you override this and fail to call super, the corresponding
    /// delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The related `AXPhoto`.
    /// 
    /// - Returns:
    ///   true if the action button tap was handled, false if the default action button behavior
    ///   should be invoked.
    @objc(handleActionButtonTappedForPhoto:)
    open func handleActionButtonTapped(photo: AXPhotoProtocol) -> Bool {
        if let _ = self.delegate?.photosViewController?(self, handleActionButtonTappedFor: photo) {
            return true
        }
        
        return false
    }
    
    /// Called when an action button action is completed. If you override this and fail to call super, the corresponding
    /// delegate method **will not be called!**
    ///
    /// - Parameters:
    ///   - photo: The related `AXPhoto`.
    /// - Note: This is only called for the default action.
    @objc(actionCompletedWithActivityType:forPhoto:)
    open func actionCompleted(activityType: UIActivity.ActivityType, for photo: AXPhotoProtocol) {
        self.delegate?.photosViewController?(self, actionCompletedWith: activityType, for: photo)
    }
    #endif
    
    // MARK: - AXNetworkIntegrationDelegate
    public func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol, loadDidFinishWith photo: AXPhotoProtocol) {
        if let imageAsset = photo.imageAsset {
            
            print("networkIntegration photo.imageAsset")
            DispatchQueue.main.async { [weak self] in
                var picture:UIImage?
                self?.image(forAsset: imageAsset, completion: { (image) in
                    picture = image
                    print("networkIntegration \(picture)")
                    photo.ax_loadingState = .loaded
                    self?.notificationCenter.post(name: .photoImageUpdate,
                                                  object: photo,
                                                  userInfo: [
                                                    AXPhotosViewControllerNotification.AnimatedImageKey: picture,
                                                    AXPhotosViewControllerNotification.LoadingStateKey: AXPhotoLoadingState.loaded
                    ])
                    
                })
                
                
            }
        } else if let animatedImage = photo.ax_animatedImage {
            photo.ax_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(name: .photoImageUpdate,
                                              object: photo,
                                              userInfo: [
                                                AXPhotosViewControllerNotification.AnimatedImageKey: animatedImage,
                                                AXPhotosViewControllerNotification.LoadingStateKey: AXPhotoLoadingState.loaded
                ])
            }
        } else if let imageData = photo.imageData, let animatedImage = FLAnimatedImage(animatedGIFData: imageData) {
            photo.ax_animatedImage = animatedImage
            photo.ax_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(name: .photoImageUpdate,
                                              object: photo,
                                              userInfo: [
                                                AXPhotosViewControllerNotification.AnimatedImageKey: animatedImage,
                                                AXPhotosViewControllerNotification.LoadingStateKey: AXPhotoLoadingState.loaded
                ])
            }
        } else if let image = photo.image {
            photo.ax_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(name: .photoImageUpdate,
                                              object: photo,
                                              userInfo: [
                                                AXPhotosViewControllerNotification.ImageKey: image,
                                                AXPhotosViewControllerNotification.LoadingStateKey: AXPhotoLoadingState.loaded
                ])
            }
        }
    }
    
    public func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol, loadDidFailWith error: Error, for photo: AXPhotoProtocol) {
        guard photo.ax_loadingState != .loadingCancelled else {
            return
        }
        
        photo.ax_loadingState = .loadingFailed
        photo.ax_error = error
        DispatchQueue.main.async { [weak self] in
            self?.notificationCenter.post(name: .photoImageUpdate,
                                          object: photo,
                                          userInfo: [
                                            AXPhotosViewControllerNotification.ErrorKey: error,
                                            AXPhotosViewControllerNotification.LoadingStateKey: AXPhotoLoadingState.loadingFailed
            ])
        }
    }
    
    public func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol, didUpdateLoadingProgress progress: CGFloat, for photo: AXPhotoProtocol) {
        photo.ax_progress = progress
        DispatchQueue.main.async { [weak self] in
            self?.notificationCenter.post(name: .photoLoadingProgressUpdate,
                                          object: photo,
                                          userInfo: [AXPhotosViewControllerNotification.ProgressKey: progress])
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let currentPhotoIndex = self.currentPhotoIndex
        let dataSource = self.dataSource
        let zoomingImageView = self.currentPhotoViewController?.zoomingImageView
        let pagingConfig = self.pagingConfig
        
        guard !(zoomingImageView?.isScrollEnabled ?? true)
            && (pagingConfig.navigationOrientation == .horizontal
                || (pagingConfig.navigationOrientation == .vertical
                    && (currentPhotoIndex == 0 || currentPhotoIndex == dataSource.numberOfPhotos - 1))) else {
                        return false
        }
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            
            let isVertical = abs(velocity.y) > abs(velocity.x)
            guard isVertical else {
                return false
            }
            
            if pagingConfig.navigationOrientation == .horizontal {
                return true
            } else {
                if currentPhotoIndex == 0 {
                    return velocity.y > 0
                } else {
                    return velocity.y < 0
                }
            }
        }
        
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

// MARK: - Convenience extensions
fileprivate var PhotoViewControllerLifecycleContext: UInt8 = 0
fileprivate extension Array where Element: UIViewController {
    
    func removeLifeycleObserver(_ observer: NSObject) -> Void {
        self.forEach({ ($0 as UIViewController).removeLifecycleObserver(observer) })
    }
    
}

fileprivate extension UIViewController {
    
    func addLifecycleObserver(_ observer: NSObject) -> Void {
        self.addObserver(observer, forKeyPath: #keyPath(parent), options: .new, context: &PhotoViewControllerLifecycleContext)
    }
    
    func removeLifecycleObserver(_ observer: NSObject) -> Void {
        self.removeObserver(observer, forKeyPath: #keyPath(parent), context: &PhotoViewControllerLifecycleContext)
    }
    
}

fileprivate extension UIPageViewController {
    
    var scrollView: UIScrollView {
        get {
            guard let scrollView = self.view.subviews.filter({ $0 is UIScrollView }).first as? UIScrollView else {
                fatalError("Unable to locate the underlying `UIScrollView`")
            }
            
            return scrollView
        }
    }
    
}

fileprivate var PhotoViewControllerContentOffsetContext: UInt8 = 0
fileprivate extension UIScrollView {
    
    func addContentOffsetObserver(_ observer: NSObject) -> Void {
        self.addObserver(observer, forKeyPath: #keyPath(contentOffset), options: .new, context: &PhotoViewControllerContentOffsetContext)
    }
    
    func removeContentOffsetObserver(_ observer: NSObject) -> Void {
        self.removeObserver(observer, forKeyPath: #keyPath(contentOffset), context: &PhotoViewControllerContentOffsetContext)
    }
    
}

// MARK: - AXPhotosViewControllerDelegate
@objc public protocol AXPhotosViewControllerDelegate: AnyObject, NSObjectProtocol {
    
    /// Called when the `AXPhotosViewController` navigates to a new photo. This is defined as when the swipe percent between pages
    /// is greater than the threshold (>0.5).
    ///
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is navigating.
    ///   - photo: The `AXPhoto` that was navigated to.
    ///   - index: The `index` in the dataSource of the `AXPhoto` being transitioned to.
    @objc(photosViewController:didNavigateToPhoto:atIndex:)
    optional func photosViewController(_ photosViewController: AXPhotosViewController,
                                       didNavigateTo photo: AXPhotoProtocol,
                                       at index: Int)
    
    @objc(photosViewController:didSelectPhoto:atIndex:)
    optional func photosViewController(_ photosViewController: AXPhotosViewController,
                                       didSelectPhoto photo: AXPhotoProtocol,
                                       at index: Int)
    
    /// Called when the `AXPhotosViewController` is configuring its `OverlayView` for a new photo. This should be used to update the
    /// the overlay's title or any other overlay-specific properties.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is updating the overlay.
    ///   - overlayView: The `AXOverlayView` that is being updated.
    ///   - photo: The `AXPhoto` the overlay is being configured for.
    ///   - index: The index of the `AXPhoto` that the overlay is being configured for.
    ///   - totalNumberOfPhotos: The total number of photos in the current `dataSource`.
    @objc(photosViewController:willUpdateOverlayView:forPhoto:atIndex:totalNumberOfPhotos:)
    optional func photosViewController(_ photosViewController: AXPhotosViewController,
                                       willUpdate overlayView: AXOverlayView,
                                       for photo: AXPhotoProtocol,
                                       at index: Int,
                                       totalNumberOfPhotos: Int)
    
    //    @objc(photosViewController:willUpdateTopOverlayView:forPhoto:atIndex:totalNumberOfPhotos:)
    //    optional func photosViewController(_ photosViewController: AXPhotosViewController,
    //                                       willUpdateTop overlayTopView: AXOverlayTopView,
    //                                       for photo: AXPhotoProtocol,
    //                                       at index: Int,
    //                                       totalNumberOfPhotos: Int)
    
    /// Called when the `AXPhotoViewController` will show/hide its `OverlayView`. This method will be called inside of an
    /// animation context, so perform any coordinated animations here.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is updating the overlay visibility.
    ///   - overlayView: The `AXOverlayView` whose visibility is changing.
    ///   - visible: A boolean that denotes whether or not the overlay will be visible or invisible.
    @objc
    optional func photosViewController(_ photosViewController: AXPhotosViewController,
                                       overlayView: AXOverlayView,
                                       visibilityWillChange visible: Bool)
    
    //    @objc
    //    optional func photosViewController(_ photosViewController: AXPhotosViewController,
    //                                       overlayView: AXOverlayTopView,
    //                                       visibilityWillChangeTop visible: Bool)
    
    /// If implemented and returns a valid zoom scale for the photo (valid meaning >= the photo's minimum zoom scale), the underlying
    /// zooming image view will adopt the returned `maximumZoomScale` instead of the default calculated by the library. A good implementation
    /// of this method will use a combination of the provided `minimumZoomScale` and `imageSize` to extrapolate a `maximumZoomScale` to return.
    /// If the `minimumZoomScale` is returned (ie. `minimumZoomScale` == `maximumZoomScale`), zooming will be disabled for this image.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is updating the photo's zoom scale.
    ///   - photo: The `AXPhoto` that the zoom scale will affect.
    ///   - minimumZoomScale: The minimum zoom scale that is calculated by the library. This value cannot be changed.
    ///   - imageSize: The size of the image that belongs to the `AXPhoto`.
    /// - Returns: A "maximum" zoom scale that >= `minimumZoomScale`.
    @objc(photosViewController:maximumZoomScaleForPhoto:minimumZoomScale:imageSize:)
    optional func photosViewController(_ photosViewController: AXPhotosViewController,
                                       maximumZoomScaleFor photo: AXPhotoProtocol,
                                       minimumZoomScale: CGFloat,
                                       imageSize: CGSize) -> CGFloat
    
    #if os(iOS)
    /// Called when the action button is tapped for a photo. If no implementation is provided, will fall back to default action.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` handling the action.
    ///   - photo: The related `Photo`.
    @objc(photosViewController:handleActionButtonTappedForPhoto:)
    optional func photosViewController(_ photosViewController: AXPhotosViewController, 
                                       handleActionButtonTappedFor photo: AXPhotoProtocol)
    
    /// Called when an action button action is completed.
    ///
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that handled the action.
    ///   - photo: The related `AXPhoto`.
    /// - Note: This is only called for the default action.
    @objc(photosViewController:actionCompletedWithActivityType:forPhoto:)
    optional func photosViewController(_ photosViewController: AXPhotosViewController, 
                                       actionCompletedWith activityType: UIActivity.ActivityType, 
                                       for photo: AXPhotoProtocol)
    #endif
    
    /// Called just before the `AXPhotosViewController` begins its dismissal
    ///
    /// - Parameter photosViewController: The view controller being dismissed
    @objc(photosViewControllerWillDismiss:)
    optional func photosViewControllerWillDismiss(_ photosViewController: AXPhotosViewController)
    
    /// Called after the `AXPhotosViewController` completes its dismissal
    ///
    /// - Parameter photosViewController: The dismissed view controller
    @objc(photosViewControllerDidDismiss:)
    optional func photosViewControllerDidDismiss(_ photosViewController: AXPhotosViewController)
}

// MARK: - Notification definitions
// Keep Obj-C land happy
@objc open class AXPhotosViewControllerNotification: NSObject {
    @objc static let ProgressUpdate = Notification.Name.photoLoadingProgressUpdate.rawValue
    @objc static let ImageUpdate = Notification.Name.photoImageUpdate.rawValue
    @objc static let ImageKey = "AXPhotosViewControllerImage"
    @objc static let AnimatedImageKey = "AXPhotosViewControllerAnimatedImage"
    @objc static let ReferenceViewKey = "AXPhotosViewControllerReferenceView"
    @objc static let LoadingStateKey = "AXPhotosViewControllerLoadingState"
    @objc static let ProgressKey = "AXPhotosViewControllerProgress"
    @objc static let ErrorKey = "AXPhotosViewControllerError"
}

public extension Notification.Name {
    static let photoLoadingProgressUpdate = Notification.Name("AXPhotoLoadingProgressUpdateNotification")
    static let photoImageUpdate = Notification.Name("AXPhotoImageUpdateNotification")
}


extension AXPhotosViewController: PlayerDelegate {
    
    public func playerReady(_ player: Player) {
        print("\(#function) ready")
    }
    
    public func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
        if player.playbackState == .paused {
            self.currentPhotoViewControllerForPlayer?.playButton.isHidden = false
            self.currentPhotoViewControllerForPlayer?.view.bringSubviewToFront(self.view)
        }
        if player.playbackState == .stopped {
            self.currentPhotoViewControllerForPlayer?.playButton.isHidden = false
        }
    }
    
    public func playerBufferingStateDidChange(_ player: Player) {
    }
    
    public func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    public func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
    
}


extension AXPhotosViewController: PlayerPlaybackDelegate {
    
    public func playerCurrentTimeDidChange(_ player: Player) {
        
        print("player current time: \(player.currentTime)")
        print("player current time: \(player.maximumDuration)")
        if (canUpdateProgressIndicator) {
            videoRangeSlider.updateProgressIndicator(seconds: player.currentTime)
        }
        
    }
    
    public func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    public func playerPlaybackDidEnd(_ player: Player) {
    }
    
    public func playerPlaybackWillLoop(_ player: Player) {
    }
    
}
