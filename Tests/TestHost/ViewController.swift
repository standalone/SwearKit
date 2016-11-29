//
//  ViewController.swift
//  Plug
//
//  Created by Ben Gottlieb on 2/9/15.
//  Copyright (c) 2015 Stand Alone, inc. All rights reserved.
//

import UIKit
import SwearKit

class ViewController: UIViewController {
	var presented = false
	@IBOutlet var statusLabel: UILabel!
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let view = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))

		if !self.presented {
			self.presented = true
			self.navigationController!.push(TestController1()).then(on: .main) {
				self.navigationController!.pop()
			}.then(on: .main) {
				self.present(TestController2())
			}.then(on: .main) {
				self.dismiss()
				}.then(on: .main, { (Void) -> Promise<Bool> in
				view.backgroundColor = UIColor.green
				self.view.addSubview(view)
				
				return UIView.animate(duration: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0) {
					view.center = CGPoint(x: 200, y: 200)
				}
			}).then(on: .main, { (Bool) -> EmptyPromise in
				view.remove()
			})	
		}
	}
}



class TestController1: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.red
	}
}

class TestController2: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.blue
	}
}
