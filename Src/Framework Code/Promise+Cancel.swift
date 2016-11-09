//
//  Promise+Cancel.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/9/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation


/**
	To cancel a promise from within a `next` block, throw a PromiseCancelled error
*/

public enum PromiseCancelled: Error, CustomStringConvertible { case byUser, other
	public var description: String {
		switch self {
		case .byUser: return "cancelled by user"
		case .other: return "cancelled"
		}
	}
	
}

extension Promise {

	public func cancel(_ reason: PromiseCancelled) { self.updateState(.rejected(error: reason)) }
	
}
