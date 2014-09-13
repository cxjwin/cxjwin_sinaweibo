//
//  WBWebViewController.swift
//  SinaWeibo
//
//  Created by cxjwin on 6/13/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

class WBWebViewController: UIViewController {

	@IBOutlet var webView : UIWebView?
	
	var URLString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// load request
		if let URLString = self.URLString {
			var URL = NSURL(string: URLString)
			var request = NSURLRequest(URL: URL)
			self.webView?.loadRequest(request)
		} else {
			println("url string is nil...")
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
