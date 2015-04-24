import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var conversation : Conversation?
  var user : User?
  var messages : [Message] = []
  
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var messageTextField: UITextField!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.title = conversation!.otherUsers(user!).first!.username
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    
    conversation!.messages.query()?.orderByAscending("createdAt").findObjectsInBackgroundWithBlock() {
      (objects, error) in
      self.messages = objects as! [Message]
      self.messages.append(self.conversation!.lastMessage!)
      self.tableView.reloadData()
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let message = self.messages[indexPath.row]
    
    if message.author == user! {
      var cell = tableView.dequeueReusableCellWithIdentifier("MyMessageCell") as! MyMessageTableViewCell
      
      cell.content.text = message.content
      
      return cell
    }
    
    var cell = tableView.dequeueReusableCellWithIdentifier("TheyMessageCell") as! UITableViewCell
    
    cell.textLabel!.text = message.content
    
    return cell
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func keyboardWillShow(notification: NSNotification) {
    let value = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
    let keyboardSize = value.CGRectValue().size.height
    let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
    
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
      self.bottomConstraint.constant += keyboardSize
      
      }, completion: nil)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
      self.bottomConstraint.constant = 0
      
      }, completion: nil)
  }

  
  @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
    messageTextField.resignFirstResponder()
    if let messageBody = messageTextField.text {
      let message = Message.send(user!, body: messageBody, conversation: conversation!)
        messageTextField.text = ""
        messages.append(message)
        self.tableView.reloadData()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
  
}
