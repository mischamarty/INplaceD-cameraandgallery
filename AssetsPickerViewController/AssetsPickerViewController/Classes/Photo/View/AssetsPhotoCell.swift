//
//  AssetsPhotoCell.swift
//  Pods
//
//  Created by DragonCherry on 5/17/17.
//
//

import UIKit
import Photos

public protocol AssetsPhotoCellProtocol {
    var asset: PHAsset? { get set }
    //var isSelected: Bool { get set }
    //var isHighlighted: Bool { get set }
    var isVideo: Bool { get set }
    var imageView: UIImageView { get }
    var count: Int { set get }
    var duration: TimeInterval { set get }
    var markedSelected: Bool {get set}
}

public protocol AssetsPhotoCellDelegate: class {
    func didPressSelectButton(sender: Any)
}

open class AssetsPhotoCell: UICollectionViewCell, AssetsPhotoCellProtocol, AssetsPhotoCellDelegate {
    
    
    open var markedSelected: Bool = false {
          didSet {
                    if (!markedSelected) {
        
                                            self.selectButton.setTitle("", for: .selected)
                                            self.selectButton.setTitle("", for: .normal)
                                            self.selectButton.backgroundColor = UIColor.clear
                    }
                }
    }
    
    public weak var delegate: AssetsPhotoCellDelegate?
    


    // MARK: - AssetsPhotoCellProtocol
    open var asset: PHAsset? {
        didSet {
            // customizable
            if let asset = asset {
                panoramaIconView.isHidden = asset.mediaSubtypes != .photoPanorama
            }
        }
    }
    
    open var isVideo: Bool = false {
        didSet {
            durationLabel.isHidden = !isVideo
            if !isVideo {
                imageView.removeGradient()
            }
        }
    }
    
    var animationStarted = false
    
//    open override var isHighlighted: Bool {
//         didSet {
//            if (!isHighlighted) {
//
//                                    self.selectButton.setTitle("", for: .selected)
//                                    self.selectButton.setTitle("", for: .normal)
//                                    self.selectButton.backgroundColor = UIColor.clear
//            }
//        }
//    }
    
//    open override var isSelected: Bool {
//        didSet {
////            if (!isSelected) {
////                let main = DispatchQueue.main
////                main.asyncAfter(deadline: .now() + 0.5) {
////                    self.selectButton.isHidden = true
////                }
////            }
////            else {
////                self.selectButton.isHidden = false
////            }
//            //overlay.isHidden = !isSelected
//           // self.selectButton.isHidden = !isSelected
//
//            if (!isSelected ) {
//
//                                    self.selectButton.setTitle("", for: .selected)
//                                    self.selectButton.setTitle("", for: .normal)
//                                    self.selectButton.backgroundColor = UIColor.clear
//            }
////            else {
////                self.selectButton.setTitle("\(count)", for: .selected)
////                self.selectButton.setTitle("\(count)", for: .normal)
////                self.selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
////            }
//
////            else if (isSelected && oldValue != isSelected) {
////
////            }
//        }
//    }
    
    public let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor(rgbHex: 0xF0F0F0)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    open var count: Int = 0 {
        didSet {
            selectButton.setTitle("\(count)", for: .selected)
            selectButton.setTitle("\(count)", for: .normal)
            selectButton.titleLabel!.font = UIFont(name: "Verdana", size: 16)!
            selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
            //overlay.countLabel.text = "\(count)";
            print("count \(count)") }
    }
    
    open var duration: TimeInterval = 0 {
        didSet {
            durationLabel.text = String(duration: duration)
        }
    }
    
    // MARK: - Views
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = UIFont.systemFont(forStyle: .caption1)
        return label
    }()
    
    private let panoramaIconView: PanoramaIconView = {
        let view = PanoramaIconView()
        view.isHidden = true
        return view
    }()
    
//    private let overlay: AssetsPhotoCellOverlay = {
//        let overlay = AssetsPhotoCellOverlay()
//        overlay.isHidden = true
//        return overlay
//    }()
    
    open var  emptyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        //button.backgroundColor = UIColor(red: 90/255, green: 119/255, blue: 236/255, alpha: 1)
        button.backgroundColor = .clear
        button.contentMode = .center
        button.clipsToBounds = true
        return button
    }()
    
    open var selectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.backgroundColor = .clear
        button.contentMode = .center
        button.clipsToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
       // button.isHidden = true
        return button
    }()

    
    @objc  public func didPressSelectButton(sender: Any) {
        //print("didPressSelectButton from AssetsPhotoCell ==== \(isHighlighted) ==== \(self.isSelected)) === \(self.selectButton.isSelected) == \( self.selectButton.tag) == \(self.count)")
        //overlay.isHidden = !overlay.isHidden
        //animationStarted = true
        
        print("didPressSelectButton from AssetsPhotoCell ==== \(self.markedSelected)")
        
      //  if (!(self.count > 0)) {
        if (!self.markedSelected) {
            self.selectButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
           // self.selectButton.isHidden = !self.selectButton.isHidden

            
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
                self.selectButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.selectButton.setTitle("\(self.count)", for: .selected)
                self.selectButton.setTitle("\(self.count)", for: .normal)

            }, completion: { _ in
                self.selectButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                //self.selectButton.isSelected = !self.selectButton.isSelected
                
                // self.selectButton.isSelected = true
                self.markedSelected = true
                
                //self.selectButton.tag = 1
                //self.animationStarted = false
            })
            
//            UIView.transition(with: selectButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
//                self.selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
//                self.selectButton.setTitle("\(self.count)", for: .selected)
//            }, completion: nil)
            
            
//            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
//                self.selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
//                self.selectButton.setTitle("\(self.count)", for: .selected)
//            }, completion: { _ in
//                // do stuff once animation is complete
//            })
        }
        else {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                self.selectButton.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
                self.selectButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.selectButton.backgroundColor = .clear
            }, completion: { _ in
                self.selectButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.selectButton.setTitle("", for: .normal)
                self.selectButton.setTitle("", for: .selected)
               
                //self.selectButton.isSelected = !self.selectButton.isSelected
                 //self.selectButton.isSelected = false
                self.markedSelected = false

                // self.selectButton.tag = 0
                //self.animationStarted = false
              //  self.selectButton.isHidden = !self.selectButton.isHidden


            })
            
//            UIView.transition(with: selectButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
//                self.selectButton.backgroundColor = .clear
//                self.selectButton.setTitle("", for: .normal)
//            }, completion: nil)
            
//            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
//                self.selectButton.backgroundColor = .clear
//                self.selectButton.setTitle("", for: .normal)
//
//            }, completion: { _ in
//                // do stuff once animation is complete
//            })

        }
        //selectButton.layoutSubviews()
        delegate?.didPressSelectButton(sender: self)
    }
    
    // MARK: - Lifecycle
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(imageView)
        contentView.addSubview(durationLabel)
        contentView.addSubview(panoramaIconView)
        //contentView.addSubview(overlay)
        //overlay.layer.zPosition = 10
        //overlay.frame = CGRect(x: self.frame.width - 33, y: 3, width: 30, height: 30)
        //selectButton.frame = CGRect(x: self.frame.width - 33, y: 3, width: 30, height: 30)
        
        contentView.addSubview(emptyButton)
        contentView.addSubview(selectButton)
        
        emptyButton.addTarget(self, action: #selector(didPressSelectButton), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(didPressSelectButton), for: .touchUpInside)

        
        selectButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 23, height: 23))
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(4)
        }
        
        emptyButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25, height: 25))
            make.top.equalToSuperview().inset(3)
            make.trailing.equalToSuperview().inset(3)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        durationLabel.snp.makeConstraints { (make) in
            make.height.equalTo(durationLabel.font.pointSize + 10)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        panoramaIconView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 14, height: 7))
            make.trailing.equalToSuperview().inset(6.5)
            make.bottom.equalToSuperview().inset(10)
        }
        
//        overlay.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
    }
    
//    open override func willMove(toSuperview newSuperview: UIView?) {
//        self.emptyButton.alpha = 0
//               UIView.animate(withDuration: 3.5, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
//                   self.emptyButton.alpha = 1
//               }
//        )
//        
//    }
    
    
    
    
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if isVideo {
            imageView.setGradient(.fromBottom, start: 0, end: 0.2, startAlpha: 0.75, color: .black)
        }
        
//        self.emptyButton.alpha = 0
//        UIView.animate(withDuration: 3.5, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
//            self.emptyButton.alpha = 1
//        }
   //     )
    }
}
