//
//  PlayerManager.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 06/10/2023.
//

import Foundation
import Observation
import AVKit

@Observable
class PlayerManager: NSObject {
	enum State {
		case playing
		case paused
	}

	let session: AVAudioSession
	var player: AVQueuePlayer
	let downloadManager: DownloadManager

	var state: State {
		switch player.timeControlStatus {
		case .paused, .waitingToPlayAtSpecifiedRate:
			return .paused
		case .playing:
			return .playing
		default:
			return .paused
		}
	}

	enum PlayerManagerError: Error{
		case notDownloaded
	}

	init(downloadManager: DownloadManager) {
		self.downloadManager = downloadManager
		session = AVAudioSession.sharedInstance()
		player = .init(items: [])

		do {
			try session.setCategory(.playback, mode: .spokenAudio, options: .allowAirPlay)
		} catch {
			print("failed to set category on session? \(error)")
		}
	}

	func play(episode: Episode) throws {
		if let location = episode.fileURL {
			player.insert(.init(url: location), after: nil)
			try play()
		} else {
			// Download the item
			// TODO: add a streaming option for large files?	
			Task {
				try await downloadManager.scheduleDownload(episode)
				return try play(episode: episode)
			}
		}
	}

	func play() throws {
		try session.setActive(true)
		player.play()
	}

	func pause() {
		player.pause()
	}

	func forward(by amount: TimeInterval) {
		// TODO: use step(byCount:) here?
		var seekTo = player.currentTime()
		seekTo.value += Int64(amount)
		player.seek(to: seekTo, toleranceBefore: .zero, toleranceAfter: .zero)
	}
	func rewind(by amount: TimeInterval) {
		var seekTo = player.currentTime()
		seekTo.value -= Int64(amount)
		player.seek(to: seekTo, toleranceBefore: .zero, toleranceAfter: .zero)
	}

	func enqueue(_ episode: Episode) async throws {
		// TODO: enable streaming from file here
		if !episode.downloaded {
			try await downloadManager.scheduleDownload(episode)
		}

		guard let location = episode.fileLocation else {
			print("episode didn't have a file location, can't enqueue...")
			throw PlayerManagerError.notDownloaded
		}

		player.insert(.init(url: URL.documentsDirectory.appending(path: location)), after: player.items().last)
	}
}
