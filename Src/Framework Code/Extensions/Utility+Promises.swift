//
//  Utility+Promises.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/18/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation

extension Promise {
	public static func delayed(_ interval: TimeInterval) -> EmptyPromise {
		let promise = EmptyPromise()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + interval) { 
			promise.fulfill()
		}

		return promise
	}
}
