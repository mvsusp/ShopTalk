import UIKit

class WebsiteViewController: UIViewController, UIWebViewDelegate {
  
  @IBOutlet weak var webview: UIWebView!
  var website: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://" + website!)!))
    webview.delegate = self
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
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
  
  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
