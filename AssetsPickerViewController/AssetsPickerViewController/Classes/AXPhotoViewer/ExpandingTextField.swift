////
////  ExpandingTextField.swift
////  AXPhotoViewer
////
////  Created by mischa on 15.12.2019.
////
//
//import UIKit
//
//import UIKit
//
//public protocol ExpandableTextViewPlaceholderDelegate: class {
//    func expandableTextViewDidShowPlaceholder(_ textView: ExpandableTextView)
//    func expandableTextViewDidHidePlaceholder(_ textView: ExpandableTextView)
//}
//
//open class ExpandableTextView: UITextView {
//
//    private let placeholder: UITextView = UITextView()
//    public weak var placeholderDelegate: ExpandableTextViewPlaceholderDelegate?
//
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.commonInit()
//    }
//
//    override public init(frame: CGRect, textContainer: NSTextContainer?) {
//        super.init(frame: frame, textContainer: textContainer)
//        self.commonInit()
//    }
//
//    override open var contentSize: CGSize {
//        didSet {
//            self.invalidateIntrinsicContentSize()
//            self.layoutIfNeeded() // needed?
//        }
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    private func commonInit() {
//        NotificationCenter.default.addObserver(self, selector: #selector(ExpandableTextView.textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
//        self.configurePlaceholder()
//        self.updatePlaceholderVisibility()
//        
////        self.layer.backgroundColor = UIColor(red: 104/255, green: 111/255, blue: 116/255, alpha: 1).cgColor
////        self.layer.cornerRadius = 9
////        self.layer.masksToBounds = true
////        self.layer.borderWidth = 1
////        self.layer.borderColor = UIColor(red: 104/255, green: 111/255, blue: 116/255, alpha: 1).cgColor
//        self.layer.cornerRadius = 9
//        self.layer.masksToBounds = true
//        self.layer.borderWidth = 0.5
//        //self.layer.borderColor = UIColor.black.cgColor
//        self.layer.borderColor = UIColor(red: 104/255, green: 111/255, blue: 116/255, alpha: 1).cgColor
//        
//    }
//
//    open override func didMoveToWindow() {
//        super.didMoveToWindow()
//
//        if self.isPlaceholderViewAttached {
//            self.placeholderDelegate?.expandableTextViewDidShowPlaceholder(self)
//        } else {
//            self.placeholderDelegate?.expandableTextViewDidHidePlaceholder(self)
//        }
//    }
//
//    override open func layoutSubviews() {
//        super.layoutSubviews()
//        self.placeholder.frame = self.bounds
//    }
//
//    override open var intrinsicContentSize: CGSize {
//        return self.contentSize
//    }
//
//    override open var text: String! {
//        didSet {
//            self.textDidChange()
//        }
//    }
//
//    open var placeholderText: String {
//        get {
//            return self.placeholder.text
//        }
//        set {
//            self.placeholder.text = newValue
//        }
//    }
//
//    override open var textContainerInset: UIEdgeInsets {
//        didSet {
//            self.configurePlaceholder()
//        }
//    }
//
//    override open var textAlignment: NSTextAlignment {
//        didSet {
//            self.configurePlaceholder()
//        }
//    }
//
//    @available(*, deprecated, message: "use placeholderText property instead")
//    open func setTextPlaceholder(_ textPlaceholder: String) {
//        self.placeholder.text = textPlaceholder
//    }
//
//    open func setTextPlaceholderColor(_ color: UIColor) {
//        self.placeholder.textColor = color
//    }
//
//    open func setTextPlaceholderFont(_ font: UIFont) {
//        self.placeholder.font = font
//    }
//
//    open func setTextPlaceholderAccessibilityIdentifier(_ accessibilityIdentifier: String) {
//        self.placeholder.accessibilityIdentifier = accessibilityIdentifier
//    }
//
//    @objc func textDidChange() {
//        self.updatePlaceholderVisibility()
//        self.scrollToCaret()
//
//        // Bugfix:
//        // 1. Open keyboard
//        // 2. Paste very long text (so it snaps to nav bar and shows scroll indicators)
//        // 3. Select all and cut
//        // 4. Paste again: Texview it's smaller than it should be
//        self.isScrollEnabled = false
//        self.isScrollEnabled = true
//        
//        UIView.animate(withDuration: 0.25, animations: {
//            self.invalidateIntrinsicContentSize()
//            self.layoutIfNeeded()
//            self.superview?.layoutIfNeeded()
//            //self.superview?.superview?.layoutIfNeeded()
//            // self.placeholder.frame = self.bounds
//            
//        }, completion: nil)
//        
//    }
//
//    private func scrollToCaret() {
//        if let textRange = self.selectedTextRange {
//            var rect = caretRect(for: textRange.end)
//            rect = CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: rect.height + textContainerInset.bottom))
//            //rect = CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: rect.height))
//            UIView.animate(withDuration: 0.25, animations: {
//            self.scrollRectToVisible(rect, animated: false)
//            }, completion: nil)
//
//        }
//    }
//    
////    func addNotificationObservers() {
////
////        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: .UITextFieldTextDidBeginEditing, object: nil)
////
////    }
////
////    @objc func textFieldDidBeginEditing(_ notification: NSNotification) {
////        print("did begin editing")
////        self.hidePlaceholder()
////
////    }
//
//    
//    
//
//    private func updatePlaceholderVisibility() {
//        if self.text == "" {
//            self.showPlaceholder()
//        } else {
//            self.hidePlaceholder()
//        }
//    }
//
//    private func showPlaceholder() {
//        let wasAttachedBeforeShowing = self.isPlaceholderViewAttached
//        self.addSubview(self.placeholder)
//
//        if !wasAttachedBeforeShowing {
//            self.placeholderDelegate?.expandableTextViewDidShowPlaceholder(self)
//        }
//    }
//
//    private func hidePlaceholder() {
//        let wasAttachedBeforeHiding = self.isPlaceholderViewAttached
//        self.placeholder.removeFromSuperview()
//
//        if wasAttachedBeforeHiding {
//            self.placeholderDelegate?.expandableTextViewDidHidePlaceholder(self)
//        }
//    }
//
//    private var isPlaceholderViewAttached: Bool {
//        return self.placeholder.superview != nil
//    }
//
//    private func configurePlaceholder() {
//        self.placeholder.translatesAutoresizingMaskIntoConstraints = false
//        self.placeholder.isEditable = false
//        self.placeholder.isSelectable = false
//        self.placeholder.isUserInteractionEnabled = false
//        self.placeholder.textAlignment = self.textAlignment
//        self.placeholder.textContainerInset = self.textContainerInset
//        self.placeholder.backgroundColor = UIColor.clear
//    }
//}
//
//
//class ExpandingTextField: UITextView {
//    
//    var lastTextBeforeEditing: String?
//
//         override init(frame: CGRect) {
//             super.init(frame: frame)
//             setupTextChangeNotification()
//         }
//
//         required init?(coder aDecoder: NSCoder) {
//             super.init(coder: aDecoder)
//             setupTextChangeNotification()
//         }
//
//         func setupTextChangeNotification() {
//             NotificationCenter.default.addObserver(
//                forName: UITextField.textDidChangeNotification,
//                 object: self,
//                 queue: OperationQueue.main) { (notification) in
//                     self.invalidateIntrinsicContentSize()
//             }
//             NotificationCenter.default.addObserver(
//                forName: UITextField.textDidBeginEditingNotification,
//                 object: self,
//                 queue: OperationQueue.main) { (notification) in
//                     self.lastTextBeforeEditing = self.text
//             }
//         }
//
//         override var intrinsicContentSize: CGSize {
//             var size = super.intrinsicContentSize
//
//             if isEditing, let text = text, let lastTextBeforeEditing = lastTextBeforeEditing {
//                 let string = text as NSString
//                let stringSize = string.size(withAttributes: typingAttributes)
//                let origSize = (lastTextBeforeEditing as NSString).size(withAttributes: typingAttributes)
//                 size.width = size.width + (stringSize.width - origSize.width)
//             }
//
//             return size
//         }
//
//         deinit {
//             NotificationCenter.default.removeObserver(self)
//         }
//     
//}
