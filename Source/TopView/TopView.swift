import UIKit

protocol TopViewDelegate: AnyObject {

  func flashButtonDidPress(_ title: String)
  func rotateDeviceDidPress()
}

open class TopView: UIView {

  struct Dimensions {
    static let leftOffset: CGFloat = 11
    static let rightOffset: CGFloat = 7
    static let height: CGFloat = 34
  }

  var configuration = ImagePickerConfiguration()

  var currentFlashIndex = 0
  let flashButtonTitles = ["AUTO", "ON", "OFF"]

    open lazy var flashButton: UIButton = { [unowned self] in
        var config = UIButton.Configuration.plain()
        config.image = AssetManager.getImage("AUTO")
        config.title = "AUTO"
        config.imagePadding = 4
        config.baseForegroundColor = UIColor.white
        config.baseBackgroundColor = UIColor.clear
        //config.titleHighlightedColor = UIColor.white // Set the highlighted text color here
        //config.titleFont = self.configuration.flashButton

        let button = UIButton(configuration: config)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.flashButtonDidPress(button)
        }), for: .touchUpInside)
        
        button.contentHorizontalAlignment = .left
        button.accessibilityLabel = "Flash mode is auto"
        button.accessibilityHint = "Double-tap to change flash mode"

        return button
    }()



  open lazy var rotateCamera: UIButton = { [unowned self] in
    let button = UIButton()
    button.accessibilityLabel = ""
    button.accessibilityHint = "Double-tap to rotate camera"
    button.setImage(AssetManager.getImage("cameraIcon"), for: UIControl.State())
    button.addTarget(self, action: #selector(rotateCameraButtonDidPress(_:)), for: .touchUpInside)
    button.imageView?.contentMode = .center

    return button
    }()

  weak var delegate: TopViewDelegate?

  // MARK: - Initializers

  public init(configuration: ImagePickerConfiguration? = nil) {
    if let configuration = configuration {
      self.configuration = configuration
    }
    super.init(frame: .zero)
    configure()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure() {
    var buttons: [UIButton] = [flashButton]

    if configuration.canRotateCamera {
      buttons.append(rotateCamera)
    }

    for button in buttons {
      button.layer.shadowColor = UIColor.black.cgColor
      button.layer.shadowOpacity = 0.5
      button.layer.shadowOffset = CGSize(width: 0, height: 1)
      button.layer.shadowRadius = 1
      button.translatesAutoresizingMaskIntoConstraints = false
      addSubview(button)
    }

    flashButton.isHidden = configuration.flashButtonAlwaysHidden

    setupConstraints()
  }

  // MARK: - Action methods

  @objc func flashButtonDidPress(_ button: UIButton) {
    currentFlashIndex += 1
    currentFlashIndex = currentFlashIndex % flashButtonTitles.count

    switch currentFlashIndex {
    case 1:
      button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), for: UIControl.State())
      button.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), for: .highlighted)

    default:
      button.setTitleColor(UIColor.white, for: UIControl.State())
      button.setTitleColor(UIColor.white, for: .highlighted)
    }

    let newTitle = flashButtonTitles[currentFlashIndex]

    button.setImage(AssetManager.getImage(newTitle), for: UIControl.State())
    button.setTitle(newTitle, for: UIControl.State())
    button.accessibilityLabel = "Flash mode is \(newTitle)"

    delegate?.flashButtonDidPress(newTitle)
  }

  @objc func rotateCameraButtonDidPress(_ button: UIButton) {
    delegate?.rotateDeviceDidPress()
  }
}
