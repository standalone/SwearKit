//
//  Utility+Promises.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/18/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation

extension Promise {
	public static func delayed(by interval: TimeInterval) -> EmptyPromise {
		let promise = EmptyPromise()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + interval) { 
			promise.fulfill()
		}

		return promise
	}
	
	public func delay(by interval: TimeInterval) -> EmptyPromise {
		let promise = EmptyPromise()

		self.addCompletions(on: .main, onFulfilled: { _ in
			DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
				promise.fulfill()
			}
		}, onRejected: { error in  }, onCancelled: { error in  })
		
		return promise
	}
}
