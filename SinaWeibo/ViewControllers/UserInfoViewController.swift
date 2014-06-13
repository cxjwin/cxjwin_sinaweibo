//
//  UserInfoViewController.swift
//  SinaWeibo
//
//  Created by cxjwin on 14-6-11.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    let communicator = SinaWeiboManager.defaultManager().communicator
    
    var user: WeiboUser?
    
    @IBOutlet var imageView : UIImageView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.imageView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.user {
            return
        }
        
        let curUser = self.user!
        
        var avatarUrl: NSURL?
        
        if curUser.profileImageUrl {
            if curUser.avatarLarge {
                avatarUrl = NSURL(string: curUser.avatarLarge)
            } else {
                avatarUrl = NSURL(string: curUser.profileImageUrl)
            }
        }
        
        if var url = avatarUrl {
            var request = NSURLRequest(URL: url)
            
            var URLCache: NSURLCache? = self.communicator.defaultSession.configuration.URLCache
            
            var response:NSCachedURLResponse? = URLCache?.cachedResponseForRequest(request)
            
            if response {
                var data:NSData? = response!.data
                if data {
                    var image = UIImage(data: data)
                    println("\(image)")
                    self.imageView.image = image
                }
            } else {
                self.communicator.downloadImageWithURL(url, downloadCompletionHandler: {
                    [weak self] (data: NSData?, _, _) in
                    if data?.length > 0 {
                        NSOperationQueue.mainQueue().addOperationWithBlock{
                            var image = UIImage(data: data)
                            println("\(image)")
                            self!.imageView.image = image
                        }
                    }
                    })
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
