import UIKit
import GooglePlaces

enum PlaceProperty: Int {
  case placeID
  case coordinate
  case openNowStatus
  case phoneNumber
  case website
  case formattedAddress
  case rating
  case priceLevel
  case types
  case attribution

  static func numberOfProperties() -> Int {
    return 10
  }
}

/// The data source and delegate for the Place Detail |UITableView|. Beyond just displaying the
/// details of the place, this class also manages the floating section title containing the place
/// name and takes into account the presence of the back button if it's visible.
class PlaceDetailTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
  // MARK: - Properties
  fileprivate let place: GMSPlace
  fileprivate let blueCellIdentifier = "BlueCellIdentifier"
  fileprivate let extensionConstraint: NSLayoutConstraint
  fileprivate let noneText = NSLocalizedString("PlaceDetails.MissingValue",
                                           comment: "The value of a property which is missing")
  // Additional margin padding to use during layout. This is 0 for iOS versions 8.0 and above, while
  // on iOS 7 this needs to be hardcoded to 8 to ensure the correct layout.
  fileprivate let additionalMarginPadding: CGFloat = {
    if #available(iOS 8.0, *) {
      return 0
    } else {
      return 8
    }
  }()

  var offsetNavigationTitle = false

  // MARK: Init/Deinit

  /// Create a |PlaceDetailTableViewDataSource| with the specified |GMSPlace| and constraint.
  ///
  /// - parameter place The |GMSPlace| to show details for.
  /// - parameter extensionConstraint The |NSLayoutConstraint| to update when scrolling so that
  /// the header view shrinks/grows to fill the gap between the map/photo and the details.
  init(place: GMSPlace, extensionConstraint: NSLayoutConstraint) {
    self.place = place
    self.extensionConstraint = extensionConstraint
  }

  // MARK: - Public Methods

  /// Configure the |UITableView| we will be providing results for.
  ///
  /// - parameter tableView The table view to configure.
  func configure(_ tableView: UITableView) {
    // Register the |UITableViewCell|s.
    tableView.register(PlaceAttributeCell.nib,
                          forCellReuseIdentifier: PlaceAttributeCell.reuseIdentifier)
    tableView.register(PlaceNameHeader.nib,
                          forHeaderFooterViewReuseIdentifier: PlaceNameHeader.reuseIdentifier)
    tableView.register(UITableViewCell.self,
                            forCellReuseIdentifier: blueCellIdentifier)

    // Configure some other properties.
    tableView.estimatedRowHeight = 44
    tableView.estimatedSectionHeaderHeight = 44
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    tableView.separatorStyle = .none
  }

  func updateNavigationTextOffset(_ tableView: UITableView) {
    // Grab the header.
    if let header = tableView.headerView(forSection: 0) as? PlaceNameHeader {
      // Check to see if we should be offsetting the navigation title.
      if offsetNavigationTitle {
        // If so offset it by at most 36 pixels, relative to how much we've scrolled past 160px.
        let offset = max(0, min(36, tableView.contentOffset.y - 160))
        header.leadingConstraint.constant = offset + additionalMarginPadding
      } else {
        // Otherwise don't offset.
        header.leadingConstraint.constant = additionalMarginPadding
      }
    }
  }

  // MARK: - UITableView DataSource/Delegate

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return PlaceProperty.numberOfProperties() + 1
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // The first cell is special, this is a small blue spacer we use to pad out the place name
    // header.
    if (indexPath as NSIndexPath).item == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: blueCellIdentifier,
                                                             for: indexPath)
      cell.backgroundColor = UIColor.white
      cell.selectionStyle = .none
      return cell
    }

    // For all the other cells use the same class.

    let untyped = tableView.dequeueReusableCell(withIdentifier: PlaceAttributeCell.reuseIdentifier,
                                                              for: indexPath)
    let cell = untyped as! PlaceAttributeCell

    // Disable selection.
    cell.selectionStyle = .none

    // Set the relevant values.
    if let propertyType = PlaceProperty(rawValue: (indexPath as NSIndexPath).item - 1) {
      cell.propertyName.text = propertyType.localizedDescription()
      cell.propertyIcon.image = propertyType.icon()

      switch propertyType {
      case .placeID:
        cell.propertyValue.text = place.placeID
      case .coordinate:
        let format = NSLocalizedString("Places.Property.Coordinate.Format",
                                       comment: "The format string for latitude, longitude")
        cell.propertyValue.text = String(format: format, place.coordinate.latitude,
                                         place.coordinate.longitude)
      case .openNowStatus:
        cell.propertyValue.text = textForOpenNowStatus(place.openNowStatus)
      case .phoneNumber:
        cell.propertyValue.text = place.phoneNumber ?? noneText
      case .website:
        cell.propertyValue.text = place.website?.absoluteString ?? noneText
      case .formattedAddress:
        cell.propertyValue.text = place.formattedAddress ?? noneText
      case .rating:
        let rating = place.rating
        // As specified in the documentation for |GMSPlace|, a rating of 0.0 signifies that there
        // have not yet been any ratings for this location.
        if rating > 0 {
          cell.propertyValue.text = "\(rating)"
        } else {
          cell.propertyValue.text = noneText
        }
      case .priceLevel:
        cell.propertyValue.text = textForPriceLevel(place.priceLevel)
      case .types:
        cell.propertyValue.text = place.types.joined(separator: ", ")
      case .attribution:
        if let attributions = place.attributions {
          cell.propertyValue.attributedText = attributions
        } else {
          cell.propertyValue.text = noneText
        }
      }
    } else {
      fatalError("Unexpected row index")
    }

    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return place.name
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: PlaceNameHeader.reuseIdentifier)
  }

  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    // Our first cell has a fixed height, all the rest are automatic.
    if (indexPath as NSIndexPath).item == 0 {
      return 20
    }
    else {
      if #available(iOS 8.0, *) {
        return UITableViewAutomaticDimension
      } else {
        // This means that on iOS 7 we only get the first line of text.
        return 55
      }
    }
  }

  /// Only needed for iOS 7, explodes if this is not provided.
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if #available(iOS 8.0, *) {
      return UITableViewAutomaticDimension
    } else {
      // This means that on iOS 7 we only get the first line of text.
      return 65
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Update the extensionConstraint and the navigation title offset when the tableView scrolls.
    if let tableView = scrollView as? UITableView {
      extensionConstraint.constant = max(0, -scrollView.contentOffset.y)

      updateNavigationTextOffset(tableView)
    }
  }

  // MARK: - Utilities

  /// Return the appropriate text string for the specified |GMSPlacesOpenNowStatus|.
  fileprivate func textForOpenNowStatus(_ status: GMSPlacesOpenNowStatus) -> String {
    switch status {
    case .no: return NSLocalizedString("Places.OpenNow.No",
                                       comment: "Closed/Open state for a closed location")
    case .yes: return NSLocalizedString("Places.OpenNow.Yes",
                                        comment: "Closed/Open state for an open location")
    case .unknown: return NSLocalizedString("Places.OpenNow.Unknown",
                                            comment: "Closed/Open state for when it is unknown")
    }
  }

  /// Return the appropriate text string for the specified |GMSPlacesPriceLevel|.
  fileprivate func textForPriceLevel(_ priceLevel: GMSPlacesPriceLevel) -> String {
    switch priceLevel {
    case .free: return NSLocalizedString("Places.PriceLevel.Free",
                                         comment: "Relative cost for a free location")
    case .cheap: return NSLocalizedString("Places.PriceLevel.Cheap",
                                          comment: "Relative cost for a cheap location")
    case .medium: return NSLocalizedString("Places.PriceLevel.Medium",
                                           comment: "Relative cost for a medium cost location")
    case .high: return NSLocalizedString("Places.PriceLevel.High",
                                         comment: "Relative cost for a high cost location")
    case .expensive: return NSLocalizedString("Places.PriceLevel.Expensive",
                                              comment: "Relative cost for an expensive location")
    case .unknown: return NSLocalizedString("Places.PriceLevel.Unknown",
                                            comment: "Relative cost for when it is unknown")
    }
  }
}

extension PlaceProperty {
  func localizedDescription() -> String {
    switch self {
    case .placeID:
      return NSLocalizedString("Places.Property.PlaceID",
                               comment: "Name for the Place ID property")
    case .coordinate:
      return NSLocalizedString("Places.Property.Coordinate",
                               comment: "Name for the Coordinate property")
    case .openNowStatus:
      return NSLocalizedString("Places.Property.OpenNowStatus",
                               comment: "Name for the Open now status property")
    case .phoneNumber:
      return NSLocalizedString("Places.Property.PhoneNumber",
                               comment: "Name for the Phone number property")
    case .website:
      return NSLocalizedString("Places.Property.Website",
                               comment: "Name for the Website property")
    case .formattedAddress:
      return NSLocalizedString("Places.Property.FormattedAddress",
                               comment: "Name for the Formatted address property")
    case .rating:
      return NSLocalizedString("Places.Property.Rating",
                               comment: "Name for the Rating property")
    case .priceLevel:
      return NSLocalizedString("Places.Property.PriceLevel",
                               comment: "Name for the Price level property")
    case .types:
      return NSLocalizedString("Places.Property.Types",
                               comment: "Name for the Types property")
    case .attribution:
      return NSLocalizedString("Places.Property.Attributions",
                               comment: "Name for the Attributions property")
    }
  }

  func icon() -> UIImage? {
    switch self {
    case .placeID:
      return UIImage(named: "place_id")
    case .coordinate:
      return UIImage(named: "coordinate")
    case .openNowStatus:
      return UIImage(named: "open_now")
    case .phoneNumber:
      return UIImage(named: "phone_number")
    case .website:
      return UIImage(named: "website")
    case .formattedAddress:
      return UIImage(named: "address")
    case .rating:
      return UIImage(named: "rating")
    case .priceLevel:
      return UIImage(named: "price_level")
    case .types:
      return UIImage(named: "types")
    case .attribution:
      return UIImage(named: "attribution")
    }
  }
}
