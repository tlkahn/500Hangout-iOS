import UIKit
import GoogleMaps
import GooglePlaces
import XLForm

/// A view controller which displays details about a specified |GMSPlace|.
@objc open class PlaceDetailViewController: UIViewController {
  fileprivate let place: GMSPlace
  @IBOutlet fileprivate weak var photoView: UIImageView!
  @IBOutlet fileprivate weak var mapView: GMSMapView!
  @IBOutlet var tableBackgroundView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var statusBarShadow: ShadowLineView!
  @IBOutlet weak var navigationBar: UIView!
  @IBOutlet weak var headerHeightExtension: UIView!
  @IBOutlet weak var headerHeightExtensionConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var confirmBtn: UIButton!
  fileprivate lazy var placesClient = { GMSPlacesClient.shared() } ()
  fileprivate static let photoSize = CGSize(width: 450, height: 300)
  fileprivate var tableDataSource: PlaceDetailTableViewDataSource!
    
  @objc init(place: GMSPlace) {
    self.place = place
    super.init(nibName: String(describing: type(of: self)), bundle: nil)
  }
  
  @IBAction func confirmBtnTapped(_ sender: AnyObject) {
    print("confirmed")
    let prevVC: NativeEventFormViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! NativeEventFormViewController;
    prevVC.locationRow.value = place
//    prevVC.locationRow.value = place.formattedAddress // (String(format: "%f,%f", place.coordinate.latitude, place.coordinate.longitude)) //XLFormOptionsObject(value: 0, displayText: (String(format: "%f,%f", place.coordinate.latitude, place.coordinate.longitude)))
    self.navigationController?.popViewController(animated: true)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    // Configure the table
    tableDataSource = PlaceDetailTableViewDataSource(place: place,
                                            extensionConstraint: headerHeightExtensionConstraint)
    tableView.backgroundView = tableBackgroundView
    tableView.dataSource = tableDataSource
    tableView.delegate = tableDataSource
    tableDataSource.configure(tableView)

    // Configure the UI elements
    lookupPhoto()
    configureMap()
    configureBars()

  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if #available(iOS 8.0, *) {
      updateNavigationBarState(traitCollection)
      updateStatusBarState()
    } else {
      tableDataSource.offsetNavigationTitle = true
    }
  }

  @available(iOS 8.0, *)
  override open func willTransition(
    to newCollection: UITraitCollection,
    with coordinator: UIViewControllerTransitionCoordinator) {

    super.willTransition(to: newCollection, with: coordinator)

    updateNavigationBarState(newCollection)
  }

  @available(iOS 8.0, *)
  override open func viewWillTransition(
    to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    super.viewWillTransition(to: size, with: coordinator)

    updateStatusBarState()
  }

  fileprivate func lookupPhoto() {
    // Lookup the photos associated with this place.
    placesClient.lookUpPhotos(forPlaceID: place.placeID) { (metadata, error) in
      // Handle the result if it was successful.
      if let metadata = metadata {
        // Check to see if any photos were found.
        if !metadata.results.isEmpty {
          // If there were load the first one.
          self.loadPhoto(metadata.results[0])
        } else {
          NSLog("No photos were found")
        }
      } else if error != nil {
        NSLog("An error occured while looking up the photos: \(error)")
      } else {
        fatalError("An unexpected error occured")
      }
    }
  }

  fileprivate func loadPhoto(_ photo: GMSPlacePhotoMetadata) {
    // Load the specified photo.
    placesClient.loadPlacePhoto(photo, constrainedTo: PlaceDetailViewController.photoSize,
                                scale: view.window?.screen.scale ?? 1) { (image, error) in
      // Handle the result if it was successful.
      if let image = image {
        self.photoView.image = image
        self.photoView.removeConstraint(self.photoWidthConstraint)
      } else if error != nil {
        NSLog("An error occured while loading the first photo: \(error)")
      } else {
        fatalError("An unexpected error occured")
      }
    }
  }

  fileprivate func configureMap() {
    // Place a marker on the map and center it on the desired coordinates.
    let marker = GMSMarker(position: place.coordinate)
    marker.map = mapView
    mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0,
                                       viewingAngle: 0)
    mapView.isUserInteractionEnabled = false
  }

  fileprivate func configureBars() {
    // Configure the drop-shadow we display under the status bar.
    statusBarShadow.enableShadow = false
    statusBarShadow.shadowOpacity = 1
    statusBarShadow.shadowSize = 80

    // Add a constraint to the top of the navigation bar so that it respects the top layout guide.
    view.addConstraint(NSLayoutConstraint(item: navigationBar, attribute: .top, relatedBy: .equal,
      toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))

    // Set the color of the hight extension view.
    headerHeightExtension.backgroundColor = UIColor.init(red: 249/255.0, green: 102/255.0, blue: 92/255.0, alpha: 1)
  }

  @available(iOS 8.0, *)
  fileprivate func updateNavigationBarState(_ traitCollection: UITraitCollection) {
    // Hide the navigation bar if we have enough space to be split-screen.
//    let isNavigationBarHidden = traitCollection.horizontalSizeClass == .Regular
//    navigationBar.hidden = isNavigationBarHidden
//    tableDataSource.offsetNavigationTitle = !isNavigationBarHidden
//    tableDataSource.updateNavigationTextOffset(tableView)
    navigationBar.isHidden = true
  }

  @available(iOS 8.0, *)
  fileprivate func updateStatusBarState() {
    // Hide the shadow if we are not right against the status bar.
    let hasMargin = insetViewController?.hasMargin ?? false
    statusBarShadow.isHidden = hasMargin
  }

  @IBAction func backButtonTapped() {
    splitPaneViewController?.popViewController()
  }
}
