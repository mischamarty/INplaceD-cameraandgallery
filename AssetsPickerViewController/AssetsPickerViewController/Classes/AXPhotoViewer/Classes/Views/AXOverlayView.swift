//
//  AXOverlayView.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/28/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

@objc open class AXOverlayView: UIView, AXStackableViewContainerDelegate, UITextViewDelegate {
    
    #if os(iOS)
    /// The toolbar used to set the `titleView`, `leftBarButtonItems`, `rightBarButtonItems`
    @objc public let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
    
    /// The title view displayed in the toolbar. This view is sized and centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    /// This is prioritized over `title`.
    @objc public var titleView: AXOverlayTitleViewProtocol? {
        didSet {
            assert(self.titleView == nil ? true : self.titleView is UIView, "`titleView` must be a UIView.")
            
            if self.window == nil {
                return
            }
            
            self.updateToolbarBarButtonItems()
        }
    }
    
    /// The bar button item used internally to display the `titleView` attribute in the toolbar.
    var titleViewBarButtonItem: UIBarButtonItem?
    
   // let descriptionTextField: UITextField = UITextField()//frame: CGRect(x:0,y:0,width: 100, height: 100)

    //let textView: ExpandableTextView = ExpandableTextView(frame: CGRect(x: 30, y: 50, width: 100, height: 50))
    let textView: ExpandableTextView = ExpandableTextView()
    
    let buttonSend  = UIButton(type: .custom)
    
    let buttonCancel  = UIButton(type: .custom)
    
   // let buttonOk: UIButton = UIButton(frame: CGRect(x: 50, y: 120, width: 30, height: 30))
    
    /// The title displayed in the toolbar. This string is centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    /// Overwrites `internalTitle`.
    @objc public var title: String? {
        didSet {
            self.updateTitleBarButtonItem()
        }
    }
    
    /// The title displayed in the toolbar. This string is centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    /// This is used internally by the library to set a default title. Overwritten by `title`.
    var internalTitle: String? {
        didSet {
            self.updateTitleBarButtonItem()
        }
    }
    
    /// The title text attributes inherited by the `title`.
    @objc public var titleTextAttributes: [NSAttributedString.Key: Any]? {
        didSet {
            self.updateTitleBarButtonItem()
        }
    }
    
//    @objc public var frameContainerView: UIView = {
//        let view =  UIView(frame: CGRect(x:10,y:44,width: 320, height: 30))
//        view.backgroundColor = .green
//        return view
//    }()
    
    /// The bar button item used internally to display the `title` attribute in the toolbar.
    let titleBarButtonItem = UIBarButtonItem(customView: UILabel())
    
    /// The bar button item that appears in the top left corner of the overlay.
    @objc public var leftBarButtonItem: UIBarButtonItem? {
        set(value) {
            if let value = value {
                self.leftBarButtonItems = [value]
            } else {
                self.leftBarButtonItems = nil
            }
        }
        get {
            return self.leftBarButtonItems?.first
        }
    }
    
    /// The bar button items that appear in the top left corner of the overlay.
    @objc public var leftBarButtonItems: [UIBarButtonItem]? {
        didSet {
            if self.window == nil {
                return
            }
            
            self.updateToolbarBarButtonItems()
        }
    }
    
    /// The bar button item that appears in the top right corner of the overlay.
    @objc public var rightBarButtonItem: UIBarButtonItem? {
        set(value) {
            if let value = value {
                self.rightBarButtonItems = [value]
            } else {
                self.rightBarButtonItems = nil
            }
        }
        get {
            return self.rightBarButtonItems?.first
        }
    }
    
    /// The bar button items that appear in the top right corner of the overlay.
    @objc public var rightBarButtonItems: [UIBarButtonItem]? {
        didSet {
            if self.window == nil {
                return
            }
            
            self.updateToolbarBarButtonItems()
        }
    }
    #endif
    
    /// The caption view to be used in the overlay.
    @objc open var captionView: AXCaptionViewProtocol = AXCaptionView() {
        didSet {
            guard let oldCaptionView = oldValue as? UIView else {
                assertionFailure("`oldCaptionView` must be a UIView.")
                return
            }
            
            guard let captionView = self.captionView as? UIView else {
                assertionFailure("`captionView` must be a UIView.")
                return
            }
            
            let index = self.bottomStackContainer.subviews.firstIndex(of: oldCaptionView)
            oldCaptionView.removeFromSuperview()
            self.bottomStackContainer.insertSubview(captionView, at: index ?? 0)
            self.setNeedsLayout()
        }
    }
    
    /// Whether or not to animate `captionView` changes. Defaults to true.
    @objc public var animateCaptionViewChanges: Bool = true {
        didSet {
            self.captionView.animateCaptionInfoChanges = self.animateCaptionViewChanges
        }
    }
    
    /// The inset of the contents of the `OverlayView`. Use this property to adjust layout for things such as status bar height.
    /// For internal use only.
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Container to embed all content anchored at the top of the `overlayView`.
    /// Add custom subviews to the top container in the order that you wish to stack them. These must be self-sizing views.
    @objc public var topStackContainer: AXStackableViewContainer!
    
    /// Container to embed all content anchored at the bottom of the `overlayView`.
    /// Add custom subviews to the bottom container in the order that you wish to stack them. These must be self-sizing views.
    @objc public var bottomStackContainer: AXStackableViewContainer!
    
    @objc public var bottomStackContainer2: UIView!
    @objc public var bottomStackContainerColor: UIView!

    

    
    /// A flag that is set at the beginning and end of `OverlayView.setShowInterface(_:alongside:completion:)`
    fileprivate var isShowInterfaceAnimating = false
    
    /// Closures to be processed at the end of `OverlayView.setShowInterface(_:alongside:completion:)`
    fileprivate var showInterfaceCompletions = [() -> Void]()
    
    fileprivate var isFirstLayout: Bool = true
    
    @objc public init() {
        super.init(frame: .zero)
        
        self.topStackContainer = AXStackableViewContainer(views: [], anchoredAt: .top)
        self.topStackContainer.backgroundColor = AXConstants.overlayForegroundColor
        self.topStackContainer.delegate = self
        self.addSubview(self.topStackContainer)
        
        #if os(iOS)
        self.toolbar.backgroundColor = .clear
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
      //  self.topStackContainer.addSubview(self.toolbar)
        //self.topStackContainer.addSubview(self.frameContainerView)
        #endif
        
        self.bottomStackContainer = AXStackableViewContainer(views: [], anchoredAt: .bottom)
        //self.bottomStackContainer.backgroundColor = AXConstants.overlayForegroundColor
        //self.bottomStackContainer.delegate = self
        //self.addSubview(self.bottomStackContainer)
        
        //self.bottomStackContainer.addSubview(self.toolbar)

        
        self.captionView.animateCaptionInfoChanges = true
        if let captionView = self.captionView as? UIView {
            self.bottomStackContainer.addSubview(captionView)
        }
        
        
        //----------
        
        
        self.bottomStackContainer2 = UIView()
        let color = UIColor.black.withAlphaComponent(0.5)
        bottomStackContainer2.backgroundColor = color
        self.addSubview(self.bottomStackContainer2)
        
        self.bottomStackContainerColor = UIView()
               bottomStackContainerColor.backgroundColor = color
               self.addSubview(self.bottomStackContainerColor)
        
        
//        textView.layer.borderColor = UIColor.white.cgColor
//        textView.layer.borderWidth = 1
//        textView.layer.cornerRadius = 5
        //textView.layer.masksToBounds = true
       // textView.layoutSubviews()
        textView.text = "Add description..."
        textView.layer.masksToBounds = true
              textView.layer.borderWidth = 0.5
              //self.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderColor = UIColor.white.cgColor
                //UIColor(red: 104/255, green: 111/255, blue: 116/255, alpha: 1).cgColor
             // self.isScrollEnabled = false
              
              textView.font = UIFont(name: "Verdana", size: 15)!
        textView.textColor = .black
              textView.tintColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
        //UIColor(red: 104/255, green: 111/255, blue: 116/255, alpha: 1)
              textView.textContainerInset = UIEdgeInsets(top: 5, left: 3, bottom: 6, right: 3)
        
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.bringSubviewToFront(self)
        
        
        textView.delegate = self
       // textView.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)

        
        
       // buttonOk.setTitle("OK", for: .normal)
       // buttonOk.addTarget(self, action: #selector(pressedOk), for: .touchDown)

       // textView.frame = CGRect(x: 30, y: 50, width: 100, height: 50)

        
        let bottomStackContainer3 = UIView(frame: CGRect(x: 100, y: 10, width: 100, height: 50))
//              let color2 = UIColor.black.withAlphaComponent(0.5)
//              bottomStackContainer3.backgroundColor = color2
              
        bottomStackContainer3.translatesAutoresizingMaskIntoConstraints = false
        
        textView.translatesAutoresizingMaskIntoConstraints = false
       
        bottomStackContainer2.translatesAutoresizingMaskIntoConstraints = false
        bottomStackContainerColor.translatesAutoresizingMaskIntoConstraints = false

        
        
        let buttonSendIcon = UIImage(named: "button_send_white", in: AXBundle.frameworkBundle, compatibleWith: nil)
        //let buttonSend  = UIButton(type: .custom)
       // buttonSend.frame = CGRect (x:0, y:30, width: (buttonSendIcon?.size.width)!, height: (buttonSendIcon?.size.height)!)
        buttonSend.setImage(buttonSendIcon, for: .normal)
        
        buttonSend.translatesAutoresizingMaskIntoConstraints = false
        
      //  buttonSend.addTarget(self, action: #selector(buttonSendClicked), for: UIControl.Event.touchDown)

        
        
        let buttonCancelIcon = UIImage(named: "button_cross_new", in: AXBundle.frameworkBundle, compatibleWith: nil)
               //let buttonCancel  = UIButton(type: .custom)
              // buttonSend.frame = CGRect (x:0, y:30, width: (buttonSendIcon?.size.width)!, height: (buttonSendIcon?.size.height)!)
               buttonCancel.setImage(buttonCancelIcon, for: .normal)
               
               buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        
     //   buttonCancel.addTarget(self, action: #selector(buttonCancelClicked), for: UIControl.Event.touchDown)
        



    
        self.bottomStackContainer2.addSubview(buttonSend)
        
        self.bottomStackContainer2.addSubview(buttonCancel)


        bottomStackContainer3.addSubview(self.textView)
        
        
        self.bottomStackContainer2.addSubview(bottomStackContainer3)

              

        print("buttonSend------------------> \(buttonSend.imageView?.image?.size.width)")
        print("buttonCancel------------------> \(buttonCancel.imageView?.image?.size.width)")

        
        if #available(iOS 11.0, *) {
            [
               // textView.topAnchor.constraint(equalTo: self.bottomStackContainer2.topAnchor),
                
//                textView.bottomAnchor.constraint(equalTo: self.bottomStackContainer2!.bottomAnchor),
//
//                textView.leadingAnchor.constraint(equalTo: self.bottomStackContainer2!.leadingAnchor, constant: 50),
//                textView.trailingAnchor.constraint(equalTo: self.bottomStackContainer2!.trailingAnchor, constant: -50 )
//                ,
//               textView.heightAnchor.constraint(equalToConstant: CGFloat(40.0)),
                
                                bottomStackContainer3.bottomAnchor.constraint(equalTo: self.bottomStackContainer2!.bottomAnchor),
                
                                bottomStackContainer3.leadingAnchor.constraint(equalTo: self.bottomStackContainer2!.leadingAnchor, constant: 48),
                                bottomStackContainer3.trailingAnchor.constraint(equalTo: self.bottomStackContainer2!.trailingAnchor, constant: -57 )
                                ,
                               //bottomStackContainer3.heightAnchor.constraint(equalToConstant: CGFloat(40.0)),
               buttonSend.bottomAnchor.constraint(equalTo: self.bottomStackContainer2!.bottomAnchor, constant: -12),
               buttonSend.leadingAnchor.constraint(equalTo: self.bottomStackContainer2!.trailingAnchor, constant: -44),
                
                buttonCancel.bottomAnchor.constraint(equalTo: self.bottomStackContainer2!.bottomAnchor, constant: -12),
                buttonCancel.trailingAnchor.constraint(equalTo: self.bottomStackContainer2!.leadingAnchor, constant: 35),
                
                
                                textView.bottomAnchor.constraint(equalTo: bottomStackContainer3.bottomAnchor, constant: -10),
                
                                textView.leadingAnchor.constraint(equalTo: bottomStackContainer3.leadingAnchor, constant: 0),
                                textView.trailingAnchor.constraint(equalTo: bottomStackContainer3.trailingAnchor, constant: 0 )
                                ,
                               textView.heightAnchor.constraint(equalToConstant: CGFloat(30.0)),


               
                ].forEach{$0.isActive = true}
            
            
                     let guide = self.safeAreaLayoutGuide
            
        
                    let bottomConstraint = NSLayoutConstraint(item: bottomStackContainer2, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
                    bottomConstraint.identifier = "bottomC"
            
                    let rightConstraint = NSLayoutConstraint(item: bottomStackContainer2, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            
                    let leftConstraint = NSLayoutConstraint(item: bottomStackContainer2, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant:  0)
            
            
            
            let bottomConstraintColor = NSLayoutConstraint(item: bottomStackContainerColor, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            
                 
                            let rightConstraintColor = NSLayoutConstraint(item: bottomStackContainerColor, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
                    
                            let leftConstraintColor = NSLayoutConstraint(item: bottomStackContainerColor, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant:  0)
            
            
//                    let widthConstraint = NSLayoutConstraint(item: bottomStackContainer2, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
                    let heightConstraint = NSLayoutConstraint(item: bottomStackContainer2, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bottomStackContainer3, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 22)
            
             let heightConstraint2 = NSLayoutConstraint(item: bottomStackContainer3, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: textView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
            
  //           let heightConstraint = NSLayoutConstraint(item: bottomStackContainer2, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: +60)
            
            let topConstraintColor = NSLayoutConstraint(item: bottomStackContainerColor, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: guide, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            
           //  let topConstraintColor = NSLayoutConstraint(item: bottomStackContainerColor, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 60)
                          
            
                    NSLayoutConstraint.activate([heightConstraint,heightConstraint2,
                                                 leftConstraint, bottomConstraint, rightConstraint,
                                                 bottomConstraintColor, topConstraintColor, rightConstraintColor, leftConstraintColor ])
            
            
//            [
//                          // textView.topAnchor.constraint(equalTo: self.bottomStackContainer2.topAnchor),
//                           
//                          bottomStackContainer2.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//
//                              bottomStackContainer2.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//                              bottomStackContainer2.trailingAnchor.constraint(equalTo: self.trailingAnchor)
//                           ,
//                                  bottomStackContainer2.heightAnchor.constraint(equalToConstant: 40)
//                           ].forEach{$0.isActive = true}
               } else {
                   // Fallback on earlier versions
               }
               
       
        //self.addSubview(self.textView)
        //----------
        

       
        
        
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main) { [weak self] (note) in
            self?.setNeedsLayout()
        }
    }
    
    @objc  func buttonCancelClicked()
    {
        print("buttonCancelClicked")
        
    }
    
    @objc func buttonSendClicked()
    {
        print("buttonSendClicked")
    }
    
      @objc func pressedOk(gesture: UITapGestureRecognizer) {
        print("pressedOk")
    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
                  print("textViewDidBeginEditing")

    }
    
    public func textViewDidChange(_ textView: UITextView) {
                          print("textViewDidChange")
        let size = CGSize(width:textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        
        if (estimatedSize.height < 130) {
        
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }

        }
        
          UIView.animate(withDuration: 0.25, animations: {
                    self.invalidateIntrinsicContentSize()
                    self.layoutIfNeeded()
                    //self.superview?.superview?.layoutIfNeeded()
                    // self.placeholder.frame = self.bounds
        
                }, completion: nil)
        }

    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
                                  print("textViewDidEndEditing")

    }
    
    @objc func textFieldTextDidChange(gesture: UITapGestureRecognizer) {
          print("textFieldTextDidChange")
        textView.invalidateIntrinsicContentSize()
        

      }
    
//     func intrinsicContentSize() -> CGSize {
//        if self.editing {
//            let textSize: CGSize = NSString(string: ((text ?? "" == "") ? self.placeholder : self.text) ?? "").sizeWithAttributes(self.typingAttributes)
//            return CGSize(width: textSize.width + (self.leftView?.bounds.size.width ?? 0) + (self.rightView?.bounds.size.width ?? 0) + 2, height: textSize.height)
//        } else {
//            return super.intrinsicContentSize()
//        }
//    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        
        #if os(iOS)
        if self.window != nil {
            self.updateToolbarBarButtonItems()
        }
        #endif
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.topStackContainer.contentInset = UIEdgeInsets(top: self.contentInset.top,
                                                           left: self.contentInset.left,
                                                           bottom: 0,
                                                           right: self.contentInset.right)
        self.topStackContainer.frame = CGRect(origin: .zero, size: self.topStackContainer.sizeThatFits(self.frame.size))
        
        self.bottomStackContainer.contentInset = UIEdgeInsets(top: 0,
                                                              left: self.contentInset.left,
                                                              bottom: self.contentInset.bottom,
                                                              right: self.contentInset.right)
        let bottomStackSize = self.bottomStackContainer.sizeThatFits(self.frame.size)
        self.bottomStackContainer.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.size.height - bottomStackSize.height),
                                                 size: bottomStackSize)
        
        self.isFirstLayout = false
    }
    
    var isKeyboardShown = false
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
      print("text1")
        print("point.y \(point.y)")
        
        let textViewFrame = bottomStackContainer2.convert(self.textView.frame.origin, to: self)
        print("textViewFrame.y \(textViewFrame.y)")
       // print("textViewFrame.manY \(textViewFrame.maxY)")


        if (isKeyboardShown && point.y < self.bottomStackContainer2.frame.minY
            && point.x > 75 && point.x < self.frame.width - 75
            ) {
            print("text2")

            self.textView.resignFirstResponder()
            
            return nil;
        }
        if (point.y > self.bottomStackContainer2.frame.minY  && point.x > 75 && point.x < self.frame.width - 75) {
            print("text3")

            return self.textView
        }
        
        if let view = super.hitTest(point, with: event) as? UIControl {
            print("AXOverlayView hit test 2");


            return view
        }
        
        return nil
    }
    
    // MARK: - Completions
    func performAfterShowInterfaceCompletion(_ closure: @escaping () -> Void) {
        self.showInterfaceCompletions.append(closure)
        
        if !self.isShowInterfaceAnimating {
            self.processShowInterfaceCompletions()
        }
    }
    
    func processShowInterfaceCompletions() {
        for completion in self.showInterfaceCompletions {
            completion()
        }
        
        self.showInterfaceCompletions.removeAll()
    }
    
    // MARK: - Show / hide interface
    func setShowInterface(_ show: Bool, animated: Bool, alongside closure: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        let alpha: CGFloat = show ? 1 : 0
        if abs(alpha - self.alpha) <= .ulpOfOne {
            return
        }
        
        self.isShowInterfaceAnimating = true
        
        if abs(alpha - 1) <= .ulpOfOne {
            self.isHidden = false
        }
        
        let animations = { [weak self] in
            self?.alpha = alpha
            closure?()
        }
        
        let internalCompletion: (_ finished: Bool) -> Void = { [weak self] (finished) in
            if abs(alpha) <= .ulpOfOne {
                self?.isHidden = true
            }
            
            self?.isShowInterfaceAnimating = false
            
            completion?(finished)
            self?.processShowInterfaceCompletions()
        }
        
        if animated {
            UIView.animate(withDuration: AXConstants.frameAnimDuration,
                           animations: animations,
                           completion: internalCompletion)
        } else {
            animations()
            internalCompletion(true)
        }
    }
    
    // MARK: - AXCaptionViewProtocol
    func updateCaptionView(photo: AXPhotoProtocol) {
        self.captionView.applyCaptionInfo(attributedTitle: photo.attributedTitle ?? nil,
                                          attributedDescription: photo.attributedDescription ?? nil,
                                          attributedCredit: photo.attributedCredit ?? nil)
        
        if self.isFirstLayout {
            self.setNeedsLayout()
            return
        }
        
        let size = self.bottomStackContainer.sizeThatFits(self.frame.size)
        let animations = { [weak self] in
            guard let `self` = self else { return }
            self.bottomStackContainer.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.size.height - size.height), size: size)
            self.bottomStackContainer.setNeedsLayout()
            self.bottomStackContainer.layoutIfNeeded()
        }
        
        if self.animateCaptionViewChanges {
            UIView.animate(withDuration: AXConstants.frameAnimDuration, animations: animations)
        } else {
            animations()
        }
    }
    
    // MARK: - AXStackableViewContainerDelegate
    func stackableViewContainer(_ stackableViewContainer: AXStackableViewContainer, didAddSubview: UIView) {
        self.setNeedsLayout()
        
    }
    
    func stackableViewContainer(_ stackableViewContainer: AXStackableViewContainer, willRemoveSubview: UIView) {
        DispatchQueue.main.async { [weak self] in
            self?.setNeedsLayout()
        }
    }
    
    #if os(iOS)
    // MARK: - UIToolbar convenience
    func updateToolbarBarButtonItems() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = AXConstants.overlayBarButtonItemSpacing
        
        var barButtonItems = [UIBarButtonItem]()
        if let leftBarButtonItems = self.leftBarButtonItems {
            let last = leftBarButtonItems.last
            for barButtonItem in leftBarButtonItems {

//                barButtonItem.setTitlePositionAdjustment(UIOffset(horizontal: 30, vertical: 50), for: UIBarMetrics.default)
//                barButtonItem.setTitlePositionAdjustment(UIOffset(horizontal: 30, vertical: 50), for: UIBarMetrics.compact)

                barButtonItems.append(barButtonItem)
                
                if barButtonItem != last {
                    barButtonItems.append(fixedSpace)
                }
            }
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
        
        barButtonItems.append(flexibleSpace)
        //let descriptionTextField: UITextField = UITextField(frame: CGRect(x:0,y:0,width: 100, height: 100))
//        descriptionTextField.layer.borderColor = UIColor.white.cgColor
//        descriptionTextField.layer.borderWidth = 1
//        descriptionTextField.layer.cornerRadius = 5
//        descriptionTextField.layer.masksToBounds = true
//        descriptionTextField.text = "Please enter description..."
//        descriptionTextField.defaultTextAttributes = defaultAttributes()
        //descriptionTextField.sizeToFit()
   //     let descriptionBarButton = UIBarButtonItem.init(customView: descriptionTextField)
     //   barButtonItems.append(descriptionBarButton)
        barButtonItems.append(flexibleSpace)

        
//        var centerBarButtonItem: UIBarButtonItem?
//        if let titleView = self.titleView as? UIView {
//            if let titleViewBarButtonItem = self.titleViewBarButtonItem, titleViewBarButtonItem.customView === titleView {
//                centerBarButtonItem = titleViewBarButtonItem
//            } else {
//                self.titleViewBarButtonItem = UIBarButtonItem(customView: titleView)
//                centerBarButtonItem = self.titleViewBarButtonItem
//            }
//        } else {
//            centerBarButtonItem = self.titleBarButtonItem
//        }
//
//        if let titleView = self.titleView as? UIView {
//            if let titleViewBarButtonItem = self.titleViewBarButtonItem, titleViewBarButtonItem.customView === titleView {
//                centerBarButtonItem = titleViewBarButtonItem
//            } else {
//                self.titleViewBarButtonItem = UIBarButtonItem(customView: titleView)
//                centerBarButtonItem = self.titleViewBarButtonItem
//            }
//        } else {
//            centerBarButtonItem = self.titleBarButtonItem
//        }
//
//        if let centerBarButtonItem = centerBarButtonItem {
//            barButtonItems.append(centerBarButtonItem)
//            barButtonItems.append(flexibleSpace)
//        }
        
        if let rightBarButtonItems = self.rightBarButtonItems?.reversed() {
            let last = rightBarButtonItems.last
            for barButtonItem in rightBarButtonItems {
                barButtonItems.append(barButtonItem)
                
                if barButtonItem != last {
                    barButtonItems.append(fixedSpace)
                }
            }
        }
        
        self.toolbar.items = barButtonItems
       // self.frameContainerView.frame = CGRect(x:10, y:0, width: 380, height: 30)
    }
    
    func updateTitleBarButtonItem() {
        func defaultAttributes() -> [NSAttributedString.Key: Any] {
            let pointSize: CGFloat = 17.0
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
        
        var attributedText: NSAttributedString?
        if let title = self.title {
            attributedText = NSAttributedString(string: title,
                                                attributes: self.titleTextAttributes ?? defaultAttributes())
        } else if let internalTitle = self.internalTitle {
            attributedText = NSAttributedString(string: internalTitle,
                                                attributes: self.titleTextAttributes ?? defaultAttributes())
        }
        
        if let attributedText = attributedText {
            guard let titleBarButtonItemLabel = self.titleBarButtonItem.customView as? UILabel else { return }
            if titleBarButtonItemLabel.attributedText != attributedText {
                titleBarButtonItemLabel.attributedText = attributedText
                titleBarButtonItemLabel.sizeToFit()
            }
        }
    }
    #endif
    
   
}

