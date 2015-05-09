import UIKit

class MessagesViewController: ApplicationViewController, UITableViewDelegate, UITableViewDataSource {
  
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
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func loadConversation() {
    self.title = conversation!.otherUsers(user!).first!.username
    conversation!.findMessages() {
      (messages) in
      self.messages = messages
   
      if messages.count == 0 {
        return
      }
      
      let paths = map(0..<self.messages.count, {(x) in NSIndexPath(forRow: x, inSection: 0) })
      self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
      self.tableView.reloadData()
      self.scrollMessages(animated: true)
    }
  }
  
  func scrollMessages(animated: Bool = true) {
    if messages.count > 0 {
      let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
      tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: animated)
    }
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let message = self.messages[indexPath.row]
    
    if message.author == user! {
      var cell = tableView.dequeueReusableCellWithIdentifier("MyMessageCell") as! MyMessageTableViewCell
      cell.content.text = message.content
      
      return cell.content.layer.bounds.height
    }
    
    var cell = tableView.dequeueReusableCellWithIdentifier("TheyMessageCell") as! TheyMessageCell
    
    cell.content.text = message.content
    
    return cell.layer.bounds.height
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
    
    var cell = tableView.dequeueReusableCellWithIdentifier("TheyMessageCell") as! TheyMessageCell
    
    cell.content.text = message.content
    
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
      }, completion: { (success) in
        self.scrollMessages()
      }
    )
  }
  
  func keyboardWillHide(notification: NSNotification) {
    let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
      self.bottomConstraint.constant = 0
      
      }, completion: nil)
  }
  
  override func messageArrived(notification: NSNotification) {
    self.conversation?.fetch()
    self.conversation?.lastMessage?.fetch()
    messages.append(self.conversation!.lastMessage!)
    let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)!
    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    self.scrollMessages()
  }
  
  @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
    if let messageBody = messageTextField.text {
      let message = Message.send(user!, body: messageBody, conversation: conversation!)
      messageTextField.text = ""
      messages.append(message)
      let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)!
      self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      self.scrollMessages()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let controller = segue.destinationViewController as! WebsiteViewController
    controller.website = conversation!.otherUsers(user!).first?.website
  }
}
