import UIKit

protocol TopViewDelegate: class {

  func flashButtonDidPress(_ title: String)
  //func rotateDeviceDidPress()
  func  cancelButtonDidPress()
}

class TopView: UIView {

  struct Dimensions {
    static let leftOffset: CGFloat = 11
    static let rightOffset: CGFloat = 7
    static let height: CGFloat = 34
  }

  var currentFlashIndex = 0
  let flashButtonTitles = ["Auto", "On", "Off"]

  lazy var flashButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.titleLabel?.font = UIFont (name: "Verdana", size: 13)
    button.setImage(AssetManager.getImage("Auto"), for: UIControl.State())
   // button.setTitle("Auto", for: UIControl.State())
    button.setTitle("", for: UIControl.State())
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    button.setTitleColor(UIColor.white, for: UIControl.State())
    button.setTitleColor(UIColor.white, for: .highlighted)
    //button.titleLabel?.font = Configuration.flashButton
    button.addTarget(self, action: #selector(flashButtonDidPress(_:)), for: .touchUpInside)
    button.contentHorizontalAlignment = .left

    return button
    }()

  lazy var rotateCamera: UIButton = { [unowned self] in
    let button = UIButton()
    
        
    let image = UIImage(named: "button_exit")
    
    button.setImage(image, for: .normal)
    button.titleLabel?.font = Configuration.doneButton
    
    button.addTarget(self, action: #selector(rotateCameraButtonDidPress(_:)), for: .touchUpInside)
    button.imageView?.contentMode = .center

    return button
    }()

  weak var delegate: TopViewDelegate?

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    var buttons: [UIButton] = [flashButton]

    if Configuration.canRotateCamera {
        buttons.append(rotateCamera)
    }

    for button in buttons {
    //  button.layer.shadowColor = UIColor.black.cgColor
//      button.layer.shadowOpacity = 0.5
//      button.layer.shadowOffset = CGSize(width: 0, height: 1)
//      button.layer.shadowRadius = 0
      button.translatesAutoresizingMaskIntoConstraints = false
      addSubview(button)
    }

    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Action methods

    @objc func flashButtonDidPress(_ button: UIButton) {
    currentFlashIndex += 1
    currentFlashIndex = currentFlashIndex % flashButtonTitles.count

    switch currentFlashIndex {
    case 1:
      //button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), for: UIControlState())
      //button.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), for: .highlighted)
        button.setTitleColor(UIColor.white, for: UIControl.State())
      button.setTitleColor(UIColor.white, for: .highlighted)

    default:
        button.setTitleColor(UIColor.white, for: UIControl.State())
      button.setTitleColor(UIColor.white, for: .highlighted)
    }

    let newTitle = flashButtonTitles[currentFlashIndex]

        button.setImage(AssetManager.getImage(newTitle), for: UIControl.State())
        button.setTitle(newTitle, for: UIControl.State())

    delegate?.flashButtonDidPress(newTitle)
  }

    @objc func rotateCameraButtonDidPress(_ button: UIButton) {
    delegate?.cancelButtonDidPress()
    //delegate?.rotateDeviceDidPress()
  }
}
