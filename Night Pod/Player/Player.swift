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
	case rewind(manager: PlayerManager, amount: TimeInterval)
	case playPause(manager: PlayerManager)
	case forward(manager: PlayerManager, skip: TimeInterval)

	var body: some View {
		switch self {
		case .rewind(let manager, let amount):
			Button {
				manager.rewind(by: amount)
			} label: {
				Image(systemName: "backward.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
					.frame(height: 40)
			}
		case .playPause(let manager):
			Button {
				do {
					manager.state == .paused ? try manager.play() : manager.pause()
				} catch {
					print("play error: \(error)")
				}
			} label: {
				Image(systemName: manager.state == .paused ? "play.fill" : "pause.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
					.frame(height: 45)
			}
		case .forward(let manager, let amount):
			Button {
				manager.forward(by: amount)
			} label: {
				Image(systemName: "forward.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
					.frame(height: 40)
			}
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
			MediaButton.rewind(manager: manager, amount: skipTimeInterval)
			MediaButton.playPause(manager: manager)
			MediaButton.forward(manager: manager, skip: skipTimeInterval)
			Spacer()
			Button {
				// TODO: Enable Player to drag up into a sheet that has icon art etc
			} label: {
				CachedAsyncImage
			}
		}
		.frame(maxWidth: .infinity, maxHeight: 60)
	}
}

#Preview {
	Player()
}
