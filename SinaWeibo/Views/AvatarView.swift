//
//  AvatarView.swift
//  SinaWeibo
//
//  Created by cxjwin on 6/17/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

@objc(AvatarView)
@IBDesignable
class AvatarView: UIImageView {

	@IBInspectable var URLString: String? {
	didSet {
		if let _URLString = URLString {
			var avatarUrl = NSURL(string: _URLString);
			
			let manager = SDWebImageManager.sharedManager()
			var cacheimage: UIImage? = manager.imageCache.imageFromDiskCacheForKey(avatarUrl.absoluteString)
			
			if let _image = cacheimage {
				self.image = _image
			} else {
				self.image = nil
				
				var completed: (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, finished: Bool) -> Void = {
					[weak self] (image: UIImage?, error: NSError?, cacheType: SDImageCacheType, finished: Bool) in
					if image {
						dispatch_async(dispatch_get_main_queue(), {
							self!.image = image!
							})
					}
				}
				
				manager.downloadWithURL(avatarUrl, options: SDWebImageOptions.CacheMemoryOnly, progress: nil, completed: completed)
			}
		}
	}
	}
	
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
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
