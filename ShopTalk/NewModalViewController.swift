import UIKit

class NewModalViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var allContactsTableview: UITableView!
  var contacts = [User]()
  var user: User?
  var mainController: ContactViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    allContactsTableview.delegate = self
    allContactsTableview.dataSource = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    user!.createContact(contacts[indexPath.row])
    self.dismissViewControllerAnimated(true, completion: {
      self.mainController?.contacts = self.user!.contacts
      self.mainController?.tableView.reloadData()
    })
  }
  
  
  @IBAction func dismissModal(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: {})
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contacts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("addContactCell") as! UITableViewCell
      var user = self.contacts[indexPath.row]
      cell.textLabel?.text = user.username
      cell.detailTextLabel?.text = user.website
      return cell
  }
  
}
