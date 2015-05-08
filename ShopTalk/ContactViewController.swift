import UIKit
import Parse

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
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
    
    self.contactsTableView.hidden = true
  }
  
  override func viewWillAppear(animated: Bool) {
    Conversation.findConversations([self.user!]) {
      (conversations) in
      self.conversations = conversations
      self.contacts = self.user!.contacts
      self.tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return segmentedControl.selectedSegmentIndex == 0 ? conversations.count : contacts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! UITableViewCell
    if segmentedControl.selectedSegmentIndex == 0 {
      var conversation = self.conversations[indexPath.row]
      cell.textLabel?.text = conversation.otherUsers(self.user!).first!.username
      cell.detailTextLabel?.text = conversation.lastMessage?.content
      return cell
    } else {
      var contact = self.contacts[indexPath.row]
      cell.textLabel?.text = contact.username
      cell.detailTextLabel?.text = contact.website
      return cell
    }
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      user?.removeContact(contacts[indexPath.row])
      self.contacts = user!.contacts
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      
    } else if editingStyle == UITableViewCellEditingStyle.Insert {
      
    }
  }

  
  @IBAction func valueChanged(sender: UISegmentedControl) {
    self.tableView.reloadData()
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
      var index = self.tableView.indexPathForSelectedRow()!
      var controller = segue.destinationViewController as! MessagesViewController
      controller.user = user
      
      if segmentedControl.selectedSegmentIndex == 0 {
        controller.conversation = conversations[index.row]
        controller.loadConversation()
      } else {
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