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
		case .forward: return "forward.fill"
		case .rewind: return "backward.fill"
		case .playPause(let manager):
			return manager.state == .paused ? "play.fill" : "pause.fill"
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
				.frame(height: 40) // TODO: 45 for play pause
		}
	}
}

struct Player: View {
	@Environment(PlayerManager.self) var manager
	@State var currentEpisode: Episode?

	let skipTimeInterval = 10.0

	var body: some View {
		HStack {
			Button {
				// TODO: Enable Player to drag up into a sheet that has icon art etc
			} label: {
				Image(systemName: "chevron.up")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
					.frame(height: 40)
			}
			Spacer()
			MediaButton.rewind(manager: manager, amount: -skipTimeInterval)
			MediaButton.playPause(manager: manager)
			MediaButton.forward(manager: manager, amount: skipTimeInterval)
			Spacer()
			Button {
				// TODO: Enable Player to drag up into a sheet that has icon art etc
			} label: {
//				CachedAsyncImage
			}
		}
		.frame(maxWidth: .infinity, maxHeight: 60)
	}
}

#Preview {
	Player()
}
