//
//  ScrollViewHeader.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI

// From this brilliant blog post: https://danielsaidi.com/blog/2023/02/06/adding-a-stretchable-header-to-a-swiftui-scroll-view

struct ScrollViewHeader<Content: View>: View {
	init(
		@ViewBuilder content: @escaping () -> Content
	) {
		self.content = content
	}

	private let content: () -> Content

	var body: some View {
		GeometryReader { geo in
			content()
				.stretchable(in: geo)
		}
	}
}
