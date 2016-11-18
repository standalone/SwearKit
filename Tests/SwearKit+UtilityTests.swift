//
//  SwearKit+UtilityTests.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/18/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation
import XCTest
@testable import SwearKit

class SwearKit_Utility_Tests: XCTestCase {
	func testDelayed() {
		let now = Date()
		let interval: TimeInterval = 1.0
		let expect = expectation(description: "delayed")
		
		EmptyPromise.delayed(interval).then {
			XCTAssert(Date().timeIntervalSince(now) >= interval, "Didn't wait long enough")
			expect.fulfill()
		}

			
		
		waitForExpectations(timeout: interval + 1) { error in
			
		}
	}
}
