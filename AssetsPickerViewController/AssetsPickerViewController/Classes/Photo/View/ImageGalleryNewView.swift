import UIKit
import Photos
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol ImageGalleryNewPanGestureDelegate: class {

  func panGestureDidStart()
  func panGestureDidChange(_ translation: CGPoint)
  func panGestureDidEnd(_ translation: CGPoint, velocity: CGPoint)
}

open class ImageGalleryNewView: UIView, UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
         func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
               var assets = [PHAsset]()
               for indexPath in indexPaths {
                   assets.append(AssetsManager.shared.assetArray[indexPath.row])
               }
               AssetsManager.shared.cache(assets: assets, size: pickerConfig.assetCacheSize)
           }
    }
    
   

    

  let cellReuseIdentifier: String = UUID().uuidString
  let footerReuseIdentifier: String = UUID().uuidString
  var selectedArray = [PHAsset]()
  var selectedMap = [String: PHAsset]()
  var requestIdMap = [IndexPath: PHImageRequestID]()
  var pickerConfig: AssetsPickerConfig!


    
  let emptyView: AssetsEmptyView = {
           return AssetsEmptyView()
       }()
    
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

  struct Dimensions {
    static let galleryHeight: CGFloat = 160
    static let galleryBarHeight: CGFloat = 24
  }

    
  lazy open var collectionView: UICollectionView = { [unowned self] in
    
    let pickerConfig = AssetsPickerConfig()
           pickerConfig.assetCellType = AssetsPhotoCell.classForCoder()
           pickerConfig.albumPortraitForcedCellHeight = 50
           pickerConfig.albumLandscapeForcedCellHeight = 50
           pickerConfig.albumDefaultSpace = 1
           pickerConfig.albumLineSpace = 1
           pickerConfig.albumPortraitColumnCount = 1
           pickerConfig.albumLandscapeColumnCount = 1
    
    
    let collectionView = UICollectionView(frame: CGRect.zero,
      collectionViewLayout: self.collectionViewLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = Configuration.mainColor
    collectionView.showsHorizontalScrollIndicator = false
    
    AssetsManager.shared.pickerConfig = pickerConfig
    AssetsManager.shared.registerObserver()

    
    collectionView.allowsMultipleSelection = true
    collectionView.alwaysBounceVertical = true
    collectionView.register(pickerConfig.assetCellType, forCellWithReuseIdentifier: self.cellReuseIdentifier)
    collectionView.register(AssetsPhotoFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: self.footerReuseIdentifier)
    collectionView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    collectionView.backgroundColor = UIColor.clear
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.remembersLastFocusedIndexPath = true
    if #available(iOS 10.0, *) {
        collectionView.prefetchDataSource = self
    }
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
    let layout = ImageGalleryNewLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = Configuration.cellSpacing
    layout.minimumLineSpacing = 2
    layout.sectionInset = UIEdgeInsets.zero

    return layout
    }()

  public lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addGestureRecognizer(self.panGestureRecognizer)
    //view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    view.backgroundColor = UIColor.clear

    return view
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: #selector(handlePanGestureRecognizer(_:)))
    return gesture
    }()

  open lazy var noImagesLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.font = Configuration.noImagesFont
    label.textColor = Configuration.noImagesColor
    label.text = Configuration.noImagesTitle
    label.alpha = 0
    label.sizeToFit()
    self.addSubview(label)

    return label
    }()

  //open lazy var selectedStack = ImageStack()
  lazy var assets = [PHAsset]()

  weak var delegate: ImageGalleryNewPanGestureDelegate?
  var collectionSize: CGSize?
  var shouldTransform = false
  var imagesBeforeLoading = 0
  //var fetchResult: PHFetchResult<PHAsset>?
    //  var fetchResult: PHFetchResult<AnyObject>?

  var canFetchImages = false
  var imageLimit = 0

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = Configuration.mainColor

    collectionView.register(AssetsPhotoCell.self,
      forCellWithReuseIdentifier: cellReuseIdentifier)

    [collectionView, topSeparator].forEach { addSubview($0) }

    //topSeparator.addSubview(Configuration.indicatorView)

    imagesBeforeLoading = 0
    //fetchPhotos()
    self.collectionView.reloadData()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  open override func layoutSubviews() {
    super.layoutSubviews()
    updateNoImagesLabel()
  }
    
   

  public func updateFrames() {
    let totalWidth = UIScreen.main.bounds.width
    frame.size.width = totalWidth
    let collectionFrame = frame.height == Dimensions.galleryBarHeight ? 100 + Dimensions.galleryBarHeight : frame.height
    topSeparator.frame = CGRect(x: 0, y: 0, width: totalWidth, height: Dimensions.galleryBarHeight)
    topSeparator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
    Configuration.indicatorView.frame = CGRect(x: (totalWidth - Configuration.indicatorWidth) / 2, y: (topSeparator.frame.height - Configuration.indicatorHeight) / 2,
      width: Configuration.indicatorWidth, height: Configuration.indicatorHeight)
    collectionView.frame = CGRect(x: 0, y: topSeparator.frame.height, width: totalWidth, height: collectionFrame - topSeparator.frame.height)
    collectionSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)

    collectionView.reloadData()
    print("collectionview size \(collectionView.numberOfItems(inSection: 0))")

  }
    
    func updateFramesNoReload() {
        let totalWidth = UIScreen.main.bounds.width
        frame.size.width = totalWidth
        let collectionFrame = frame.height == Dimensions.galleryBarHeight ? 100 + Dimensions.galleryBarHeight : frame.height
        topSeparator.frame = CGRect(x: 0, y: 0, width: totalWidth, height: Dimensions.galleryBarHeight)
        topSeparator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        Configuration.indicatorView.frame = CGRect(x: (totalWidth - Configuration.indicatorWidth) / 2, y: (topSeparator.frame.height - Configuration.indicatorHeight) / 2,
                                                   width: Configuration.indicatorWidth, height: Configuration.indicatorHeight)
        collectionView.frame = CGRect(x: 0, y: topSeparator.frame.height, width: totalWidth, height: collectionFrame - topSeparator.frame.height)
        collectionSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        
    }

  func updateNoImagesLabel() {
    let height = bounds.height
    let threshold = Dimensions.galleryBarHeight * 2

    UIView.animate(withDuration: 0.25, animations: {
      if threshold > height || self.collectionView.alpha != 0 {
        self.noImagesLabel.alpha = 0
      } else {
        self.noImagesLabel.center = CGPoint(x: self.bounds.width / 2, y: height / 2)
        self.noImagesLabel.alpha = (height > threshold) ? 1 : (height - Dimensions.galleryBarHeight) / threshold
      }
    })
  }

  // MARK: - Photos handler

//  func fetchPhotos(_ completion: (() -> Void)? = nil) {
//    AssetManager.fetch { assets in
//      self.assets.removeAll()
//      self.assets.append(contentsOf: assets)
//      self.collectionView.reloadData()
//
//      completion?()
//    }
//  }

  // MARK: - Pan gesture recognizer

    @objc func handlePanGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
    guard let superview = superview else { return }

    let translation = gesture.translation(in: superview)
    let velocity = gesture.velocity(in: superview)


    
    switch gesture.state {
    case .began:
      delegate?.panGestureDidStart()
    case .changed:
      delegate?.panGestureDidChange(translation)
    case .ended:
      delegate?.panGestureDidEnd(translation, velocity: velocity)
    default: break
    }
  }

  func displayNoImagesMessage(_ hideCollectionView: Bool) {
    collectionView.alpha = hideCollectionView ? 0 : 1
    updateNoImagesLabel()
  }
}

// MARK: CollectionViewFlowLayout delegate methods

extension ImageGalleryNewView: UICollectionViewDelegateFlowLayout {

  public func collectionView(_ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize {
      guard let collectionSize = collectionSize else { return CGSize.zero }

      return collectionSize
  }
}

// MARK: CollectionView delegate methods

extension ImageGalleryNewView: UICollectionViewDelegate {

//  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    guard let cell = collectionView.cellForItem(at: indexPath)
//      as? ImageGalleryViewCell else { return }
//
//    let asset = assets[(indexPath as NSIndexPath).row]
//
//    AssetManager.resolveAsset(asset, size: CGSize(width: 100, height: 100)) { image in
//      guard let _ = image else { return }
//      if cell.selectedImageView.image != nil {
//         cell.selectedImageView.image = nil
//        self.selectedStack.dropAsset(asset)
//      } else if self.imageLimit == 0 || self.imageLimit > self.selectedStack.assets.count {
//        cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery3")
//        cell.selectedImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
//       // UIView.animate(withDuration: 0.2, animations: { _ in
//          cell.selectedImageView.transform = CGAffineTransform.identity
//       // })
//        self.selectedStack.pushAsset(asset)
//      }
//    }
//  }
//
//  public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
//    forItemAt indexPath: IndexPath) {
//      guard (indexPath as NSIndexPath).row + 10 >= assets.count
//        //&& (indexPath as NSIndexPath).row < fetchResult?.count
//        && canFetchImages else { return }
//
//      fetchPhotos()
//      canFetchImages = false
//  }
}




extension ImageGalleryNewView: UICollectionViewDataSource {

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
         //cellDelegate.delegate = self
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
     
//     public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//         cancelFetching(at: indexPath)
//     }
     
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

