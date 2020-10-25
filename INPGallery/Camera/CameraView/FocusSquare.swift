import UIKit

public class FocusSquare: UIView  {
    
//    let imageView = UIView()
//              imageView.backgroundColor = UIColor.clear
//              imageView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
//              imageView.layer.borderColor = UIColor.yellow.cgColor
//              imageView.layer.borderWidth = 2
//              imageView.layer.cornerRadius = 15
//              imageView.alpha = 0
//
//           drawLine(startx: imageView.frame.width/2, starty: 0, endx: imageView.frame.width/2, endy: 10, lineWidth: 2, color: UIColor.yellow)
//
//              return imageView
//              }()
//
//       override func drawRect(startx: CGFloat, starty: CGFloat, endx: CGFloat, endy: CGFloat, lineWidth: CGFloat, color: UIColor) {
//           let aPath = UIBezierPath()
//           aPath.move(to: CGPoint(x:startx, y:starty))
//           aPath.addLine(to: CGPoint(x: endx, y: endy))
//           aPath.close()
//           color.set()
//           aPath.lineWidth = lineWidth
//           aPath.stroke()
//       }

    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
        layer.borderColor = UIColor.yellow.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 15
        alpha = 0
        backgroundColor = .clear
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.yellow.cgColor)
        
        context.move(to: CGPoint(x: self.frame.width/2, y: 0))
        context.addLine(to: CGPoint(x: self.frame.width/2, y: 10))
        
        context.move(to: CGPoint(x: self.frame.width/2, y: self.frame.height))
        context.addLine(to: CGPoint(x: self.frame.width/2, y: self.frame.width - 10))
        
        context.move(to: CGPoint(x: 0, y: self.frame.height/2))
        context.addLine(to: CGPoint(x: 10, y: self.frame.height/2))
        
        context.move(to: CGPoint(x: self.frame.width, y: self.frame.height/2))
        context.addLine(to: CGPoint(x: self.frame.width - 10, y: self.frame.height/2))
        
        context.strokePath()
    }
}
