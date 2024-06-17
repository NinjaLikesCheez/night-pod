//
//  CoverHeaderView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI
import Kingfisher

struct CoverHeaderView: View {
	let podcast: Podcast

	static var height: CGFloat = 280
	private var headerVisibleRatio: CGFloat

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
		KFImage(podcast.imageURL)
			.placeholder({ ImagePlaceholderView() })
			.resizable()
			.aspectRatio(contentMode: .fit)
			.cornerRadius(5)
			.shadow(radius: 10)
			.rotation3DEffect(.degrees(rotationDegrees), axis: (x: 1, y: 0, z: 0))
			.offset(y: verticalOffset)
			.padding(.top, 60)
			.padding(.bottom, 20)
			.padding(.horizontal, 20)
	}
}
