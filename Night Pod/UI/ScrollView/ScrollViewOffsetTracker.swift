//
//  ScrollViewOffsetTracker.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI

enum ScrollOffsetNamspace {
	static let namespace = "scrollView"
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ScrollViewOffsetTracker: View {
	var body: some View {
		GeometryReader { geo in
			Color.clear
				.preference(
					key: ScrollOffsetPreferenceKey.self,
					value: geo.frame(
						in: .named(ScrollOffsetNamspace.namespace)
					).origin
				)
		}
		.frame(height: 0)
	}
}

extension ScrollView {
	func withOffsetTracking(
		action: @escaping (_ offset: CGPoint) -> Void
	) -> some View {
		self.coordinateSpace(name: ScrollOffsetNamspace.namespace)
			.onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
	}
}
