import UIKit

/// Simple placeholder view controller, will be replaced with the real deal in a later CL.
class BackgroundViewController: UIViewController {
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .default
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.white
  }
}
