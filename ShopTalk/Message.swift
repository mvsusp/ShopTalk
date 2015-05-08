import Foundation
import Parse

class Message : PFObject, PFSubclassing {
  
  @NSManaged var author: User
  @NSManaged var content: String
  
  
  static func parseClassName() -> String {
    return "Message"
  }
  
  class func send(author: User, body: String, conversation: Conversation) -> Message {
    var message = Message()
    message.content = body
    message.author = author
    message.saveInBackgroundWithBlock() {
      (success) in
      conversation.addMessage(message)
    }
    
    return message
  }
}