//
//  UIView+Promise.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/28/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

extension UIView {
	public class func animate(duration: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat = 1.0, initialSpringVelocity velocity: CGFloat = 0.0, options: UIView.AnimationOptions = [], animations: @escaping () -> Void) -> Promise<Bool> {
		let promise = Promise<Bool>()
		
		UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations) { complete in
			
			promise.fulfill(true)
		}
		
		return promise
	}
	
	public func remove() -> EmptyPromise {
		let promise = EmptyPromise()
		
		self.removeFromSuperview()
		
		promise.fulfill(0)
		return promise
	}
}
#endif
