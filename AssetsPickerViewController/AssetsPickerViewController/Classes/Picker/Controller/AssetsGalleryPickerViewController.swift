import UIKit
import Photos

// MARK: - AssetsPickerViewControllerDelegate
@objc public protocol AssetsGalleryPickerViewControllerDelegate: class {
    @objc optional func assetsPickerDidCancel(controller: AssetsGalleryPickerViewController)
    @objc optional func assetsPickerCannotAccessPhotoLibrary(controller: AssetsGalleryPickerViewController)
    func assetsPicker(controller: AssetsGalleryPickerViewController, selected assets: [PHAsset])
    @objc optional func assetsPicker(controller: AssetsGalleryPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool
    @objc optional func assetsPicker(controller: AssetsGalleryPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath)
    @objc optional func assetsPicker(controller: AssetsGalleryPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool
    @objc optional func assetsPicker(controller: AssetsGalleryPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath)
    @objc optional func assetsPicker(controller: AssetsGalleryPickerViewController, didDismissByCancelling byCancel: Bool)
    @objc optional func assetsPicker(controller: AssetsGalleryPickerViewController, didOpenInGallery asset: PHAsset, at indexPath: IndexPath)
}


// MARK: - AssetsPickerViewController
open class AssetsGalleryPickerViewController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    @objc open weak var pickerDelegate: AssetsGalleryPickerViewControllerDelegate?
    open var selectedAssets: [PHAsset] {
        return photoViewController.selectedAssets
    }
    
//    //--toolbar
//    fileprivate lazy var toolbarCustomized: UIToolbar = {
//        let toolbar = UIToolbar()
//        var items = [UIBarButtonItem]()
//        items.append( UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressedCancel(button:))))
//        items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
//        toolbar.items = items
//        return toolbar
//    }()
    
    @objc func pressedCancel(button: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            //self.delegate?.assetsPicker?(controller: self.picker, didDismissByCancelling: true)
        })
        //delegate?.assetsPickerDidCancel?(controller: picker)
    }
    
    //--
    
    open var isShowLog: Bool = false
    public var pickerConfig: AssetsPickerConfig! {
        didSet {
            if let config = self.pickerConfig?.prepare() {
                AssetsManager.shared.pickerConfig = config
                photoViewController?.pickerConfig = config
            }
        }
    }
    
    public private(set) var photoViewController: AssetsGalleryPhotoViewController!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    func commonInit() {
        
        
        
        let config = AssetsPickerConfig().prepare()
        self.pickerConfig = config
        AssetsManager.shared.pickerConfig = config
        let controller = AssetsGalleryPhotoViewController()
        
        controller.pickerConfig = config
        self.photoViewController = controller
        
        TinyLog.isShowInfoLog = isShowLog
        TinyLog.isShowErrorLog = isShowLog
        AssetsManager.shared.registerObserver()
        
    
        
        viewControllers = [photoViewController]
        
        self.transitioningDelegate = self
        
        
        
        
        //self.setToolbarItems(itemsT, animated: false)
        //self.navigationController?.setToolbarItems(itemsT, animated: false)
        //self.toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        
//
//        let constraints = [
//            toolbarCustomized.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            toolbarCustomized.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            toolbarCustomized.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//        ]
//        NSLayoutConstraint.activate(constraints)
        
    }
    
    open override func viewDidLoad() {
       
        
        self.setToolbarHidden(false, animated: false)
        
    
        let greyLightTransparent =  UIColor(red: 232/255, green: 233/255, blue: 236/255, alpha: 0.75)
        self.toolbar.backgroundColor = greyLightTransparent
        //self.toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.toolbar.isTranslucent = false
        self.toolbar.isOpaque = true
        
        

    }
    
    open override func viewWillAppear(_ animated: Bool) {
        var itemsT = [UIBarButtonItem]()
//        itemsT.append( UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressedCancel(button:))))
//        itemsT.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
//        itemsT.append( UIBarButtonItem(title: "Hey", style: .plain, target: self, action: nil))

        let button1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressedCancel(button:)))
              // button1.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)!], for: .normal)
               button1.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
        itemsT.append( button1)

        itemsT.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
               
               
               let button2 = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(pressedCancel(button:)))
               button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .normal)
        button2.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16.0)!, NSAttributedString.Key.foregroundColor : UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)], for: .disabled)
               
               itemsT.append(button2)

     //   self.setToolbarItems(itemsT, animated: false)
        //self.toolbar.items  = itemsT
    }
    
    deinit {
        AssetsManager.shared.clear()
        logd("Released \(type(of: self))")
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationController_forPresented");


        return nil;
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationController_forDismissed");

        return nil;
    }
}
