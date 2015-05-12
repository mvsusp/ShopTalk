import Foundation
import Parse

class User : PFObject, PFSubclassing {
  
  @NSManaged var contacts: [User]
  @NSManaged var username: String
  @NSManaged var about: String
  @NSManaged var website: String
  @NSManaged var frontImageData: NSData?
  @NSManaged var logoImageData: NSData?
  
  var frontImage: UIImage? {
    get {
      if frontImageData != nil {
        
        var image = UIImage(data: frontImageData!)
        
        let newSize = CGSizeMake(20, 20)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image?.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
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
        
        var image = UIImage(data: logoImageData!)
        
        let newSize = CGSizeMake(50, 50)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image?.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
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
    currentInstallation.addUniqueObject("\(user.objectId!)", forKey: "channels")
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