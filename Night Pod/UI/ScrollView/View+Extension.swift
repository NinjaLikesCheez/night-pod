//
//  View+Extension.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI

// From this brilliant blog post: https://danielsaidi.com/blog/2023/02/06/adding-a-stretchable-header-to-a-swiftui-scroll-view


extension View {
	@ViewBuilder
	func stretchable(in geometryProxy: GeometryProxy) -> some View {
		let width = geometryProxy.size.width
		let height = geometryProxy.size.height
		let minY = geometryProxy.frame(in: .global).minY
		let useStandard = minY <= 0
		self.frame(
			width: width,
			height: height + (useStandard ? 0 : minY)
		)
		.offset(y: useStandard ? 0 : -minY)
	}
}
