import UIKit

@IBDesignable
class PlusButton: UIButton {
  
  @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
    didSet {
      layer.borderColor = borderColor.CGColor
    }
  }
  
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 3.0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
}
