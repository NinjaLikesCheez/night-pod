//
//  CGFloat+Extensions.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 15/03/2024.
//

import Foundation

extension CGFloat {
	func capped(to range: ClosedRange<Self>) -> Self {
		if self < range.lowerBound { return range.lowerBound }
		if self > range.upperBound { return range.upperBound }
		return self
	}
}
