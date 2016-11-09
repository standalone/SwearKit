//
//  SwaerKit+URLSessionTests.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/9/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation
import XCTest
@testable import SwearKit

class SwearKit_URLSession_Tests: XCTestCase {
	func testSuccessfulDownload() {
		let completionExpectation = expectation(description: "Successful Download Test")
		let finallyExpectation = expectation(description: "Finally Called")
		
		let url = URL(string: "http://jsonview.com/example.json")!
		
		URLSession.shared.get(url: url).then { data -> Int in
			XCTAssert(data.count == 260, "Got wrong amount of data")
			completionExpectation.fulfill()
			return 0
		}.catch { error in
			XCTAssert(true, "shouldn't get an error for a successful test download")
		}.cancelled { error in
			XCTAssert(true, "shouldn't be able to cancel a test download")
		}.finally {
			finallyExpectation.fulfill()
		}
		waitForExpectations(timeout: 10) { error in
			
		}
	}

	func testFailedDownload() {
		let failureExpectation = expectation(description: "Failed Download Test")
		let finallyExpectation = expectation(description: "Finally Called")
		
		let url = URL(string: "http://asdfasdfjsonview.com/example.json")!
		
		URLSession.shared.get(url: url).then { data -> Int in
			XCTAssert(true, "shouldn't receive data from a failed test download")
			return 0
		}.catch { error in
			failureExpectation.fulfill()
		}.cancelled { error in
			XCTAssert(true, "shouldn't be able to cancel a test download")
		}.finally {
			finallyExpectation.fulfill()
		}
		
		waitForExpectations(timeout: 10) { error in
			
		}
	}
}
