import UIKit

/// A simple UIView subclass which renders a configurable drop-shadow. The view itself is
/// transparent and only shows the drop-shadow. The drop-shadow draws the same size as the frame of
/// the view, and can take an optional corner radius into account when calculating the effect.
class ShadowView: UIView {
  /// The blur radius of the drop-shadow, defaults to 0.
  var shadowRadius = CGFloat() { didSet { update() } }
  /// The opacity of the drop-shadow, defaults to 0.
  var shadowOpacity = Float() { didSet { update() } }
  /// The x,y offset of the drop-shadow from being cast straight down.
  var shadowOffset = CGSize.zero { didSet { update() } }
  /// The color of the drop-shadow, defaults to black.
  var shadowColor = UIColor.black { didSet { update() } }
  /// Whether to display the shadow, defaults to false.
  var enableShadow = false { didSet { update() } }
  /// The corner radius to take into account when casting the shadow, defaults to 0.
  var cornerRadius = CGFloat() { didSet { update() } }

  override var frame: CGRect {
    didSet(oldFrame) {
      // Check to see if the size of the frame has changed, if it has then we need to recalculate
      // the shadow.
      if oldFrame.size != frame.size {
        update()
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }

  fileprivate func setup() {
    // Configure the view
    backgroundColor = UIColor.clear
    isOpaque = false
    isHidden = true

    // Enable rasterization on the layer, this will improve the performance of shadow rendering.
    layer.shouldRasterize = true
  }

  fileprivate func update() {
    isHidden = !enableShadow

    if enableShadow {
      // Configure the layer properties.
      layer.shadowRadius = shadowRadius
      layer.shadowOffset = shadowOffset
      layer.shadowOpacity = shadowOpacity
      layer.shadowColor = shadowColor.cgColor

      // Set a shadow path as an optimization, this significantly improves shadow performance.
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    } else {
      // Disable the shadow.
      layer.shadowRadius = 0
      layer.shadowOpacity = 0
    }
  }
}
