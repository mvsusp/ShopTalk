import UIKit
import Parse

class LogInSignUpViewController: UIViewController {
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var pwdTextField: UITextField!
  var user : User?
  var conversations = [Conversation]()
  @IBOutlet weak var loginView: UIView!
  @IBOutlet weak var signupView: UIView!
  
  @IBAction func logInPressed(sender: UIButton) {
    if usernameTextField.text == "" || pwdTextField.text == "" {
      let alertController = UIAlertController(title: "Log in", message: "All fields are required", preferredStyle: .Alert)
      let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
      alertController.addAction(OKAction)
      self.presentViewController(alertController, animated: true, completion: nil)
      
    } else {
      PFUser.logInWithUsernameInBackground(usernameTextField.text, password: pwdTextField.text) {
        (user: PFUser?, error: NSError?) -> Void in
        if user != nil {
          var query = PFQuery(className: "User").whereKey("username", equalTo: user!.username!)
          query.getFirstObjectInBackgroundWithBlock() {
            (object, error) in
            self.user = object as! User?
            
            Conversation.findConversations(self.user!) {
              (conversations) in
              self.conversations = conversations
              self.performSegueWithIdentifier("login", sender: self)
            }
          }
        } else {
          let alertController = UIAlertController(title: "Log in", message: error!.description, preferredStyle: .Alert)
          let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
          alertController.addAction(OKAction)
          self.presentViewController(alertController, animated: true, completion: nil)        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    signupView.hidden = true
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func segmentSwitched(sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      loginView.hidden = false
      signupView.hidden = true
    } else {
      loginView.hidden = true
      signupView.hidden = false
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var navigationController = segue.destinationViewController as! UINavigationController
    var controller = navigationController.topViewController as! ContactViewController
    controller.user = user
    controller.conversations = conversations
  }

  
}
