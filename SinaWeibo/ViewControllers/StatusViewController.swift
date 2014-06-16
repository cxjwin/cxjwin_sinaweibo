//
//  StatusViewController.swift
//  SinaWeibo
//
//  Created by cxjwin on 14-6-11.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

class StatusViewController: UITableViewController {
    
    let kStatusViewTag = 101
    
    let communicator: SinaWeiboCommunicator = SinaWeiboManager.defaultManager().communicator
    
    let database: FMDatabase = DatabaseManager.defaultManager().database
    
    var observers = NSMutableArray()
    
    var statuses = NSMutableArray()
    
    var nextPage = 1
    
    var dataArray = NSMutableArray()
    
    var item: NSURL?
	
	var isLoading: Bool
	
	// views
	var loadMoreView = LoadMoreView(frame: CGRectZero)
	
    deinit {
        self.removeObservers()
    }
	
	init(coder aDecoder: NSCoder!) {
		isLoading = false
		super.init(coder: aDecoder)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
        self.addObservers()
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named:"BackgroundTile"))
		
        let tableFooterViewFrame = CGRect(x: 0, y: 0, width: CGRectGetWidth(self.tableView.frame), height: 1)
        self.tableView.tableFooterView = UIView(frame: tableFooterViewFrame)
        self.tableView.tableFooterView.backgroundColor = UIColor.whiteColor()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("refreshControlValueChanged"), forControlEvents: .ValueChanged)
		
		loadMoreView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 30)
		
        let user = SinaWeiboManager.defaultManager().user
        if user.screenName {
            self.title = user.screenName
        } else {
            self.title = "ME"
        }
        
        self.loadStatusesDataFromDB()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
		let count = self.statuses.count
		
		
		
        return self.statuses.count
    }
	
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        let identifier: String = "StatusCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
        cell.selectionStyle = .None
        
        var status = self.statuses[indexPath.row] as WeiboStatus
        
        var statusView = cell.contentView.viewWithTag(kStatusViewTag) as StatusView
		
        statusView.status = status
        
        return cell
    }
	
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat  {
		var status = self.statuses[indexPath!.row] as WeiboStatus
		return StatusView.contentHeightWithStatus(status);
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
            var statuses = WeiboStatus.statusesFromJSONData(data, error: nil)
            if (statuses) {
                self.statuses.addObjectsFromArray(statuses)
            } else {
                // Do nothing
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            })
        
        self.loadStatusesData()
    }
    
    func loadStatusesData() {
        self.communicator.getWeiboStatusesWithPage(1, completionHandler: {
            [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            if self!.refreshControl.refreshing {
                self!.refreshControl.endRefreshing()
            }
            
            if error {
                NSLog("%@", error!.localizedDescription)
				return;
            }
            
            var statuses: NSMutableArray? = WeiboStatus.statusesWithPreviewImageSizeFromJSONData(data, error: nil)
            
            if statuses && statuses?.count > 0 {
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
	
	func loadNextPageStatusesData() {
		
	}
    
    func refreshControlValueChanged() {
        if self.refreshControl.refreshing {
            self.loadStatusesData()
        }
    }
    
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
            self.observers.addObject(observer)
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
            self.observers.addObject(observer)
        }while(false)
        
        // kShowOriginalPicNotification
        do {
            var observer =
            NSNotificationCenter.defaultCenter().addObserverForName("kShowOriginalPicNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
                _ in
                NSLog("%s", __FUNCTION__)
                
                })
            self.observers.addObject(observer)
        }while(false)
        
        // kThumbnailPicLoadedNotification
        do {
            var observer =
            NSNotificationCenter.defaultCenter().addObserverForName("kThumbnailPicLoadedNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
                _ in
                NSLog("%s", __FUNCTION__)
                self.tableView.reloadData()
                })
            self.observers.addObject(observer)
        }while(false)
        
        // kShowUserInfoNotification
        do {
            var observer =
            NSNotificationCenter.defaultCenter().addObserverForName("kShowUserInfoNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
                (note: NSNotification!) in
                var user = note.object as WeiboUser;
                println("\(user.profileImageUrl)")
                
                var storyBoard = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle())
                var viewController = storyBoard.instantiateViewControllerWithIdentifier("UserInfoViewController") as UserInfoViewController
                viewController.user = user
                self.navigationController.pushViewController(viewController, animated: true)
                
                })
            self.observers.addObject(observer)
        }while(false)
    }
    
    func removeObservers() {
        if observers.count > 0 {
            for observer : AnyObject in observers {
                NSNotificationCenter.defaultCenter().removeObserver(observer)
            }
        }
    }
    
}
