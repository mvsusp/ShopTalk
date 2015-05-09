import UIKit
import Parse

class LogInSignUpViewController: ApplicationViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var newPwd: UITextField!
  @IBOutlet weak var newUsername: UITextField!
  @IBOutlet weak var website: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var pwdTextField: UITextField!
  var user : User?
  var conversations = [Conversation]()
  @IBOutlet weak var loginView: UIView!
  @IBOutlet weak var signupView: UIView!
  
  var logoImage : UIImage?
  var logoImagePicker = UIImagePickerController()
  var frontImage : UIImage?
  var frontImagePicker = UIImagePickerController()
  

  override func viewDidLoad() {
    super.viewDidLoad()
    logoImagePicker.delegate = self
    frontImagePicker.delegate = self
    
    signupView.hidden = true
    
//    if let currentUser = PFUser.currentUser() {
//      presentMainViewController(currentUser.username!)
//    }
  }

  
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
          self.presentMainViewController(user!.username!)
        } else {
          let alertController = UIAlertController(title: "Log in", message: error!.description, preferredStyle: .Alert)
          let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
          alertController.addAction(OKAction)
          self.presentViewController(alertController, animated: true, completion: nil)        }
      }
    }
  }
  
  func presentMainViewController(username: String) {
    var query = PFQuery(className: "User").includeKey("contacts").whereKey("username", equalTo: username)
    query.getFirstObjectInBackgroundWithBlock() {
      (object, error) in
      self.user = object as! User?
       self.performSegueWithIdentifier("login", sender: self)
    }
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
  
  @IBAction func signedUp(sender: UIButton) {
    if newUsername.text == "" || newPwd.text == ""  {
      let alertController = UIAlertController(title: "Sign up", message: "All fields are required", preferredStyle: .Alert)
      let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
      alertController.addAction(OKAction)
      self.presentViewController(alertController, animated: true, completion: nil)
      
    } else {
      let pfUser = PFUser()
      pfUser.username = newUsername.text!
      pfUser.password = newPwd.text!
      
      pfUser.signUpInBackgroundWithBlock {
        (succeeded, error) in
        if error == nil {
          self.user = User.create(self.newUsername.text!)
          self.user?.website = self.website.text
          self.user?.frontImage = self.frontImage
          self.user?.logoImage = self.logoImage
          self.user?.saveInBackground()

          self.performSegueWithIdentifier("login", sender: self)

          
        } else {
//          let errorString = error.userInfo["error"] as NSString
          // Show the errorString somewhere and let the user try again.
        }
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var navigationController = segue.destinationViewController as! UINavigationController
    var controller = navigationController.topViewController as! ContactViewController
    controller.user = self.user
    controller.conversations = conversations
  }
  
  
  @IBAction func logoImagePressed(sender: UIButton) {
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
      logoImagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
      logoImagePicker.allowsEditing = false
      
      self.presentViewController(logoImagePicker, animated: true, completion: nil)
    }
  }
  
  @IBAction func frontImagePressed(sender: UIButton) {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
      frontImagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
      frontImagePicker.allowsEditing = false
      
      self.presentViewController(frontImagePicker, animated: true, completion: nil)
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    self.dismissViewControllerAnimated(true, completion: { () -> Void in
      
    })
    if picker == frontImagePicker {
      frontImage = image
    } else {
      logoImage = image
    }
  }
  
}
