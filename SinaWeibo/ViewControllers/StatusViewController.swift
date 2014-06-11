//
//  StatusViewController.swift
//  SinaWeibo
//
//  Created by cxjwin on 14-6-11.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

import UIKit

class StatusViewController: UITableViewController {

	let kStatusViewTag = 101;
	
	let communicator: SinaWeiboCommunicator = SinaWeiboManager.defaultManager().communicator
	let database: FMDatabase = DatabaseManager.defaultManager().database;
	
	var statuses = NSMutableArray();
	
	var nextPage = 1;
	var dataArray = NSMutableArray();
	
	var item: NSURL?
	
	deinit {
		self.removeObservers()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		
		// self.addObservers()
		
		self.tableView.backgroundColor = UIColor(patternImage: UIImage(named:"BackgroundTile"))
		
		let tableFooterViewFrame = CGRect(x: 0, y: 0, width: CGRectGetWidth(self.tableView.frame), height: 1)
		self.tableView.tableFooterView = UIView(frame: tableFooterViewFrame)
		self.tableView.tableFooterView.backgroundColor = UIColor.whiteColor()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.addTarget(self, action: Selector("refreshControlValueChanged"), forControlEvents: .ValueChanged)
		
		let user = SinaWeiboManager.defaultManager().user
		if user.screenName {
			self.title = user.screenName
		} else {
			self.title = "我"
		}
		
		// self.loadStatusesDataFromDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.statuses.count
    }
	
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		if !tableView || !indexPath {
			return nil;
		}
		
		let identifier: String = "StatusCell"
		
		var cell = tableView!.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath!) as UITableViewCell
		cell.selectionStyle = .None
		
		var status = self.statuses[indexPath!.row] as WeiboStatus;
		
		var subView = cell.contentView.viewWithTag(kStatusViewTag) as StatusView
		subView.statusAction = {
			[weak self] (statusView: StatusView?, info: AnyObject?, actionType: StatusActionType) in
			
			switch actionType {
			case .ShowUserInfo:
				var viewController = UserInfoViewController(nibName: nil, bundle: nil)
				viewController.user = status.user
				self!.navigationController.pushViewController(viewController, animated: true)
				
			default:
				NSLog("Other actionType")
			}
		}
		
		subView.status = status
		
		return cell
    }

	override func tableView(tableView: UITableView?, willDisplayCell: UITableViewCell?, forRowAtIndexPath: NSIndexPath?) {
		var bounds = willDisplayCell!.contentView.bounds;
		var statusView = willDisplayCell!.contentView.viewWithTag(kStatusViewTag) as StatusView
		statusView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(bounds), height: CGRectGetHeight(bounds))
	}
	
	override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat  {
				
		var height: CGFloat = 48.0;
		
		// height for status text
		var status = self.statuses[indexPath!.row] as WeiboStatus
		
		// status text
		let textHeight = status.contentTextSize.CGSizeValue().height
		height = 3 + height + textHeight + 3
		
		if (status.retweetedStatus) {
			// height for separtion view
			height = 2 + height + 16 + 2;
			// height for retweeted status text
			let reTextHeight = status.retweetedStatus.contentTextSize.CGSizeValue().height
			height = 3 + height + reTextHeight  + 3;
		}
		
		// single image
		if status.pictureURLInStatus() is NSURL {
			var imageHeight: CGFloat = status.previewImageSize.CGSizeValue().height
			height = 3 + height + imageHeight + 3;
		}
		// muti images
		else if status.pictureURLInStatus() is NSMutableArray {
			let imageHeight = status.previewImageSize.CGSizeValue().height
			height = 3 + height + imageHeight + 3;
		}
		
		// height for tool bar
		height = 5 + height + 16 + 10;
		
		return height;
	}
	
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

	func loadStatusesDataFromDB() {
		var sql: NSString = NSString(string: "select * from statuses_data;")
		
		var resultSet = self.database.executeQuery(sql, withArgumentsInArray: nil)

		self.statuses = NSMutableArray()
		
		while (resultSet.next()) {
			var data = resultSet.dataForColumnIndex(0)
			var statuses = WeiboStatus.statusesFromJSONData(data, error: nil);
			if (statuses) {
				self.statuses.addObjectsFromArray(statuses)
			} else {
				// Do nothing
			}
		}
		
		dispatch_async(dispatch_get_main_queue(), {
			self.loadStatusesData()
			self.tableView.reloadData()
			})
	}

	func loadStatusesData() {
		self.communicator.getWeiboStatusesWithPage(1, completionHandler: {
			[weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) in
			
			if self!.refreshControl.refreshing {
				self!.refreshControl.endRefreshing()
			}
			
			if error {
				NSLog("%@", error!.localizedDescription)
			}
			
			var statuses: NSMutableArray? = WeiboStatus.statusesWithPreviewImageSizeFromJSONData(data, error: nil)
			
			if statuses {
				self!.dataArray.removeAllObjects()
				self!.dataArray.addObject(data)
				self!.nextPage = 2
				self!.statuses = statuses!
				
				dispatch_async(dispatch_get_main_queue(), {
					self!.tableView.reloadData()
				})
			}
			})
	}
	
	func refreshControlValueChanged() {
		if self.refreshControl.refreshing {
			self.loadStatusesData()
		}
	}
	
	var observers: NSObjectProtocol[] = NSObjectProtocol[]()
	
	func addObservers() {
		// applicationDidEnterBackground
		do {
			var observer =
			NSNotificationCenter.defaultCenter().addObserverForName("applicationDidEnterBackground", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
				_ in
				NSLog("%s", __FUNCTION__)
				let count = self.dataArray.count
				if (count > 0) {
					for (var i = 0; i < count; ++i) {
						var sql: NSString = NSString(string: "insert into statuses_data (data) values (?);")
						var data = self.dataArray.objectAtIndex(i) as NSData
						self.database.executeUpdate(sql, withArgumentsInArray: NSArray(object: data))
					}
				}
				})
			observers.append(observer)
		}while(false)
		
		// kWeiboUserInfoDidUpdateNotification
		do {
			var observer =
			NSNotificationCenter.defaultCenter().addObserverForName("kWeiboUserInfoDidUpdateNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
				_ in
				NSLog("%s", __FUNCTION__)
				var user = SinaWeiboManager.defaultManager().user
				self.title = user.screenName
				})
			observers.append(observer)
		}while(false)
		
		// kShowOriginalPicNotification
		do {
			var observer =
			NSNotificationCenter.defaultCenter().addObserverForName("kShowOriginalPicNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
				_ in
				NSLog("%s", __FUNCTION__)
				
				})
			observers.append(observer)
		}while(false)
		
		// kThumbnailPicLoadedNotification
		do {
			var observer =
			NSNotificationCenter.defaultCenter().addObserverForName("kThumbnailPicLoadedNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
				_ in
				NSLog("%s", __FUNCTION__)
				self.tableView.reloadData()
				})
			observers.append(observer)
		}while(false)
	}
	
	func removeObservers() {
		if observers.count > 0 {
			for observer in observers {
				NSNotificationCenter.defaultCenter().removeObserver(observer)
			}
		}
	}
	
}
