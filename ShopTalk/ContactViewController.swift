import UIKit
import Parse

class ContactViewController: ApplicationViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var contactsTableView: UITableView!
  var conversations = [Conversation]()
  var contacts = [User]()
  var user : User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.contactsTableView.delegate = self
    self.contactsTableView.dataSource = self
    self.contactsTableView.hidden = true
    
//    var attr = [
//      NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBold", size: 16.0)!
//      ,
//      NSForegroundColorAttributeName : UIColor(red: 21/255.0, green: 202/255.0, blue: 249/255.0, alpha: 1)
//    ]
//    UISegmentedControl.appearance().setTitleTextAttributes(attr, forState: .Normal)
//
//    var attr2 = [
//      NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBold", size: 16.0)!,
//      NSForegroundColorAttributeName : UIColor.whiteColor()
//    ]
//    UISegmentedControl.appearance().setTitleTextAttributes(attr2, forState: .Selected)
//    UISegmentedControl.appearance().tintColor = UIColor(red: 21/255.0, green: 202/255.0, blue: 249/255.0, alpha: 1)

    //
//    let font = UIFont(name: "Helvetica Neue", size: 14)!
//    segmentedControl.setTitleTextAttributes([NSFontAttributeName:font], forState: UIControlState.Normal)
  }
  
  override func viewWillAppear(animated: Bool) {
    reloadData()
  }
  
  func reloadData(){
    Conversation.findConversations([self.user!]) {
      (conversations) in
      self.conversations = conversations
      self.contacts = self.user!.contacts
      self.tableView.reloadData()
      self.contactsTableView.reloadData()
    }
  }

  override func messageArrived(notification: NSNotification) {
    super.messageArrived(notification)
    reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableView == self.tableView ? conversations.count : contacts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.tableView {
      var cell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! UITableViewCell

      var conversation = self.conversations[indexPath.row]
      var contact = conversation.otherUsers(self.user!).first!
      cell.textLabel?.text = contact.username
      cell.detailTextLabel?.text = conversation.lastMessage?.content
      cell.imageView?.layer.cornerRadius = 3
      cell.imageView?.layer.masksToBounds = true
      cell.imageView?.image = contact.logoImage
      return cell
    } else {
      var cell = tableView.dequeueReusableCellWithIdentifier("CompanyCell") as! LogoImageCellTableViewCell

      var contact = self.contacts[indexPath.row]
      cell.textLabel?.text = contact.username
      cell.detailTextLabel?.text = contact.about
      cell.imageView?.layer.cornerRadius = 3
      cell.imageView?.layer.masksToBounds = true
      cell.imageView?.image = contact.logoImage

      return cell
    }
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete && tableView == self.contactsTableView {
      user?.removeContact(contacts[indexPath.row])
      self.contacts = user!.contacts
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      
    } else if editingStyle == UITableViewCellEditingStyle.Insert {
      
    }
  }

  
  @IBAction func valueChanged(sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      tableView.reloadData()
      contactsTableView.hidden = true
      tableView.hidden = false
    } else if sender.selectedSegmentIndex == 1{
      contactsTableView.reloadData()
      tableView.hidden = true
      contactsTableView.hidden = false
    } else {
      performSegueWithIdentifier("addSegue", sender: self)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "addSegue" {
      var controller = segue.destinationViewController as! NewModalViewController
      controller.user = self.user
      controller.mainController = self
      
      var existingContacts = contacts.map({ $0.username })
      existingContacts.append(user!.username)
      User.query()?.whereKey("username", notContainedIn: existingContacts).findObjectsInBackgroundWithBlock() {
        (objects, error) in
        
        controller.contacts = objects as! [User]
        controller.allContactsTableview.reloadData()
      }
    } else if true {
      var controller = segue.destinationViewController as! WebsiteViewController
      controller.user = user

      
      if segmentedControl.selectedSegmentIndex == 0 {
        var index = self.tableView.indexPathForSelectedRow()!
        controller.conversation = conversations[index.row]
        controller.website = controller.conversation!.otherUsers(user!).first?.website

        controller.loadConversation()
      } else {
        var index = self.contactsTableView.indexPathForSelectedRow()!
        
        let people = [self.user!, self.contacts[index.row]]
        Conversation.findConversations( people, block: {
          (conversations) in
          if conversations.count == 0 {
            controller.conversation = Conversation.create(people)
          } else {
            controller.conversation = conversations.last!
          }
          controller.website = controller.conversation!.otherUsers(controller.user!).first?.website
          controller.webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://" + controller.website!)!))

          controller.loadConversation()
        })
      }
    
    }
    
    else {
      var controller = segue.destinationViewController as! MessagesViewController
      controller.user = user
      
      if segmentedControl.selectedSegmentIndex == 0 {
        var index = self.tableView.indexPathForSelectedRow()!
        controller.conversation = conversations[index.row]
        controller.loadConversation()
      } else {
        var index = self.contactsTableView.indexPathForSelectedRow()!

        let people = [self.user!, self.contacts[index.row]]
        Conversation.findConversations( people, block: {
          (conversations) in
          if conversations.count == 0 {
            controller.conversation = Conversation.create(people)
          } else {
            controller.conversation = conversations.last!
          }
          controller.loadConversation()
        })
      }
    }
  }
}