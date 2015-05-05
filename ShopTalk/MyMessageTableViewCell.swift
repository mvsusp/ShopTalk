import UIKit

@IBDesignable
class MyMessageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var content: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
//    content.layer.cornerRadius = 3.0
//    content.layer.
//    content.clipsToBounds = true
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

}
