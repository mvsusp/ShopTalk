import UIKit
import Parse

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  var conversations = [Conversation]()
  var user : User?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    //    self.tableView.reloadData()
    //
    //    PFQuery(className: "User").getObjectInBackgroundWithId("NFh27ywcnZ") {
    //      (user: PFObject?, error: NSError?) in
    //      if error == nil && user != nil{
    //        self.user = user as? User
    //
    ////        var alexis = self.user!.contacts.first!
    ////        var people = [self.user!, alexis]
    ////        var conversation = Conversation.create(people)
    ////        var message = Message.send(alexis, body: "hey ho", conversation: conversation)
    //
    //        Conversation.findConversations(user!) {
    //          (conversations) in
    //          self.conversations = conversations
    //          self.tableView.reloadData()
    //        }
    //      }
    //    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversations.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! UITableViewCell
    var conversation = self.conversations[indexPath.row]
    cell.textLabel?.text = conversation.otherUsers(self.user!).first!.username
    cell.detailTextLabel?.text = conversation.lastMessage!.content
    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var index = self.tableView.indexPathForSelectedRow()!
    var controller = segue.destinationViewController as! MessagesViewController
    controller.conversation = conversations[index.row]
    controller.user = user
  }
}

