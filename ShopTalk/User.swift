import Foundation
import Parse

class User : PFObject, PFSubclassing {
  
  @NSManaged var contacts: [User]
  @NSManaged var username: String
  @NSManaged var website: String
  
  static func parseClassName() -> String {
    return "User"
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