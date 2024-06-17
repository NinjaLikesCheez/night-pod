//
//  Date+Extensions.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 15/03/2024.
//

import Foundation

extension Date {
	func shortDateString() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMM yy"
		return formatter.string(from: self)
	}
}
