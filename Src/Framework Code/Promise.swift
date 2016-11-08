//
//  Promise.swift
//  SwearKit
//
//  Created by Ben Gottlieb on 11/8/16.
//  Copyright © 2016 Stand Alone, inc. All rights reserved.
//

import Foundation

struct Completions<Value> {
	let onFulfilled: (Value) -> ()
	let onRejected: (Error) -> ()
	let queue: DispatchQueue
	
	func fulfill(_ value: Value) { self.queue.async { self.onFulfilled(value) } }
	func reject(_ error: Error) { queue.async { self.onRejected(error) } }
}

struct Finally {
	let onFinally: () -> ()
	let queue: DispatchQueue
	
	func finally() { self.queue.async { self.onFinally() } }
}

enum State<Value>: CustomStringConvertible { case pending, fulfilled(value: Value), rejected(error: Error)
	var isPending: Bool {
		if case .pending = self { return true }
		return false
	}
	
	var value: Value? {
		if case let .fulfilled(value) = self { return value }
		return nil
	}
	
	var error: Error? {
		if case let .rejected(error) = self { return error }
		return nil
	}
	
	var description: String {
		switch self {
		case .fulfilled(let value): return "Fulfilled (\(value))"
		case .rejected(let error): return "Rejected (\(error))"
		case .pending: return "Pending"
		}
	}
}


extension DispatchQueue {
	static var promiseQueue: DispatchQueue { return DispatchQueue.global(qos: .userInitiated) }
}

public final class Promise<Value> {
	private var state: State<Value> = .pending
	private let serializer = DispatchQueue(label: "promise_lock_queue", qos: .userInitiated)
	private var completions: [Completions<Value>] = []
	private var finallies: [Finally] = []
	
	public init() { }
	
	public init(value: Value) { self.state = .fulfilled(value: value) }
	
	public init(error: Error) { self.state = .rejected(error: error) }
	
	public convenience init(queue: DispatchQueue = .promiseQueue, work: @escaping (_ fulfill: @escaping (Value) -> (), _ reject: @escaping (Error) -> () ) throws -> ()) {
		self.init()
		queue.async {
			do {
				try work(self.fulfill, self.reject)
			} catch let error {
				self.reject(error)
			}
		}
	}
	
	@discardableResult public func then<NewValue>(on queue: DispatchQueue = .promiseQueue, _ onFulfilled: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
		return Promise<NewValue>(work: { fulfill, reject in
			self.addCompletions(on: queue,
				onFulfilled: { value in
					do {
						try onFulfilled(value).then(fulfill, reject)
					} catch let error {
						reject(error)
					}
				},
				onRejected: reject
			)
		})
	}
	
	@discardableResult public func then<NewValue>(on queue: DispatchQueue = .promiseQueue, _ onFulfilled: @escaping (Value) throws -> NewValue) -> Promise<NewValue> {
		return then(on: queue, { (value) -> Promise<NewValue> in
			do {
				return Promise<NewValue>(value: try onFulfilled(value))
			} catch let error {
				return Promise<NewValue>(error: error)
			}
		})
	}
	
	@discardableResult public func then(on queue: DispatchQueue = .promiseQueue, _ onFulfilled: @escaping (Value) -> (), _ onRejected: @escaping (Error) -> () = { _ in }) -> Promise<Value> {
		return Promise<Value>(work: { fulfill, reject in
			self.addCompletions( on: queue,
			                     onFulfilled: { value in fulfill(value); onFulfilled(value) },
			                     onRejected: { error in reject(error);  onRejected(error) }
			)
		})
	}
	
	@discardableResult public func finally(on queue: DispatchQueue = .promiseQueue, _ onFinally: @escaping () -> Void) -> Self {
		self.finallies.append(Finally(onFinally: onFinally, queue: queue))
		return self
	}
	
	@discardableResult public func `catch`(on queue: DispatchQueue = .promiseQueue, _ onRejected: @escaping (Error) -> ()) -> Promise<Value> {
		return self.then(on: queue, { _ in }, onRejected)
	}
	
	public func reject(_ error: Error) { self.updateState(.rejected(error: error)) }
	public func fulfill(_ value: Value) { self.updateState(.fulfilled(value: value)) }
	
	public var isPending: Bool {
		var result: Bool = false
		self.serializer.sync { result = self.state.isPending }
		return result
	}
	public var isFulfilled: Bool { return self.value != nil }
	public var isRejected: Bool { return self.error != nil }
	
	public var value: Value? {
		var result: Value?
		self.serializer.sync { result = self.state.value }
		return result
	}
	
	public var error: Error? {
		var result: Error?
		self.serializer.sync { result = self.state.error }
		return result
	}
	
	private func updateState(_ state: State<Value>) {
		self.serializer.sync {
			guard self.state.isPending else { return }
			self.state = state
			self.fireCompletions()
		}
	}
	
	private func addCompletions(on queue: DispatchQueue, onFulfilled: @escaping (Value) -> (), onRejected: @escaping (Error) -> ()) {
		let completion = Completions(onFulfilled: onFulfilled, onRejected: onRejected, queue: queue)
		self.serializer.async { self.completions.append(completion) }
		self.fireCompletions()
	}
	
	private func fireCompletions() {
		self.serializer.async {
			guard !self.state.isPending else { return }
			self.completions.forEach { completion in
				switch self.state {
				case let .fulfilled(value):
					completion.fulfill(value)
				case let .rejected(error):
					completion.reject(error)
				default:
					break
				}
			}
			self.completions.removeAll()
			
			self.finallies.forEach { finally in finally.finally() }
			self.finallies.removeAll()
		}
	}
}
