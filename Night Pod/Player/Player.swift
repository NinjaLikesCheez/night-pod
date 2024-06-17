//
//  MediaPlayer.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 03/10/2023.
//

import Foundation
import SwiftUI
import Observation
import AVKit

enum MediaButton: View {
	case rewind(manager: PlayerManager, amount: Double)
	case playPause(manager: PlayerManager)
	case forward(manager: PlayerManager, amount: Double)

	var imageName: String {
		switch self {
		// TODO: make this use the skip interval amount to determine the image (or use generic)
		case .forward: return "goforward.15"
		case .rewind: return "gobackward.15"
		case .playPause(let manager):
			return manager.isPlaying ? "pause.fill" : "play.fill"
		}
	}

	var height: CGFloat {
		switch self {
		case .forward, .rewind: return 40
		case .playPause: return 45
		}
	}

	var body: some View {
		Button {
			switch self {
			case let .forward(manager, amount), let .rewind(manager, amount):
				manager.seek(by: amount)
			case let .playPause(manager):
				do {
					try manager.toggle()
				} catch {
					print("player error: \(error)")
				}
			}
		} label: {
			Image(systemName: imageName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.padding(.horizontal, 20)
				.padding(.vertical, 10)
				.frame(height: height) // TODO: 45 for play pause
		}
	}
}

struct Player: View {
	@Environment(PlayerManager.self) var manager
	@State var currentEpisode: Episode?

	let skipTimeInterval = 15.0

	var mediaControls: some View {
		Group {
			MediaButton.rewind(manager: manager, amount: -skipTimeInterval)
			MediaButton.playPause(manager: manager)
			MediaButton.forward(manager: manager, amount: skipTimeInterval)
		}
	}

	var mediaImage: some View {
		Button {
			// TODO: Enable Player to drag up into a sheet that has icon art etc
		} label: {
			//				CachedAsyncImage
		}
	}

	var body: some View {
		ZStack {
			HStack {
				mediaControls
			}
			mediaImage
		}
		.frame(maxWidth: .infinity, minHeight: 40, maxHeight: 60)
	}
}

#Preview {
	Player()
}
