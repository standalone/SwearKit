//
//  Plug_Tests.swift
//  Plug Tests
//
//  Created by Ben Gottlieb on 2/9/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import UIKit
import XCTest
@testable import SwearKit

class SwearKit_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testPreFulfilled() {
		let expect = self.expectation(description: "unfulfilled promise")
		
		self.fulfilledPromise().then { text in
			expect.fulfill()
		}
		
		waitForExpectations(timeout: 1.0) { error in
			if let error = error {
				print("not fulfilled, \(error)")
			}
		}
	}
	
	func testPreRejected() {
		let expect = self.expectation(description: "unrejected promise")
		
		self.brokenPromise().then { text in
			XCTAssert(false, "Should not have been fulfilled")
			}.catch { error in
				expect.fulfill()
		}
		
		waitForExpectations(timeout: 3.0) { error in
			if let error = error {
				print("not rejected, \(error)")
			}
		}
	}
	
	func testPreCancelled() {
		let expect = self.expectation(description: "uncancelled promise")
		
		self.cancelledPromise().then { text in
			XCTAssert(false, "Should not have been fulfilled")
		}.catch { error in
			XCTAssert(false, "Should not have been rejected")
		}.cancelled { error in
			expect.fulfill()
		}
		
		waitForExpectations(timeout: 1.0) { error in
			if let error = error {
				print("not cancelled, \(error)")
			}
		}
	}

	func testChainParallel() {
		self.chain(parallel: true)
	}

	func testChainSerial() {
		self.chain(parallel: false)
	}

	func chain(parallel: Bool) {
		let expect = self.expectation(description: "chained promise")
		let chain = PromiseChain<Int>()
		let timeOut = parallel ? 2.0 : 5
		
		for i in 0...10 {
			chain.add() {
				let promise = Promise<Int>()
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					if i == 5 {
						promise.fulfill(i)
					} else {
						promise.reject(NSError(domain: "", code: 1, userInfo: nil))
					}
				}
				
				return promise
			}
		}
		
		chain.run(inParallel: parallel).then { success in
			print("Success: \(success)")
			expect.fulfill()
		}.catch { error in
			XCTAssert(false, "Chain should have succeeded")
		}

		waitForExpectations(timeout: timeOut) { error in
			if let error = error {
				print("chain failed, \(error)")
			}
		}
	}

	
	func fulfilledPromise() -> Promise<String> {
		let promise = Promise<String>()
		
		promise.fulfill("fulfilled!")
		return promise
	}

	func brokenPromise() -> Promise<String> {
		let promise = Promise<String>()
		
		promise.reject(NSError(domain: "Fail", code: 77, userInfo: nil))
		return promise
	}

	func cancelledPromise() -> Promise<String> {
		let promise = Promise<String>()
		
		promise.cancel(.other)
		return promise
	}

}
