//
//  MyInfoViewController.swift
//  SinaWeibo
//
//  Created by cxjwin on 6/13/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

let kMyAvatarViewTag = 101

class MyInfoViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		let communicator = SinaWeiboManager.defaultManager().communicator
		let curUser = SinaWeiboManager.defaultManager().user

		var imageView = self.tableView.tableHeaderView.viewWithTag(kMyAvatarViewTag) as UIImageView
		
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
			
			var URLCache: NSURLCache? = communicator.defaultSession.configuration.URLCache
			
			var response:NSCachedURLResponse? = URLCache?.cachedResponseForRequest(request)
			
			if response {
				var data:NSData? = response!.data
				if data {
					var image = UIImage(data: data)
					println("\(image)")
					imageView.image = image
				}
			} else {
				communicator.downloadImageWithURL(url, downloadCompletionHandler: {
					[weak imageView] (data: NSData?, _, _) in
					if data?.length > 0 {
						NSOperationQueue.mainQueue().addOperationWithBlock{
							var image = UIImage(data: data)
							println("\(image)")
							imageView!.image = image
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

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView?, canMoveRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
