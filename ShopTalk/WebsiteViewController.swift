import UIKit

class WebsiteViewController: ApplicationViewController, UITextFieldDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var webview: UIWebView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var messageTextField: UITextField!
  
  var website: String?
  var conversation: Conversation?
  var messages : [Message] = []
  var user : User?
  
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var superButton: PlusButton!
  @IBOutlet weak var hiButton: UIButton!
  
  @IBOutlet weak var centerYSuperTable: NSLayoutConstraint!
  
  @IBOutlet weak var superTableBottomXConstraint: NSLayoutConstraint!
  @IBOutlet weak var closeButtonXConstraint: NSLayoutConstraint!
  @IBOutlet weak var hiButtonXConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var superButtonXConstraint: NSLayoutConstraint!
  @IBOutlet weak var superButtonYConstraint: NSLayoutConstraint!
  var areButtonsHidden = true
  
  @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://" + website!)!))
    webview.delegate = self
    self.tableView.delegate = self
    self.tableView.dataSource = self
    messageTextField.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.centerYSuperTable.active = false
    self.view.layoutSubviews()
  }
  
  func loadConversation() {
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
    self.view.layoutSubviews()
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
      self.superTableBottomXConstraint.constant += keyboardSize
      
      if self.superButtonYConstraint.constant < keyboardSize + 100 {
        self.superButtonYConstraint.constant = keyboardSize + 100
        self.view.layoutSubviews()
      }
      
      }, completion: { (success) in
        //        self.scrollMessages()
        //        self.view.layoutSubviews()
      }
    )
  }
  
  func keyboardWillHide(notification: NSNotification) {
    let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
      self.superTableBottomXConstraint.constant = 0
      self.scrollMessages()
      
      self.view.layoutSubviews()
      
      }, completion: nil)
  }
  
  override func messageArrived(notification: NSNotification) {
    self.conversation?.fetch()
    self.conversation?.lastMessage?.fetch()
    messages.append(self.conversation!.lastMessage!)
    let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)!
    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    //    self.scrollMessages()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let messageBody = messageTextField.text {
      let message = Message.send(user!, body: messageBody, conversation: conversation!)
      messageTextField.text = ""
      messages.append(message)
      let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)!
      self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      //      self.scrollMessages()
      self.messageTextField.resignFirstResponder()
      
      return true
    }
    return false
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let controller = segue.destinationViewController as! WebsiteViewController
    controller.website = conversation!.otherUsers(user!).first?.website
    controller.conversation = conversation
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    
  }
  
  @IBAction func hiButtonPressed(sender: UIButton) {
    hiButton.userInteractionEnabled = false
    if self.centerYSuperTable.constant == 0 {
      UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.centerYSuperTable.constant = self.superButtonYConstraint.constant
        self.view.layoutSubviews()
        
        }, completion: {
          (_)in
          self.centerYSuperTable.active = false
          self.toolbarHeightConstraint.constant = 0
          self.tableViewBottomConstraint.constant = 0
          self.view.layoutSubviews()
          self.hiButton.userInteractionEnabled = true
      })
      
    } else {
      self.centerYSuperTable.constant = self.superButtonYConstraint.constant

      self.toolbarHeightConstraint.constant = 44
      self.tableViewBottomConstraint.constant = 44
      self.centerYSuperTable.active = true
      self.view.layoutSubviews()
      
      UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options:  UIViewAnimationOptions.CurveEaseOut, animations: {
        self.centerYSuperTable.constant = 0
        self.view.layoutSubviews()
        
        }, completion: {(_) in self.hiButton.userInteractionEnabled = true })
    }
    
  }
  
  @IBAction func closeButtonPressed(sender: UIButton) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func plusButtonPressed(sender: PlusButton) {
    
    if areButtonsHidden {
      closeButton.hidden = false
      hiButton.hidden = false
      areButtonsHidden = false
      
      UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        
        self.closeButtonXConstraint.constant = -60
        self.hiButtonXConstraint.constant = 60
        self.view.layoutSubviews()
        }, completion: nil)
    } else {
      
      UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.closeButtonXConstraint.constant = 0
        self.hiButtonXConstraint.constant = 0
        self.view.layoutSubviews()
        
        },
        completion: {(_)in
          self.areButtonsHidden = true
          self.closeButton.hidden = true
          self.hiButton.hidden = true
          self.view.layoutSubviews()
          
      })
    }
    
    
    
  }
  
  @IBAction func dragged(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Began:
      let center = sender.locationInView(self.view)
      superButtonXConstraint.constant = self.view.bounds.width - center.x - superButton.bounds.width
      superButtonYConstraint.constant = self.view.bounds.height - center.y - superButton.bounds.height
      //      self.centerYSuperTable.constant = self.superButtonYConstraint.constant
      
    case .Changed:
      let center = sender.locationInView(self.view)
      superButtonXConstraint.constant = self.view.bounds.width - center.x - superButton.bounds.width
      superButtonYConstraint.constant = self.view.bounds.height - center.y - superButton.bounds.height
      //      self.centerYSuperTable.constant = self.superButtonYConstraint.constant
      
    default:
      println("at least one executatble statement")
      //do nothing
    }
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
