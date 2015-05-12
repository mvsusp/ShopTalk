import UIKit
import Parse

class ContactViewController: ApplicationViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var contactsTableView: UITableView!
  var conversations = [Conversation]()
  var contacts = [User]()
  var brands = [User]()
  var user : User?
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.searchBar.delegate = self
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.contactsTableView.delegate = self
    self.contactsTableView.dataSource = self
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
      
      var existingContacts = self.contacts.map({ $0.username })
      existingContacts.append(self.user!.username)
      User.query()?.whereKey("username", notContainedIn: existingContacts).findObjectsInBackgroundWithBlock() {
        (objects, error) in
        
        self.brands = objects as! [User]
        self.contactsTableView.reloadData()
      }
    }
  }
  
  override func messageArrived(notification: NSNotification) {
    super.messageArrived(notification)
    reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if tableView == contactsTableView {
      return 2
    } else {
      return 1
    }
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if segmentedControl.selectedSegmentIndex == 0 && section == 0 && contacts.count > 0 {
      return "Favorites"
    }
    if segmentedControl.selectedSegmentIndex == 0 && section == 1 && brands.count > 0 {
      return "Brands"
    }
    return nil
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      return conversations.count
    }
    
    if section == 0 {
      return contacts.count
    } else {
      return brands.count
    }
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
      
      var contact = indexPath.section == 0 ? self.contacts[indexPath.row] : self.brands[indexPath.row]
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
    if sender.selectedSegmentIndex == 1 {
      tableView.reloadData()
      contactsTableView.hidden = true
      tableView.hidden = false
    } else if sender.selectedSegmentIndex == 0 {
      contactsTableView.reloadData()
      tableView.hidden = true
      contactsTableView.hidden = false
    } else {
      performSegueWithIdentifier("addSegue", sender: self)
    }
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    self.searchBar.resignFirstResponder()
  }
  
  
  var tempContacts = [User]()
  var tempBrands = [User]()
  func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
    self.tempContacts = self.contacts
    self.tempBrands = self.brands
    
    return true
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText == "" {
      self.contacts = self.tempContacts
      self.brands = self.tempBrands
    } else {
      
      var lowercaseText = searchText.lowercaseString
      self.contacts = self.contacts.filter({
        (t) in
        return t.website.lowercaseString.rangeOfString(lowercaseText) != nil ||
          t.username.lowercaseString.rangeOfString(lowercaseText) != nil
      })
      
      self.brands = self.brands.filter({
        (t) in
        return t.website.lowercaseString.rangeOfString(lowercaseText) != nil ||
          t.username.lowercaseString.rangeOfString(lowercaseText) != nil
      })
    }
    self.contactsTableView.reloadData()
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    self.contacts = self.tempContacts
    self.brands = self.tempBrands
    self.searchBar.text = ""
    self.searchBar.resignFirstResponder()
    self.contactsTableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {

    
    self.performSegueWithIdentifier("search", sender: self)

  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "search" {
      let newBrand = User.create(searchBar.text)
      newBrand.website = searchBar.text
      newBrand.saveInBackground()
      
      let conversation = Conversation.create([user!, newBrand])
      
      let controller = WebsiteViewController()
      controller.conversation = conversation
      controller.website = newBrand.website
      controller.user = user
      
      controller.loadConversation()
    } else if segue.identifier == "addSegue" {
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
      var controller = segue.destinationViewController as! WebsiteViewController
      controller.user = user
      
      if segmentedControl.selectedSegmentIndex == 1 {
        var index = self.tableView.indexPathForSelectedRow()!
        
        controller.conversation = conversations[index.row]
        controller.website = controller.conversation!.otherUsers(user!).first?.website
        
        controller.loadConversation()
      } else {
        var index = self.contactsTableView.indexPathForSelectedRow()!
        ////
        if index.section == 1 {
          
          let brand = self.brands[index.row]
          user!.createContact(brand)
          let conversation = Conversation.create([brand, user!])
          controller.conversation = conversation
          controller.website = brand.website
          controller.loadConversation()
          return
        }
        
        ///
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
  }
}