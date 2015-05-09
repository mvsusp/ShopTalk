import Foundation
import Parse

class User : PFObject, PFSubclassing {
  
  @NSManaged var contacts: [User]
  @NSManaged var username: String
  @NSManaged var website: String
  @NSManaged var frontImageData: NSData?
  @NSManaged var logoImageData: NSData?
  
  var frontImage: UIImage? {
    get {
      if frontImageData != nil {
        return UIImage(data: frontImageData!)
      }
      return nil
    }
    
    set(image) {
      if image == nil {
        return
      }
      
      let data = UIImageJPEGRepresentation(image!, 0.5)
      frontImageData = data
    }
  }
  
  var logoImage: UIImage? {
    get {
      if logoImageData != nil {
        return UIImage(data: logoImageData!)
      }
      return nil
    }
    
    set(image) {
      if image == nil {
        return
      }
      
      let data = UIImageJPEGRepresentation(image!, 0.5)
      logoImageData = data
    }
  }
  
  static func parseClassName() -> String {
    return "User"
  }
  
  static func find(username: String, block: (User) -> Void) {
    query()?.whereKey("username", equalTo: username).getFirstObjectInBackgroundWithBlock() {
      (object, error) in
      let user = object as! User
      block(user)
    }
  }
  
  static func create(username: String) -> User {
    var user = User()
    user.username = username
    user.save()
    
    let currentInstallation = PFInstallation.currentInstallation()
    currentInstallation.addUniqueObject("\(user.username)", forKey: "channels")
    currentInstallation.saveInBackground()
    
    return user
  }
 
  func removeContact(contact: User) {
    self.removeObject(contact, forKey: "contacts")
    self.save()
    
    contact.removeObject(self, forKey: "contacts")
    contact.saveInBackground()
  }
  
  func createContact(contact: User) {
    if contact.isDirty() {
      contact.save()
    }
    
    self.addObject(contact, forKey: "contacts")
    self.save()
    
    contact.addObject(self, forKey: "contacts")
    contact.saveInBackground()
  }
}