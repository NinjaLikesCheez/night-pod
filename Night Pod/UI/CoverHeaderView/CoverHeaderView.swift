//
//  CoverHeaderView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI
import CachedAsyncImage

struct CoverHeaderView: View {
	// TODO: make DTO for this
	let podcast: Podcast

	static var height: CGFloat = 280
	private var headerVisibleRatio: CGFloat

	init(podcast: Podcast, headerVisibleRatio: CGFloat = 1) {
		self.podcast = podcast
		self.headerVisibleRatio = headerVisibleRatio
	}

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [.brown, .black],
				startPoint: .top,
				endPoint: .bottom
			)

			cover
		}
	}

	var rotationDegrees: CGFloat {
		guard headerVisibleRatio > 1 else { return 0 }
		let value = 20.0 * (1 - headerVisibleRatio)
		return value.capped(to: -5...0)
	}

	var verticalOffset: CGFloat {
		guard headerVisibleRatio < 1 else { return 0 }
		return 70.0 * (1 - headerVisibleRatio)
	}

	var cover: some View {
		CachedAsyncImage(
			url: podcast.imageURL,
			content: { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
			},
			placeholder: {
				ZStack {
					ProgressView()
						.aspectRatio(contentMode: .fit)
				}
			}
		)
		.aspectRatio(1, contentMode: .fit)
		.cornerRadius(5)
		.shadow(radius: 10)
		.rotation3DEffect(.degrees(rotationDegrees), axis: (x: 1, y: 0, z: 0))
		.offset(y: verticalOffset)
		.padding(.top, 60)
		.padding(.bottom, 20)
		.padding(.horizontal, 20)
	}
}

private extension CGFloat {
	func capped(to range: ClosedRange<Self>) -> Self {
		if self < range.lowerBound { return range.lowerBound }
		if self > range.upperBound { return range.upperBound }
		return self
	}
}
