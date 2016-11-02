import UIKit

/// A UIView subclass which draws a horizontal line of drop-shadow above and below the view's
/// bounds. The view should be given a height of 0 when added to a view hierarchy.
class ShadowLineView: UIView {
  fileprivate let shadowView = ShadowView()

  /// The opacity of the drop-shadow line, defaults to 0.
  var shadowOpacity = Float() { didSet { shadowView.shadowOpacity = shadowOpacity } }
  /// The color of the drop-shadow. defaults to black.
  var shadowColor = UIColor.black { didSet { shadowView.shadowColor = shadowColor } }
  /// Whether to display the drop-shadow or not, defaults to false.
  var enableShadow = false { didSet { update() } }
  /// The size of the shadow. This extends above and beneath the view. Defaults to 0.
  var shadowSize = CGFloat() { didSet { update() } }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }

  fileprivate func setup() {
    addSubview(shadowView)
    shadowView.autoresizingMask = [.flexibleWidth]
  }

  fileprivate func update() {
    // Pass on our enabled state to the shadow view.
    shadowView.enableShadow = enableShadow
    // Adjust the positioning of the shadow view so that it is centered in our bounds, but has a
    // height of shadow size, and a width which is 2*shadow size larger.
    shadowView.frame = bounds.insetBy(dx: -shadowSize, dy: -shadowSize/2)
    // Make the shadow radius be half of the requested size. As the shadow view itself is half the
    // size of the requested shadow size once you add this value the shadow will be the correct
    // height.
    shadowView.shadowRadius = shadowSize/2
  }
}
