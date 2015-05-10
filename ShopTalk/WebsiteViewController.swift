import UIKit

class WebsiteViewController: ApplicationViewController, UIWebViewDelegate {
  
  @IBOutlet weak var webview: UIWebView!
  var website: String?
  
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var superButton: PlusButton!
  @IBOutlet weak var hiButton: UIButton!
  
  @IBOutlet weak var closeButtonXConstraint: NSLayoutConstraint!
  @IBOutlet weak var hiButtonXConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var superButtonXConstraint: NSLayoutConstraint!
  @IBOutlet weak var superButtonYConstraint: NSLayoutConstraint!
  var areButtonsHidden = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://" + website!)!))
    webview.delegate = self
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    
  }
  
  @IBAction func closeButtonPressed(sender: UIButton) {
      self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func plusButtonPressed(sender: PlusButton) {
    
    if areButtonsHidden {
      closeButton.hidden = false
      hiButton.hidden = false
      areButtonsHidden = false

      UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        
        self.closeButtonXConstraint.constant = -60
        self.hiButtonXConstraint.constant = 60
        self.view.layoutSubviews()
        }, completion: nil)
    } else {
      
      UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.closeButtonXConstraint.constant = 0
        self.hiButtonXConstraint.constant = 0
        self.view.layoutSubviews()
        
        },
        completion: {(_)in
          self.areButtonsHidden = true
          self.closeButton.hidden = true
          self.hiButton.hidden = true
          self.view.layoutSubviews()

      })
    }
    
    
    
  }
  
  @IBAction func dragged(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Began:
      let center = sender.locationInView(self.view)
      superButtonXConstraint.constant = self.view.bounds.width - center.x - superButton.bounds.width
      superButtonYConstraint.constant = self.view.bounds.height - center.y - superButton.bounds.height
      //      superButton.center = sender.locationInView(self.view)
      //      closeButton.center = sender.locationInView(self.view)
    case .Changed:
      let center = sender.locationInView(self.view)
      superButtonXConstraint.constant = self.view.bounds.width - center.x - superButton.bounds.width
      superButtonYConstraint.constant = self.view.bounds.height - center.y - superButton.bounds.height
      //      superButton.center = sender.locationInView(self.view)
      //      closeButton.center = sender.locationInView(self.view)
    default:
      println("at least one executatble statement")
      //do nothing
    }
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
