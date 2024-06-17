//
//  RandomShuffle.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 02/04/2024.
//

import Foundation

struct RandomShuffle<T: Collection> {
	let items: T

	func shuffle() -> [T.Element] {
		items.shuffled()
	}
}
