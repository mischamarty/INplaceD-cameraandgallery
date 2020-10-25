//
//  AssetsPhotoViewController.swift
//  Pods
//
//  Created by DragonCherry on 5/17/17.
//
//

import UIKit
import Photos
import PhotosUI
import Device
import SnapKit

// MARK: - AssetsPhotoViewController
open class AssetsPhotoViewController: UIViewController, AXPhotosViewControllerDelegate, AssetsPhotoCellDelegate {
    
    public func didPressSelectButton(sender: Any) {
        print("AssetsPhotoViewController didPressSelectButton 1")
        guard let cell = sender as? UICollectionViewCell else { print ("ex1"); return }
        guard let indexPath = self.collectionView.indexPath(for: cell) else {print ("ex2"); return}
        let asset = AssetsManager.shared.assetArray[indexPath.row]
        print("select or deselet asset ",asset)
        if selectedArray.contains(asset) {
            print("did deselect")
           // cell.isSelected = false
            deselect(asset: asset, at: indexPath)
            //cell.isHighlighted = false
            //updateNavigationStatus()
            //delegate?.assetsPicker?(controller: picker, didDeselect: asset, at: indexPath)
        }
        else {
            print("did select")
            //cell.isSelected = true
            select(asset: asset, at: indexPath)
            //cell.isHighlighted = true

            //updateNavigationStatus()
            //delegate?.assetsPicker?(controller: picker, didSelect: asset, at: indexPath)
        }
        
        
        
    }
    
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return AssetsPickerConfig.statusBarStyle
    }
    
    // MARK: Properties
    var pickerConfig: AssetsPickerConfig!
    
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
        
        let layout = AssetsPhotoLayout(pickerConfig: self.pickerConfig)
        self.updateLayout(layout: layout, isPortrait: UIApplication.shared.statusBarOrientation.isPortrait)
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.allowsMultipleSelection = true
        view.alwaysBounceVertical = true
        view.register(self.pickerConfig.assetCellType, forCellWithReuseIdentifier: self.cellReuseIdentifier)
        view.register(AssetsPhotoFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: self.footerReuseIdentifier)
        view.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        view.backgroundColor = UIColor.clear
        view.dataSource = self
        view.delegate = self
        view.remembersLastFocusedIndexPath = true
        if #available(iOS 10.0, *) {
            view.prefetchDataSource = self
        }
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        
        return view
    }()
    
    var selectedAssets: [PHAsset] {
        return selectedArray
    }
    
    // MARK: Lifecycle Methods
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(emptyView)
        view.addSubview(noPermissionView)
        //view.addSubview(toolbar)
       
       
        
        view.setNeedsUpdateConstraints()
    }
    
     let button2 = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(pressedCancel(button:)))
    var itemsT = [UIBarButtonItem]()
    func initTabItems() {
           // var itemsT = [UIBarButtonItem]()
        itemsT = [UIBarButtonItem]()
//        if(itemsT.count > 0) {
//            return
//        }
                        
                        let button1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressedCancel(button:)))
                       // button1.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
                        button1.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
                    
                        //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)

                        
                        itemsT.append( button1)
                        itemsT.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        statusView = ButtonStatusView(frame: CGRect(x: 0, y: 0, width: 35, height: 35),count: selectedArray.count)
        //updateStatusButton()
                        let barSelectionStatusButton = UIBarButtonItem(customView: statusView)
                
             
        //        let attributes = [NSAttributedString.Key.baselineOffset: NSNumber(value: -5)]
        //        barSelectionStatusButton.setTitleTextAttributes(attributes, for: .normal)
                

                
        //                barSelectionStatusButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 15), for: UIBarMetrics.compact)
                       
                itemsT.append(barSelectionStatusButton)
                        
                       
                        button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
        
        if (selectedArray.count > 0) {
                  // self.statusView.button.isHidden = false
                   button2.isEnabled = true
                   button2.tintColor = UIColor.clear
               }
               else {
                   //self.statusView.button.isHidden = true
                   button2.isEnabled = false
                   button2.tintColor = UIColor.blue

               }
                
                button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:0.5)], for: .disabled)
                              
                        
                        itemsT.append(button2)
                        
                     
                //                let buttonIcon = UIImage(named: "button_send_grey")
                //                let buttonView = UIImageView(image: buttonIcon)
                //                let barButtonItem = UIBarButtonItem(customView: buttonView)
                //
                //                barButtonItem.image = buttonIcon
                //
                //        itemsT.append(barButtonItem)

                        let greyLightTransparent =  UIColor(red: 238/255, green: 240/255, blue: 244/255, alpha: 0.75)

                self.navigationController?.toolbar.barTintColor = greyLightTransparent

                // Without this, color will be faded slightly and not exactly what's specified above
                self.navigationController?.toolbar.isTranslucent = false;
                
                self.setToolbarItems(itemsT, animated: false)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.delegate = self
        self.transitioningDelegate = self

        setupCommon()
        setupCollectionView()
        
        updateEmptyView(count: 0)
        updateNoPermissionView()
        
        
        if let selectedAssets = self.pickerConfig?.selectedAssets {
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
        
        initTabItems()
        setupBarButtonItems()

        
//          var itemsT = [UIBarButtonItem]()
//
//                let button1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressedCancel(button:)))
//               // button1.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
//                button1.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
//
//                //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
//
//
//                itemsT.append( button1)
//                itemsT.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
//                barSelectionStatusButton = UIBarButtonItem(customView: statusView)
//
//
////        let attributes = [NSAttributedString.Key.baselineOffset: NSNumber(value: -5)]
////        barSelectionStatusButton.setTitleTextAttributes(attributes, for: .normal)
//
//
//
////                barSelectionStatusButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 15), for: UIBarMetrics.compact)
//
//        itemsT.append(barSelectionStatusButton!)
//
//
//                button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
//        button2.isEnabled = false
//
//        button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:0.5)], for: .disabled)
//
//
//                itemsT.append(button2)
//
//
//        //                let buttonIcon = UIImage(named: "button_send_grey")
//        //                let buttonView = UIImageView(image: buttonIcon)
//        //                let barButtonItem = UIBarButtonItem(customView: buttonView)
//        //
//        //                barButtonItem.image = buttonIcon
//        //
//        //        itemsT.append(barButtonItem)
//
//                let greyLightTransparent =  UIColor(red: 238/255, green: 240/255, blue: 244/255, alpha: 0.75)
//
//        self.navigationController?.toolbar.barTintColor = greyLightTransparent
//
//        // Without this, color will be faded slightly and not exactly what's specified above
//        self.navigationController?.toolbar.isTranslucent = false;
//
//        self.setToolbarItems(itemsT, animated: false)
        
    }
    
//    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if let previewing = self.previewing {
//            if traitCollection.forceTouchCapability != .available {
//                unregisterForPreviewing(withContext: previewing)
//                self.previewing = nil
//            }
//        } else {
//            if traitCollection.forceTouchCapability == .available {
//                self.previewing = registerForPreviewing(with: self, sourceView: collectionView)
//            }
//        }
//    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("<><><><>viewDidLayoutSubviews")

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
        
        initTabItems()
        setStatusViewPosition(isPortrait)
        
       
        
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
//                { (_) in
//
//                photoLayout.translatedOffset = nil
//
////                let endingIndexPath = IndexPath(item: 10, section: 0)
////                                self.collectionView.scrollToItem(at: endingIndexPath, at: [.centeredVertically], animated: false)
//
////                if (self.viewerPresented) {
////                     print("view will transition2");
////                    self.collectionView.scrollToItem(at: self.globalIndexPath, at: [.centeredVertically], animated: false)
////                }
//            }
            
        }
        
       
       // print("<><>self.collectionView.collectionViewLayout1 \(self.collectionView.collectionViewLayout.collectionViewContentSize)")
        self.updateLayout(layout: self.collectionView.collectionViewLayout, isPortrait: isPortrait)
      
       
    }
    
    private var statusView = ButtonStatusView(frame: CGRect(x: 0, y: 0, width: 35, height: 35),count: 0)
    //var barSelectionStatusButton: UIBarButtonItem?


    
    override open func viewWillAppear(_ animated: Bool) {
        print("<><><><>viewWillAppear")
        super.viewWillAppear(animated)
        updateNavigationStatus()
        
       
        initTabItems()
        let isPortrait = view.frame.size.height > view.frame.size.width
        setStatusViewPosition(isPortrait)

//         var itemsT = [UIBarButtonItem]()
//
//                        let button1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressedCancel(button:)))
//                       // button1.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
//                        button1.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
//
//                        //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
//
//
//                        itemsT.append( button1)
//                        itemsT.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
//                        barSelectionStatusButton = UIBarButtonItem(customView: statusView)
//
//
//        //        let attributes = [NSAttributedString.Key.baselineOffset: NSNumber(value: -5)]
//        //        barSelectionStatusButton.setTitleTextAttributes(attributes, for: .normal)
//
//
//
//        //                barSelectionStatusButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 15), for: UIBarMetrics.compact)
//
//        itemsT.append(barSelectionStatusButton!)
//
//
//                        button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
//
//                button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:0.5)], for: .disabled)
//
//
//                        itemsT.append(button2)
//
//
//                //                let buttonIcon = UIImage(named: "button_send_grey")
//                //                let buttonView = UIImageView(image: buttonIcon)
//                //                let barButtonItem = UIBarButtonItem(customView: buttonView)
//                //
//                //                barButtonItem.image = buttonIcon
//                //
//                //        itemsT.append(barButtonItem)
//
//                        let greyLightTransparent =  UIColor(red: 238/255, green: 240/255, blue: 244/255, alpha: 0.75)
//
//                self.navigationController?.toolbar.barTintColor = greyLightTransparent
//
//                // Without this, color will be faded slightly and not exactly what's specified above
//                self.navigationController?.toolbar.isTranslucent = false;
//
//                self.setToolbarItems(itemsT, animated: false)
    
    }
    
    func setStatusViewPosition(_ isPortrait: Bool) {
                            if (!isPortrait) {
                                print("NOT PORTRAIT")
                                             self.statusView.button.frame =  CGRect(x: 0, y: 3, width: 35, height: 35)
                                       self.statusView.frame =  CGRect(x: 0, y: 3, width: 35, height: 35)

                                      
                                         } else {
                                      print("PORTRAIT")

                                             self.statusView.button.frame =  CGRect(x: 0, y: 0, width: 35, height: 35)
                                           self.statusView.frame =  CGRect(x: 0, y: 0, width: 35, height: 35)

                                         }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGestureRecognizer()
       // initTabItems()
        let isPortrait = view.frame.size.height > view.frame.size.width
        setStatusViewPosition(isPortrait)
       
        
//        if traitCollection.forceTouchCapability == .available {
//            previewing = registerForPreviewing(with: self, sourceView: collectionView)
//        }
        
//        var itemsT = [UIBarButtonItem]()
//
//        let button1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressedCancel(button:)))
//       // button1.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
//        button1.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
//
//        //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
//
//
//        itemsT.append( button1)
//        itemsT.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
//
//        let barSelectionStatusButton = UIBarButtonItem(customView: statusView)
//
//        itemsT.append(barSelectionStatusButton)
//
//        let button2 = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(pressedCancel(button:)))
//        button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
//
//        itemsT.append(button2)
//
//
////                let buttonIcon = UIImage(named: "button_send_grey")
////                let buttonView = UIImageView(image: buttonIcon)
////                let barButtonItem = UIBarButtonItem(customView: buttonView)
////
////                barButtonItem.image = buttonIcon
////
////        itemsT.append(barButtonItem)
//
//
//
//        self.setToolbarItems(itemsT, animated: false)
  //      self.navigationController?.toolbar.items  = itemsT
    
        
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeGestureRecognizer()
//        if let previewing = self.previewing {
//            self.previewing = nil
//            unregisterForPreviewing(withContext: previewing)
//        }
        
        
    }
    
    deinit {
        logd("Released \(type(of: self))")
    }
    
   
}

extension AssetsPhotoViewController: UIViewControllerTransitioningDelegate {
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

// MARK: - Initial Setups
extension AssetsPhotoViewController {
    
    func setupCommon() {
        view.backgroundColor = .white
       
        
    }
    
    func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = cancelButtonItem
        //navigationItem.rightBarButtonItem = doneButtonItem
        //doneButtonItem.isEnabled = false
    }
    
    func setupCollectionView() {
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            
            if #available(iOS 11.0, *) {
                leadingConstraint = make.leading.equalToSuperview().inset(view.safeAreaInsets.left).constraint.layoutConstraints.first
                trailingConstraint = make.trailing.equalToSuperview().inset(view.safeAreaInsets.right).constraint.layoutConstraints.first
            } else {
                leadingConstraint = make.leading.equalToSuperview().constraint.layoutConstraints.first
                trailingConstraint = make.trailing.equalToSuperview().constraint.layoutConstraints.first
            }
            make.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        noPermissionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
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
        print("hey1")
        if selectedArray.contains(asset) {
            //cell!.isSelected = false
            print("hey2")

            deselect(asset: asset, at: indexPath)
            updateNavigationStatus()
            //delegate?.assetsPicker?(controller: picker, didDeselect: asset, at: indexPath)
        }
        else {
            print("hey3")

            //cell?.isSelected = true
            select(asset: asset, at: indexPath)
            updateNavigationStatus()
            //delegate?.assetsPicker?(controller: picker, didSelect: asset, at: indexPath)
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
extension AssetsPhotoViewController {
    
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
        if let isPortrait = isPortrait {
            self.isPortrait = isPortrait
        }
        flowLayout.itemSize = self.isPortrait ? pickerConfig.assetPortraitCellSize(forViewSize: UIScreen.main.portraitContentSize) : pickerConfig.assetLandscapeCellSize(forViewSize: UIScreen.main.landscapeContentSize)
        flowLayout.minimumLineSpacing = self.isPortrait ? pickerConfig.assetPortraitLineSpace : pickerConfig.assetLandscapeLineSpace
        flowLayout.minimumInteritemSpacing = self.isPortrait ? pickerConfig.assetPortraitInteritemSpace : pickerConfig.assetLandscapeInteritemSpace
        
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
        
        self.statusView.updateStatusView(count: selectedArray.count, animated: true)
    
        if (selectedArray.count > 0) {
           // self.statusView.button.isHidden = false
            button2.isEnabled = true
           // button2.tintColor = UIColor.clear
        }
        else {
            //self.statusView.button.isHidden = true
            button2.isEnabled = false
            //button2.tintColor = UIColor.clear

        }
//        self.statusView.button.setTitle("\(selectedArray.count)", for: .normal)

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
        let contr = self.navigationController?.viewControllers[0] as! AssetsAlbumViewController
        contr.countOfPhotos = selectedArray.count
         self.navigationController?.popToViewController(contr, animated: true)
       
//        let albumController = AssetsAlbumViewController(pickerConfig: self.pickerConfig)
//               albumController.assetsPhotoViewViewController = self
//               albumController.delegate = self
//
//        self.navigationController?.pushViewController(albumController, animated: true)

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
extension AssetsPhotoViewController {
    
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
extension AssetsPhotoViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let navigationBar = navigationController?.navigationBar else { return false }
        let point = touch.location(in: navigationBar)
        // Ignore touches on navigation buttons on both sides.
        return point.x > navigationBar.bounds.width / 4 && point.x < navigationBar.bounds.width * 3 / 4
    }
}

// MARK: - UIScrollViewDelegate
extension AssetsPhotoViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        logi("contentOffset: \(scrollView.contentOffset)")
    }
}

// MARK: - UICollectionViewDelegate
extension AssetsPhotoViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let delegate = self.delegate {
            return delegate.assetsPicker?(controller: picker, shouldSelect: AssetsManager.shared.assetArray[indexPath.row], at: indexPath) ?? true
        } else {
            return true
        }
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
extension AssetsPhotoViewController: UICollectionViewDataSource {
    
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
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as? AssetsPhotoFooterView else {
            logw("Failed to cast AssetsPhotoFooterView.")
            return AssetsPhotoFooterView()
        }
        footerView.setNeedsUpdateConstraints()
        footerView.updateConstraintsIfNeeded()
        footerView.set(imageCount: AssetsManager.shared.count(ofType: .image), videoCount: AssetsManager.shared.count(ofType: .video))
        return footerView
    }
}

// MARK: - Image Fetch Utility
extension AssetsPhotoViewController {
    
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
extension AssetsPhotoViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if collectionView.numberOfSections - 1 == section {
            if collectionView.bounds.width > collectionView.bounds.height {
                return CGSize(width: collectionView.bounds.width, height: pickerConfig.assetLandscapeCellSize(forViewSize: collectionView.bounds.size).width * 2/3)
            } else {
                return CGSize(width: collectionView.bounds.width, height: pickerConfig.assetPortraitCellSize(forViewSize: collectionView.bounds.size).width * 2/3)
            }
        } else {
            return .zero
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension AssetsPhotoViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var assets = [PHAsset]()
        for indexPath in indexPaths {
            assets.append(AssetsManager.shared.assetArray[indexPath.row])
        }
        AssetsManager.shared.cache(assets: assets, size: pickerConfig.assetCacheSize)
    }
}

// MARK: - AssetsAlbumViewControllerDelegate
extension AssetsPhotoViewController: AssetsAlbumViewControllerDelegate {
    
    public func assetsAlbumViewControllerCancelled(controller: AssetsAlbumViewController) {
        logi("Cancelled.")
    }
    
    public func assetsAlbumViewController(controller: AssetsAlbumViewController, selected album: PHAssetCollection) {
        select(album: album)
    }
}

// MARK: - AssetsManagerDelegate
extension AssetsPhotoViewController: AssetsManagerDelegate {
    
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

// MARK - UIViewControllerPreviewingDelegate
//@available(iOS 9.0, *)
//extension AssetsPhotoViewController: UIViewControllerPreviewingDelegate {
//    @available(iOS 9.0, *)
//    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        logi("\(location)")
//        guard let pressingIndexPath = collectionView.indexPathForItem(at: location) else { return nil }
//        guard let pressingCell = collectionView.cellForItem(at: pressingIndexPath) else { return nil }
//        previewingContext.sourceRect = pressingCell.frame
//
////        let previewController = AssetsPreviewController()
////        previewController.asset = AssetsManager.shared.assetArray[pressingIndexPath.row]
////        return previewController
//
//        var picture:UIImage?
//        self.image(forAsset: AssetsManager.shared.assetArray[pressingIndexPath.row], completion: { (image) in
//            picture = image
//        })
//
//
//
//
//        let photo1:AXPhotoProtocol = AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageData: nil, image: picture, url: nil)
//        let photo2:AXPhotoProtocol = AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageData: nil, image: picture, url: nil)
//        let photos = [photo1, photo2]
//
//        let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: 0, prefetchBehavior: .aggressive)
//
//        let photosViewController = AXPhotosViewController(dataSource: dataSource)
//
//        return photosViewController
//
//    }
//
//    @available(iOS 9.0, *)
//    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//        logi("viewControllerToCommit: \(type(of: viewControllerToCommit))")
//    }
//}

//extension AssetsPhotoViewController: UIViewControllerTransitioningDelegate {
//
//    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        print("animationController_forPresented");
//
//        let cell = self.collectionView.cellForItem(at: globalIndexPath!) as! AssetsPhotoCellProtocol
//
//
//                    let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: false, startingView: cell.imageView) { [weak self] (photo, index) -> UIImageView? in
//                        // this closure can be used to adjust your UI before returning an `endingImageView`.
//                        return cell.imageView
//                    }
//        let animator =  AXPhotosPresentationAnimator(transitionInfo: transitionInfo)
//        return animator;
//    }
//
//    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        print("animationController_forDismissed");
//        let cell = self.collectionView.cellForItem(at: globalIndexPath!) as! AssetsPhotoCellProtocol
//
//
//        let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: false, startingView: cell.imageView) { [weak self] (photo, index) -> UIImageView? in
//            // this closure can be used to adjust your UI before returning an `endingImageView`.
//            return cell.imageView
//        }
//        let animator =  AXPhotosPresentationAnimator(transitionInfo: transitionInfo)
//        return animator;
//    }
//}
//
