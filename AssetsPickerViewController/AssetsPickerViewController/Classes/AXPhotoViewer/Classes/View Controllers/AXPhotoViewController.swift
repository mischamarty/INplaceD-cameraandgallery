//
//  AXPhotoViewController.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/7/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

#if os(iOS)
import FLAnimatedImage
#elseif os(tvOS)
import FLAnimatedImage_tvOS
#endif
import Photos

@objc open class AXPhotoViewController: UIViewController, AXPageableViewControllerProtocol, AXZoomingImageViewDelegate {
    
    @objc public weak var delegate: AXPhotoViewControllerDelegate?
    @objc public var pageIndex: Int = 0
    
    //linked to player
    
   

    
    let playButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 200, y: 200, width: 65, height: 65)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(UIImage(named: "button_playvideo_4", in: AXBundle.frameworkBundle, compatibleWith: nil), for: .normal)

        
        
       // button.backgroundColor = .green
        button.isHidden = true
        return button
    }()
    
    @objc  public func didPressPlayButton(sender: Any) {
        
        self.delegate?.playButtonPressed(self)
        
        
//         self.addChild(player)
//
//        playButton.isHidden = true
//        self.view.addSubview(player.view)
//
//
//        player.playerDelegate = self
//        player.playbackDelegate = self
//
//        player.didMove(toParent: self)
//        createImageFrames(url : self.player.url!)
//        self.player.view.addSubview(self.imageFrameView)
//        player.playFromBeginning()
        
    
        
    }
    
    
//    var frameContainerView: UIView = {
//        let view =  UIView(frame: CGRect(x: 10, y: 60, width: 300, height: 50))
//        return view
//    }()
    
    
   
    
    
    
    ///////
    


    
    @objc fileprivate(set) var loadingView: AXLoadingViewProtocol?

    var zoomingImageView: AXZoomingImageView {
        get {
            return self.view as! AXZoomingImageView
        }
    }
    
    fileprivate var photo: AXPhotoProtocol?
    fileprivate weak var notificationCenter: NotificationCenter?
    
    @objc public init(loadingView: AXLoadingViewProtocol, notificationCenter: NotificationCenter) {
        self.loadingView = loadingView
        self.notificationCenter = notificationCenter
        
        super.init(nibName: nil, bundle: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(photoLoadingProgressDidUpdate(_:)),
                                       name: .photoLoadingProgressUpdate,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(photoImageDidUpdate(_:)),
                                       name: .photoImageUpdate,
                                       object: nil)
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.notificationCenter?.removeObserver(self)
    }
    
    open override func loadView() {
        self.view = AXZoomingImageView()
    }
    
   
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.zoomingImageView.zoomScaleDelegate = self
        
       
        //player.view.frame = self.zoomingImageView.frame
      //  self.zoomingImageView.addSubview(player.view)
      
        
       
        
    
        
        

        
        
        if let loadingView = self.loadingView as? UIView {
            self.view.addSubview(loadingView)
        }
        
        self.view.addSubview(playButton)


        

        playButton.addTarget(self, action: #selector(didPressPlayButton), for: .touchUpInside)
        
    }
    
//    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        self.player.view.frame = CGRect(x:0, y:0, width: size.width, height: size.height)
//        imageFrameView.frame = CGRect(x: 10, y : 100, width: size.width - 20, height: 50)
//
//    }
    
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var adjustedSize = self.view.bounds.size
        if #available(iOS 11.0, tvOS 11.0, *) {
            adjustedSize.width -= (self.view.safeAreaInsets.left + self.view.safeAreaInsets.right)
            adjustedSize.height -= (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)
        }
        
        let loadingViewSize = self.loadingView?.sizeThatFits(adjustedSize) ?? .zero
        (self.loadingView as? UIView)?.frame = CGRect(origin: CGPoint(x: floor((self.view.bounds.size.width - loadingViewSize.width) / 2),
                                                                      y: floor((self.view.bounds.size.height - loadingViewSize.height) / 2)),
                                                      size: loadingViewSize)
        
        self.playButton.center = self.view.center
        //imageFrameView.frame = CGRect(x: 10, y : 100, width: self.view.frame.width - 20, height: 50)
        
    }
    
    
//   @objc public func didMoveToAnotherAsset() {
//
//    //print("didMoveToAnotherAsset")
//    //weak var weakSelf = self
//
//    self.player.url = nil
//
////    if (self.photo?.imageAsset?.mediaType == .video) {
////        playButton.isHidden = false
////    } else {
////        playButton.center = self.view.center
////        playButton.isHidden = true
////
////    }
////
//    //weakSelf?.player.view.removeFromSuperview()
//
//    self.player.willMove(toParent: nil)
//    self.player.view.removeFromSuperview()
//    self.player.removeFromParent()
//
//
//    }
    
    @objc public func applyPhoto(_ photo: AXPhotoProtocol) {
        self.photo = photo
        
        playButton.center = self.zoomingImageView.center

        
        if (photo.imageAsset?.mediaType == .video) {
            playButton.isHidden = false
        } else {

            playButton.isHidden = true

        }
        
        weak var weakSelf = self
        
        func resetImageView() {
            weakSelf?.zoomingImageView.image = nil
            weakSelf?.zoomingImageView.animatedImage = nil
        }
        
        self.loadingView?.removeError()
        
        switch photo.ax_loadingState {
        case .loading, .notLoaded, .loadingCancelled:
            resetImageView()
            self.loadingView?.startLoading(initialProgress: photo.ax_progress)
        case .loadingFailed:
            resetImageView()
            let error = photo.ax_error ?? NSError()
            self.loadingView?.showError(error, retryHandler: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.photoViewController(self, retryDownloadFor: photo)
                self.loadingView?.removeError()
                self.loadingView?.startLoading(initialProgress: photo.ax_progress)
            })
        case .loaded:
            guard photo.imageAsset != nil || photo.image != nil || photo.ax_animatedImage != nil else {
                assertionFailure("Must provide valid `UIImage` in \(#function)")
                return
            }
             self.loadingView?.stopLoading()
           
            if let imageAsset = photo.imageAsset {
                
                self.image(forAsset: imageAsset, completion: { (image) in
                    self.zoomingImageView.image = image
                })
                
//                if imageAsset.mediaType == .video {
//
//                    self.video3(forAsset: imageAsset, completion: { (assetURL) in
//
//
//                        self.player.url = assetURL
//                        print("player.url  \(self.player.url )")
//
////                       // self.player.playFromBeginning()
////                          print("finished hehehe1");
////                        DispatchQueue.background(background: {
////                            self.createImageFrames(asset: avAsset)
////                        }, completion:{
////                            print("finished hehehe2");
////                        })
//
//
//                    })
//
//                }
                
            } else if let animatedImage = photo.ax_animatedImage {
                self.zoomingImageView.animatedImage = animatedImage
            } else if let image = photo.image {
                self.zoomingImageView.image = image
            }
        }
        
        self.view.setNeedsLayout()
    }
    
   
    
    
//    func createImageFrames(url: URL)
//    {
//        print("02")
//
//        let asset = AVAsset(url: url)
//
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
//        print("01")
//
//        //loop for 6 number of frames
//        for _ in 0...5
//        {
//            print("1")
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
    
//    open func video(forAsset asset: PHAsset, isNeedDegraded: Bool = true, completion: @escaping ((AVPlayerItem?) -> Void)) {
//        let options = PHVideoRequestOptions()
//        options.isNetworkAccessAllowed = true
//        options.deliveryMode = .highQualityFormat
//        PHCachingImageManager.default().requestPlayerItem(
//            forVideo: asset,
//            options: options,
//            resultHandler: { (playeritem, info) in
//                if !isNeedDegraded {
//                    if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
//                        print("isDegraded")
//                        return
//                    }
//                }
//                completion(playeritem)
//        })
//    }
    
    open func video3(forAsset asset: PHAsset, isNeedDegraded: Bool = true, completion: @escaping ((URL?) -> Void)) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .mediumQualityFormat
        //PHCachingImageManager.default().requestAVAsset(
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
    
    open func video2(forAsset asset: PHAsset, isNeedDegraded: Bool = true, completion: @escaping ((URL?, AVAsset) -> Void)) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .mediumQualityFormat
        //PHCachingImageManager.default().requestAVAsset(
        PHCachingImageManager.default().requestAVAsset(
            forVideo: asset,
            options: options,
            resultHandler: { (asset, audioMix, info) -> Void in
                if asset != nil {
                    let avasset = asset as! AVURLAsset
                    let urlVideo = avasset.url
                     completion(urlVideo, avasset)
                }
               
        })
    }
    
   
    
    // MARK: - AXPageableViewControllerProtocol
    func prepareForReuse() {
        self.zoomingImageView.image = nil
        self.zoomingImageView.animatedImage = nil
        //self.player.url = nil
    }
    
    // MARK: - AXZoomingImageViewDelegate
    func zoomingImageView(_ zoomingImageView: AXZoomingImageView, maximumZoomScaleFor imageSize: CGSize) -> CGFloat {
        return self.delegate?.photoViewController(self,
                                                  maximumZoomScaleForPhotoAt: self.pageIndex,
                                                  minimumZoomScale: zoomingImageView.minimumZoomScale,
                                                  imageSize: imageSize) ?? .leastNormalMagnitude
    }
    
    // MARK: - Notifications
    @objc fileprivate func photoLoadingProgressDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? AXPhotoProtocol else {
            assertionFailure("Photos must conform to the AXPhoto protocol.")
            return
        }
        
        guard photo === self.photo, let progress = notification.userInfo?[AXPhotosViewControllerNotification.ProgressKey] as? CGFloat else {
            return
        }
        
        self.loadingView?.updateProgress?(progress)
    }
    
    @objc fileprivate func photoImageDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? AXPhotoProtocol else {
            assertionFailure("Photos must conform to the AXPhoto protocol.")
            return
        }
        
        guard photo === self.photo, let userInfo = notification.userInfo else {
            return
        }
        
        if userInfo[AXPhotosViewControllerNotification.AnimatedImageKey] != nil || userInfo[AXPhotosViewControllerNotification.ImageKey] != nil {
            self.applyPhoto(photo)
        } else if let referenceView = userInfo[AXPhotosViewControllerNotification.ReferenceViewKey] as? FLAnimatedImageView {
            self.zoomingImageView.imageView.ax_syncFrames(with: referenceView)
        } else if let error = userInfo[AXPhotosViewControllerNotification.ErrorKey] as? Error {
            self.loadingView?.showError(error, retryHandler: { [weak self] in
                guard let `self` = self, let photo = self.photo else { return }
                self.delegate?.photoViewController(self, retryDownloadFor: photo)
                self.loadingView?.removeError()
                self.loadingView?.startLoading(initialProgress: photo.ax_progress)
                self.view.setNeedsLayout()
            })
            
            self.view.setNeedsLayout()
        }
    }

}

@objc public protocol AXPhotoViewControllerDelegate: AnyObject, NSObjectProtocol {
    
    @objc(photoViewController:retryDownloadForPhoto:)
    func photoViewController(_ photoViewController: AXPhotoViewController, retryDownloadFor photo: AXPhotoProtocol)
    
    func playButtonPressed(_ photoViewController: AXPhotoViewController)

    
    @objc(photoViewController:maximumZoomScaleForPhotoAtIndex:minimumZoomScale:imageSize:)
    func photoViewController(_ photoViewController: AXPhotoViewController,
                             maximumZoomScaleForPhotoAt index: Int,
                             minimumZoomScale: CGFloat,
                             imageSize: CGSize) -> CGFloat
    
}



