import Foundation
import Parse

class Conversation : PFObject, PFSubclassing {
  
  @NSManaged private var messages: PFRelation
  @NSManaged var people: [User]
  @NSManaged var lastMessage: Message?
  
  static func parseClassName() -> String {
    return "Conversation"
  }

  class func findConversations(users: [User], block: ([Conversation]) -> Void) {
    var query = Conversation.query()!.whereKey("people", containsAllObjectsInArray: users)
    query.findObjectsInBackgroundWithBlock() {
      (objects, error) in
      var conversations = objects as! [Conversation]
      for conversation in conversations {
        if let message = conversation.lastMessage {
          message.fetch()
          message.author.fetch()
        }
      }
      
      block(conversations)
    }
  }
  
  func findMessages(block: ([Message]) -> Void) {
    if lastMessage == nil {
      block([])
    } else {
      messages.query()?.orderByAscending("createdAt").findObjectsInBackgroundWithBlock() {
        (objects, error) in
        var foundMessages = objects as! [Message]
        foundMessages.append(self.lastMessage!)
        block(foundMessages)
      }
    }
  }
  
  func otherUsers(user: User) -> [User] {
    self.fetchIfNeeded()
    var others = people.filter({(p) in p != user})
    for other in others {
      other.fetchIfNeeded()
    }
    return others
  }
  
  func isEmpty() -> Bool {
    return lastMessage == nil
  }
  
  func addMessage(message: Message) {
    if !isEmpty() {
      messages.addObject(lastMessage!)
    }
    lastMessage = message
    saveInBackground()
  }
  
  class func create(people: [User]) -> Conversation {
    var conversation = Conversation()
    conversation.people = people
    conversation.save()
    return conversation
  }
}
