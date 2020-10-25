import UIKit

protocol BottomContainerViewDelegate: class {

  func pickerButtonDidPress()
  func pickerButtonDidLongPress()
  func pickerButtonDidRelease()
  func doneButtonDidPress()
  func cancelButtonDidPress()
  func imageStackViewDidPress()
  func rotateDeviceDidPress()
}

open class BottomContainerView: UIView {

  struct Dimensions {
    static let height: CGFloat = 101
    
  }

  var photoModeOnly:Bool
  lazy var pulsator = Pulsator()

    
  lazy var pickerButton: ButtonPicker = { [unowned self] in
    let pickerButton = ButtonPicker()
    pickerButton.setTitleColor(UIColor.white, for: UIControl.State())
    pickerButton.delegate = self

    return pickerButton
    }()

  lazy var borderPickerButton: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
    view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2
 
    return view
    }()
    
    lazy var borderPickerButton2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth2
        view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize2 / 2
   
    return view
    }()
    
    lazy var videoButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth2
        view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize2 / 2
        
        return view
    }()
    

  open lazy var doneButton: UIButton = { [unowned self] in
    let button = UIButton()
    //button.setTitle(Configuration.cancelButtonTitle, for: UIControlState())
    if (self.photoModeOnly) {
        let image = UIImage(named: "button_fotopovorot_new")
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.titleLabel?.font = Configuration.doneButton
        button.addTarget(self, action: #selector(rotateCameraButtonDidPress(_:)), for: .touchUpInside)
    }
    
    else {
        
        //let image = UIImage(named: "button_exit")
        let image = UIImage(named: "button_fotopovorot_new")
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)

        button.titleLabel?.font = Configuration.doneButton
        button.addTarget(self, action: #selector(doneButtonDidPress(_:)), for: .touchUpInside)
        
    }
    

    return button
    }()
    
    open lazy var galleryButton: UIButton = { [unowned self] in
        let button = UIButton()
        
        if (self.photoModeOnly) {
            
            let image = UIImage(named: "button_exit")
            button.setImage(image, for: .normal)
            button.titleLabel?.font = Configuration.doneButton
            button.addTarget(self, action: #selector(doneButtonDidPress(_:)), for: .touchUpInside)
        }
        else {
            let image = UIImage(named: "button_sun_big")
            button.setImage(image, for: .normal)
            button.titleLabel?.font = Configuration.doneButton
            button.addTarget(self, action: #selector(handleTapGestureRecognizer(_:)), for: .touchUpInside)
        }

        
        //button.setTitle(Configuration.cancelButtonTitle, for: UIControlState())
        
        return button
        }()

  //lazy var stackView = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = Configuration.backgroundColor

    return view
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTapGestureRecognizer(_:)))

    return gesture
    }()

  weak var delegate: BottomContainerViewDelegate?
  var pastCount = 0

  // MARK: Initializers

//    public convenience init(frame: CGRect,b:Bool) {
//    //super.init(frame: frame)
//    self.init(frame: frame)
//    self.photoModeOnly = b
//    }
    
//    init(b:Bool) {
//       self.photoModeOnly = b
//    }
    
  public init(frame: CGRect, b:Bool) {
    self.photoModeOnly = b
    super.init(frame: frame)

    //[borderPickerButton, pickerButton, doneButton, stackView, topSeparator].forEach {
    [borderPickerButton, borderPickerButton2, pickerButton, doneButton,
     galleryButton, topSeparator, videoButton].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
//    if (photoModeOnly) {
//    galleryButton.isHidden = true
//    }
    
    videoButton.layer.addSublayer(pulsator)
    pulsator.numPulse = 1
    pulsator.radius = 115
    pulsator.backgroundColor = UIColor.red.cgColor
    pulsator.isHidden = true;
    videoButton.isHidden = true;

    backgroundColor = Configuration.backgroundColor
    //stackView.accessibilityLabel = "Image stack"
    //stackView.addGestureRecognizer(tapGestureRecognizer)
    
//    if (self.photoModeOnly) {
//
//        let image = UIImage(named: "button_exit")
//        galleryButton.setImage(image, for: .normal)
//        galleryButton.titleLabel?.font = Configuration.doneButton
//        galleryButton.addTarget(self, action: #selector(doneButtonDidPress(_:)), for: .touchUpInside)
//
//        let imageDone = UIImage(named: "button_fotopovorot_big")
//        doneButton.setImage(image, for: .normal)
//        doneButton.titleLabel?.font = Configuration.doneButton
//        doneButton.addTarget(self, action: #selector(rotateCameraButtonDidPress(_:)), for: .touchUpInside)
//    }


    setupConstraints()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Action methods

    @objc func doneButtonDidPress(_ button: UIButton) {
    if button.currentImage ==  UIImage(named: "button_fotopovorot_new") {
      //delegate?.cancelButtonDidPress()
        delegate?.rotateDeviceDidPress()
    } else {
      delegate?.doneButtonDidPress()
    }
  }

    @objc func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
    delegate?.imageStackViewDidPress()
  }

//  fileprivate func animateImageView(_ imageView: UIImageView) {
//    imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
//
//    UIView.animate(withDuration: 0.3, animations: {
//      imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
//      }, completion: { _ in
//        UIView.animate(withDuration: 0.2, animations: { _ in
//          imageView.transform = CGAffineTransform.identity
//        })
//    })
//  }
}

// MARK: - ButtonPickerDelegate methods

extension BottomContainerView: ButtonPickerDelegate {

  func buttonDidPress() {
    print("BottomContainerView buttonDidPress")
    delegate?.pickerButtonDidPress()
  }
  func buttonDidLongPress() {
    if (!photoModeOnly){
   // self.pickerButton.isHidden = true
      videoButton.isHidden = false
      pulsator.isHidden = false;
      pulsator.position = CGPoint(x: self.videoButton.frame.height / 2, y: self.videoButton.frame.width / 2)
        
        pulsator.start()

        
//        if (!photoModeOnly) {
//      pulsator.start()
//        }
//        else {
//            if (pulsator.position.y > self.frame.height-200) {
//                pulsator.start()
//            }
//        }
      delegate?.pickerButtonDidLongPress()
    }
    }
    func buttonDidRelease() {
         if (!photoModeOnly){
        videoButton.isHidden = true
        pulsator.isHidden = true;
        pulsator.stop()
        delegate?.pickerButtonDidRelease()
        }
    }
    
    @objc func rotateCameraButtonDidPress(_ button: UIButton) {
        delegate?.rotateDeviceDidPress()
    }
}
