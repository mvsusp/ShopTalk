import Foundation
import Parse

class Conversation : PFObject, PFSubclassing {
  
  @NSManaged var messages: PFRelation
  @NSManaged var people: [User]
  @NSManaged var lastMessage: Message?
  
  static func parseClassName() -> String {
    return "Conversation"
  }

  class func findConversations(user: PFObject, block: ([Conversation]) -> Void) {
    var query = Conversation.query()!.whereKey("people", containsAllObjectsInArray: [user])
    query.findObjectsInBackgroundWithBlock() {
      (objects, error) in
      var conversations = objects as! [Conversation]
      for conversation in conversations {
        conversation.lastMessage?.fetch()
        conversation.lastMessage?.author.fetch()
      }
      
      block(conversations)
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
