//
//  ScrollViewWithOffset.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI

struct ScrollViewWithOffset<Content: View>: View {
	public typealias ScrollAction = (_ offset: CGPoint) -> Void
	private let axes: Axis.Set
	private let showsIndicators: Bool
	private let onScroll: ScrollAction
	private let content: () -> Content

	init(
		_ axes: Axis.Set = .vertical,
		showsIndicators: Bool = true,
		onScroll: ScrollAction? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.axes = axes
		self.showsIndicators = showsIndicators
		self.onScroll = onScroll ?? { _ in }
		self.content = content
	}

	var body: some View {
		ScrollView(axes, showsIndicators: showsIndicators) {
			ZStack(alignment: .top) {
				ScrollViewOffsetTracker()
				content()
			}
		}
		.withOffsetTracking(action: onScroll)
	}
}
