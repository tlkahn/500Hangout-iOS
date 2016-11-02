import Foundation

/// A small class for managing the lifecycle of a NSNotificationCenter registration. When the class
/// is deinited it will automatically unregister from the NSNotificationCenter.
class NotificationObserver<T: AnyObject>: NSObject {
  fileprivate weak var target: T?
  fileprivate let action: (T) -> (Notification) -> Void

  /// Create a new NotificationObserver with the specified notification name, target and action. The
  /// method action on target will be called with a NSNotification object anytime a notification
  /// is fired.
  ///
  /// The target is be weakly referenced and therefore instances of this class can safely be
  /// stored in instance variables, and do not need to be nilled out.
  ///
  /// - parameter name The name of the notification to listen for.
  /// - parameter target The object to call the method on whenever the notification is posted.
  /// - parameter action The method to call.
  init(name: String, target: T, action: @escaping (T) -> (Notification) -> Void) {
    self.target = target
    self.action = action

    super.init()

    NotificationCenter.default.addObserver(self, selector: #selector(NotificationObserver.notificationFired(_:)),
                                                     name: NSNotification.Name(rawValue: name), object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func notificationFired(_ notification: Notification) {
    guard let target = target else {
      // May as well deregister from notifications if our target has gone away.
      NotificationCenter.default.removeObserver(self)
      return
    }

    action(target)(notification)
  }
}
