//
//  URLSession+Promise.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/6/16.
//  Copyright © 2016 Stand Alone, Inc. All rights reserved.
//

import Foundation

public extension URLSession {
	enum DownloadError: Error { case noData }
	
	func get(queue: DispatchQueue = .main, url: URL) -> Promise<Data> {
		let promise = Promise<Data>()
		
		let task = self.dataTask(with: url) { data, response, error in
			if let data = data {
				promise.fulfill(data)
			} else if let error = error {
				promise.reject(error)
			} else {
				promise.reject(DownloadError.noData)
			}
		}
		
		task.resume()
		return promise
	}
	
	func getWithRequest(queue: DispatchQueue = .main, url: URL) -> Promise<(URLResponse, Data)> {
		let promise = Promise<(URLResponse, Data)>()
		
		let task = self.dataTask(with: url) { data, response, error in
			if let data = data, let response = response {
				promise.fulfill((response, data))
			} else if let error = error {
				promise.reject(error)
			} else {
				promise.reject(DownloadError.noData)
			}
		}
		
		task.resume()
		return promise
	}

}
