//
//  Promise+UIViewController.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/28/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit



extension UINavigationController {
	static let pushDuration = 0.2
	static let popDuration = 0.35
	
	public func popController(animated: Bool = true) -> EmptyPromise {
		let promise = EmptyPromise()
		
		self.popViewController(animated: animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + UINavigationController.popDuration) {
			promise.fulfill(NoValue)
		}
		
		return promise
	}

	public func pushController(_ viewController: UIViewController, animated: Bool = true) -> EmptyPromise {
		let promise = EmptyPromise()
		
		self.pushViewController(viewController, animated: animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + UINavigationController.pushDuration) {
			promise.fulfill(NoValue)
		}
		
		return promise
	}
}

extension UIViewController {
	public func presentController(_ viewController: UIViewController, animated: Bool = true) -> EmptyPromise {
		let promise = EmptyPromise()

		self.present(viewController, animated: animated) {
			promise.fulfill(NoValue)
		}

		return promise
	}
	
	public func dismissController(animated: Bool = true) -> EmptyPromise {
		let promise = EmptyPromise()
		
		self.dismiss(animated: animated) {
			promise.fulfill(NoValue)
		}
		
		return promise
	}
}
#endif
