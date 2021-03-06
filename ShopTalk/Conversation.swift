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
  
  class func destroyAll(user: User) {
    let query = self.query()!.whereKey("people", containsAllObjectsInArray: [user])
    query.findObjectsInBackgroundWithBlock() {
      (objects, error) in
      for object in objects as! [Conversation]  {
        object.findMessages({(messages) in
          for message in messages {
            message.deleteInBackground()
          }
        
        })
        object.deleteInBackground()
      }
    }
  }
  
  func otherUsers(user: User) -> [User] {
    self.fetchIfNeeded()
    var others = people.filter({(p) in p.objectId != user.objectId})
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
    saveInBackgroundWithBlock() {
      (success) in
      let push = PFPush()
      let channels = self.otherUsers(message.author).map({$0.objectId!})
      push.setChannels(channels)
      
      let data = [
        "alert" : "\(message.author.username):\n\(message.content)",
        "badge" : "Increment",
        "content" : message.content,
        "author" : message.author
      ]
      
      push.setData(data)
      push.sendPushInBackground()
    }
  }
  
  class func create(people: [User]) -> Conversation {
    var conversation = Conversation()
    conversation.people = people
    conversation.saveInBackground()
    return conversation
  }
}
