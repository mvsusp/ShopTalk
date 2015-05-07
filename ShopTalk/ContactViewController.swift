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
    self.contacts = self.user!.contacts
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.contactsTableView.hidden = true
//    self.contactsTableView.delegate = self
//    self.contactsTableView.dataSource = self
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
      cell.detailTextLabel?.text = conversation.lastMessage!.content
      return cell
    } else {
      var contact = self.contacts[indexPath.row]
      cell.textLabel?.text = contact.username
      cell.detailTextLabel?.text = contact.website
      return cell
    }
  }
  
  @IBAction func valueChanged(sender: UISegmentedControl) {
    self.tableView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "addSegue" {
      
    } else {
      var index = self.tableView.indexPathForSelectedRow()!
      var controller = segue.destinationViewController as! MessagesViewController
      controller.conversation = conversations[index.row]
      controller.user = user
    }
  }
}