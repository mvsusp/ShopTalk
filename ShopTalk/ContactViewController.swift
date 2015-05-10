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
      cell.textLabel?.text = conversation.otherUsers(self.user!).first!.username
      cell.detailTextLabel?.text = conversation.lastMessage?.content
      return cell
    } else {
      var cell = tableView.dequeueReusableCellWithIdentifier("CompanyCell") as! LogoImageCellTableViewCell

      var contact = self.contacts[indexPath.row]
      cell.logoImageView.image = contact.logoImage
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
    } else {
      contactsTableView.reloadData()
      tableView.hidden = true
      contactsTableView.hidden = false
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
    } else {
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