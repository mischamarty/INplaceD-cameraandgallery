////
////  ButtonStatusView.swift
////  AXPhotoViewer
////
////  Created by mischa on 12/09/2019.
////
//
////
////  ButtonStatusView.swift
////  AssetsPickerViewController
////
////  Created by mischa on 25/08/2019.
////

import UIKit

class AXButtonStatusView: UIView {
    
    var currentValue: Int = 0  {
        didSet {
            print ("currentValue:\(currentValue)")
            if (currentValue > 0) {
            self.setTitle(title: String(currentValue))
            }
            else {
                self.setTitle(title: "")
            }

        }
    }
    
    open var  emptyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        //button.center = CGPoint (x: 0, y: 0)
 //       button.translatesAutoresizingMaskIntoConstraints = false

//        button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil,
//                                                attribute: .notAnAttribute, multiplier: 1.0, constant: 30))
//              button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil,
//                                                      attribute: .notAnAttribute, multiplier: 1.0, constant: 30))
        
//          self.addConstraint(NSLayoutConstraint(item: emptyButton, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 2.0))
        
        button.layer.cornerRadius = 17
        
        //button.layer.roundCorners(radius: 16)

        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        
        //button.backgroundColor = UIColor(red: 90/255, green: 119/255, blue: 236/255, alpha: 1)
        button.backgroundColor = .clear
        button.contentMode = .center
        
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 5
        
        button.clipsToBounds = false
    
        return button
    }()
    
    open var  backgroundView: UIView = {
        let button = UIView()
        button.frame = CGRect(x: 1, y: 1, width: 32, height: 32)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        //button.layer.borderWidth = 1.5
        //button.layer.borderColor = UIColor.white.cgColor
        //button.backgroundColor = UIColor(red: 90/255, green: 119/255, blue: 236/255, alpha: 1)
        button.backgroundColor = .clear
        button.contentMode = .center
        button.clipsToBounds = true
        return button
    }()
    
    let selectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 1, y: 1, width: 32, height: 32)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        //button.layer.borderWidth = 1.5
        //button.layer.borderColor = UIColor.white.cgColor
        //button.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentMode = .center
        
        //       var layer: CALayer {
        //         return button.layer
        //       }
        //
        //       var backView: UIView {
        //           let view = UIView()
        //           return view
        //       }
        //
        //       backView.frame = button.frame
        //       backView.backgroundColor = .yellow
        //       backView.layer.cornerRadius = 0.5 * button.bounds.size.width
        
        // button.addSubview(backView)
        //backView.sendSubviewToBack(button)
        
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        

//        self.addConstraint(NSLayoutConstraint(item: emptyButton, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
//        self.addConstraint(NSLayoutConstraint(item: emptyButton, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
        
      
        
        self.drawRingFittingInsideView(rect: CGRect(x: 0, y: 0, width: 34, height: 34))
        
       // self.addSubview(emptyButton)
        self.addSubview(backgroundView)
        self.addSubview(selectButton)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        let roundPath = UIBezierPath (roundedRect: bounds, cornerRadius: bounds.height/2)
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = roundPath.cgPath
//        emptyButton.layer.mask = maskLayer
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func hideBackgroundColorWithAnimation() {
        
    }
    
    func showBackgroundColorWithAnimation() {
        
    }
    
    func setBackgroundColor(color: UIColor) {
        backgroundView.backgroundColor = color
    }
    func getBackgroundColor() -> UIColor {
        return backgroundView.backgroundColor!
       }
    
    func setTitle( title: String) {
        selectButton.setTitle(title, for: .normal)
    }
    
    internal func drawRingFittingInsideView(rect: CGRect)->()
    {
        let desiredLineWidth:CGFloat = 1.5    // your desired value
    let hw:CGFloat = desiredLineWidth/2

        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: hw,dy: hw) )

    let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
    shapeLayer.lineWidth = desiredLineWidth
    layer.addSublayer(shapeLayer)
    }
    
}



//extension CALayer {
//
//   func roundCorners(radius: CGFloat) {
//       let roundPath = UIBezierPath(
//           roundedRect: self.bounds,
//           cornerRadius: radius)
//       let maskLayer = CAShapeLayer()
//       maskLayer.path = roundPath.cgPath
//       self.mask = maskLayer
//   }
//
//}

//
//import UIKit
//
//class AXButtonStatusView: UIView {
//
//     var prevCount:Int = 0;
//
//        let button:UIButton = {
//            let button = UIButton(type: .custom)
//            button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
//            button.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
//
//            button.contentMode = .center
//
//            //button.layer.cornerRadius = 0.5 * button.frame.size.width
//
//            button.layer.cornerRadius = button.frame.width / 2;
//
//            button.titleLabel?.font = UIFont(name: "Verdana", size: 20)
//
//
//
//            //button.layer.borderColor = UIColor.white.cgColor
//            button.layer.borderWidth = 0
//            button.clipsToBounds = true
//
//            button.setTitleColor(UIColor.white, for: .normal)
//            button.isHidden = true
//            return button
//        }()
//
//        convenience init(frame: CGRect, count: Int) {
//            self.init(frame: frame)
//            self.updateStatusView(count: count)
//        }
//
//
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//
//    //        let viewExt = UIView()
//    //        viewExt.frame =  CGRect(x: 0, y: 0, width: 60, height: 60)
//            //button.frame = frame
//            self.addSubview(button)
//
//
//        }
//
//        required init?(coder aDecoder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//
//        open func updateStatusView(count: Int) {
//
//            if (count >= 1) {
//                button.isHidden = false
//
//                if (prevCount == 0 && count >= 1){
//                    self.button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//
//
//
//                    UIView.animate(withDuration: 0.15, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
//                        self.button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//
//                    }, completion: { _ in
//
//                    })
//
//                }
//            }
//            else {
//                self.button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
//                    self.button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//
//                }, completion: { _ in
//                    self.button.isHidden = true
//                })
//            }
//            if (count == 0){
//                button.setTitle("1", for: .normal)
//            }
//            else {
//                button.setTitle("\(count)", for: .normal)
//            }
//            prevCount =  count;
//
//        }
//
//}
