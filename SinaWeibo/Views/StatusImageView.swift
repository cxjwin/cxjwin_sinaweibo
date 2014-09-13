//
//  StatusImageView.swift
//  SinaWeibo
//
//  Created by cxjwin on 7/1/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit
import QuartzCore

class URLImageView: UIImageView {
    var URLString: String? {
    didSet {
        var avatarURL: NSURL? = nil
        if (URLString != nil) {
            avatarURL = NSURL.URLWithString(URLString!)
        }
        
        if let tempURL = avatarURL {
            let manager = SDWebImageManager.sharedManager()
            var image: UIImage? = manager.imageCache.imageFromDiskCacheForKey(tempURL.absoluteString)
            if (image != nil) {
                self.image = image!
            } else {
                self.image = nil
                
                manager.downloadWithURL(tempURL, options: .CacheMemoryOnly, progress: nil, completed: {
                    [weak self] (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, finished: Bool) in
                    if (image != nil) {
                        self?.exchangeImage(image!)
                    }
                    });
            }
        }
    }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .ScaleAspectFit
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func exchangeImage(image: UIImage) {
        var transition = CATransition()
        transition.duration = 0.3
        transition.type = "fade"
        self.image = image
        self.layer.addAnimation(transition, forKey: nil)
    }
}

@objc(StatusImageView)
class StatusImageView: UIView {
    let kMaxRowCount = 3
    let kMaxColumnCount = 3
    
    var displaySize = CGSizeZero
    var imagesView: NSMutableArray = NSMutableArray()
    
    var URLStrings: NSArray? {
    didSet {
        
        for view: AnyObject in imagesView {
            let tempView = view as UIView
            tempView.removeFromSuperview()
        }
        displaySize = CGSizeZero
        self.imagesView.removeAllObjects()
        
        let count = URLStrings != nil ? URLStrings!.count : 0;
        
        if count == 1 {
            displaySize = CGSizeMake(100, 100)
            var imageView = URLImageView(frame: CGRect(origin: CGPointZero, size: displaySize))
            imageView.URLString = URLStrings!.firstObject as? String
            self.addSubview(imageView)
            self.imagesView.addObject(imageView)
        }
        else {
            let singleImageWidth: CGFloat = 64.0
            let maxWidth = CGFloat(kMaxRowCount) * singleImageWidth
            let maxHeight = CGFloat(kMaxColumnCount) * singleImageWidth
            
            var x: CGFloat = 0.0
            var y: CGFloat = 0.0
            
            for i in 0..<count {
                var imageView = URLImageView(frame: CGRect(x: x, y: y, width: singleImageWidth, height: singleImageWidth))
                imageView.URLString = URLStrings!.objectAtIndex(i) as? String
                self.addSubview(imageView)
                self.imagesView.addObject(imageView)
                
                x += singleImageWidth
                
                if x >= maxWidth {
                    x = 0.0
                    y += singleImageWidth
                }
            }
            
            displaySize = CGSizeMake(maxWidth, min(y + singleImageWidth, maxHeight));
        }
    }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
