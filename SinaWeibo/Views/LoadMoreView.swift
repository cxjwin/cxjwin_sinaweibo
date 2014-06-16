//
//  LoadMoreView.swift
//  SinaWeibo
//
//  Created by cxjwin on 6/16/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

class LoadMoreView: UIView {
	
	var indicatorView: UIActivityIndicatorView
	
	var isLoading: Bool {
	didSet {
		if isLoading {
			indicatorView.startAnimating()
		} else {
			indicatorView.stopAnimating()
		}
	}
	}
	
    init(frame: CGRect) {
		isLoading = false
		indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
		
        super.init(frame: frame)
        // Initialization code
		
		self.backgroundColor = UIColor.yellowColor()
		indicatorView.center = self.center
		self.addSubview(indicatorView)
		
		self.window
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
