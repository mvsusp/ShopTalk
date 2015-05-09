import UIKit
import Parse

let MessageArrivedNotification = "MessageArrived"

class ApplicationViewController: UIViewController {
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "messageArrived:", name: MessageArrivedNotification, object: nil)
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  func messageArrived(notification: NSNotification) {
    PFPush.handlePush(notification.userInfo)
  }
}
