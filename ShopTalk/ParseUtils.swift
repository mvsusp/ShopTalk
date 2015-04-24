import Foundation
import Parse



extension PFUser {
  
  var contacts :String {get{return"contacts"}}
  
  
  func addContact(contact: PFUser){
    self.addObject(contact, forKey: contacts)
  }
}