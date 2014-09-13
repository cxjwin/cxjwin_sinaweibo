//
//  LoginViewController.swift
//  SinaWeibo
//
//  Created by cxjwin on 14-6-11.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	var observer: NSObjectProtocol?
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(observer!)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
		observer = 
			NSNotificationCenter.defaultCenter().addObserverForName(kSinaWeiboDidLogInNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
				_ in
				self.performSegueWithIdentifier("TabBarControllerSegue", sender: nil)
				})
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		SinaWeiboManager.defaultManager().login()
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
