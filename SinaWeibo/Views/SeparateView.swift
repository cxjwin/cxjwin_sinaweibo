//
//  SeparateView.swift
//  SinaWeibo
//
//  Created by cxjwin on 6/19/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit
@objc(SeparateView)
class SeparateView: UIView {

	let lineWidth = 1.0 / UIScreen.mainScreen().scale
	
	var label: UILabel!
	var leftLine: UIView!
	var rightLine: UIView!
	
    init(frame: CGRect) {
		self.leftLine = UIView()
		self.leftLine.backgroundColor = UIColor.grayColor()
		
		self.rightLine = UIView()
		self.rightLine.backgroundColor = UIColor.grayColor()
		
		self.label = UILabel()
		self.label.backgroundColor = UIColor.clearColor()
		self.label.textAlignment = .Center
		self.label.font = UIFont.systemFontOfSize(12)
		self.label.textColor = UIColor.purpleColor()
		self.label.text = "SOURCE"
		
        super.init(frame: frame)
        // Initialization code
		
		self.addSubview(self.leftLine)
		self.addSubview(self.rightLine)
		self.addSubview(self.label)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

	override func layoutSubviews()  {
		super.layoutSubviews()
		
		self.label.sizeToFit()
		self.label.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5)
		
		leftLine.frame = CGRectMake(15, CGRectGetHeight(self.bounds) * 0.5, CGRectGetWidth(self.bounds) * 0.5 - 30, lineWidth)
		rightLine.frame =
			CGRectMake(CGRectGetWidth(self.bounds) * 0.5 + 15, CGRectGetHeight(self.bounds) * 0.5, CGRectGetWidth(self.bounds) * 0.5 - 30, lineWidth)
	}
}
