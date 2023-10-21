//
//  ScrollViewWithStickyHeader.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI

struct ScrollViewWithStickyHeader<Header: View, Content: View>: View {
	private let axes: Axis.Set
	private let showsIndicators: Bool
	private let header: () -> Header
	private let headerHeight: CGFloat
	private let headerMinHeight: CGFloat?
	private let onScroll: ScrollAction?
	private let content: () -> Content

	@State var scrollOffset: CGPoint = .zero
	@State var navigationBarHeight: CGFloat = .zero

	typealias ScrollAction = (
		_ offset: CGPoint,
		_ headerVisibleRatio: CGFloat
	) -> Void

	init(
		_ axes: Axis.Set = .vertical,
		@ViewBuilder header: @escaping () -> Header,
		showsIndicator: Bool = true,
		headerHeight: CGFloat,
		headerMinHeight: CGFloat? = nil,
		onScroll: ScrollAction? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.axes = axes
		self.showsIndicators = showsIndicator
		self.header = header
		self.headerHeight = headerHeight
		self.headerMinHeight = headerMinHeight
		self.onScroll = onScroll
		self.content = content
	}

	var body: some View {
		ZStack(alignment: .top) {
			scrollView
			navbarOverlay
				.ignoresSafeArea(edges: .top)
				.frame(minHeight: headerMinHeight)
		}
		.toolbarBackground(.hidden)
		.navigationBarTitleDisplayMode(.inline)
	}

	@ViewBuilder
	var navbarOverlay: some View {
		if headerVisibleRatio <= 0 {
			Color.clear
				.frame(height: navigationBarHeight)
				.overlay(scrollHeader, alignment: .bottom)
				.ignoresSafeArea(edges: .top)
		}
	}

	var scrollHeader: some View {
		ScrollViewHeader(content: header)
			.frame(height: headerHeight)
	}

	var scrollView: some View {
		GeometryReader { geo in
			ScrollViewWithOffset(onScroll: handleScrollOffset) {
				VStack(spacing: 0) {
					scrollHeader
					content()
				}
			}
			.onAppear {
				DispatchQueue.main.async {
					navigationBarHeight = geo.safeAreaInsets.top
				}
			}
		}
	}

	private var headerVisibleRatio: CGFloat {
		max(0, (headerHeight + scrollOffset.y) / headerHeight)
	}

	func handleScrollOffset(_ offset: CGPoint) {
		self.scrollOffset = offset
		self.onScroll?(offset, headerVisibleRatio)
	}

	var verticalOffset: CGFloat {
		guard headerVisibleRatio < 1 else { return 0 }
		return 70.0 * (1 - headerVisibleRatio)
	}
}
