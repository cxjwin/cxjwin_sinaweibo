//
//  UserInfoViewController.swift
//  SinaWeibo
//
//  Created by cxjwin on 14-6-11.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {

	var user: WeiboUser?
	
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// no user return
		if !self.user {
			return;
		}
		
		let curUser = self.user!
		
		let communicator = SinaWeiboManager.defaultManager().communicator
		
		var URLCache = communicator.defaultSession.configuration.URLCache
		
		var avatarUrl: NSURL? = nil;
		
		if (curUser.profileImageUrl) {
			if (curUser.avatarLarge) {
				avatarUrl = NSURL.URLWithString(curUser.avatarLarge)
			} else {
				avatarUrl = NSURL.URLWithString(curUser.profileImageUrl);
			}
		}

		if let url = avatarUrl {
			var request = NSURLRequest(URL: url)
			var response = URLCache.cachedResponseForRequest(request)
			
			var imageView = self.view.viewWithTag(101) as UIImageView
			if (response) {
				dispatch_async(dispatch_get_main_queue(), {
					imageView.image = UIImage(data: response.data);
					})
			} else {
				 communicator.downloadImageWithURL(url, downloadCompletionHandler: {
					[unowned(safe) imageView] (data: NSData?, response: NSURLResponse?, error: NSError?) in
					if !error && data?.length > 0 {
						dispatch_async(dispatch_get_main_queue(), {
							imageView.image = UIImage(data: data)
						});
					}
				});
			}
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
