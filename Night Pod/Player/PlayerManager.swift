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
	private var session = with(AVAudioSession.sharedInstance()) {
		try? $0.setCategory(.playback, mode: .spokenAudio, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
	}
	private let player = AVQueuePlayer(items: [])
	private let downloadManager: DownloadManager

	var state: State = .paused

	init(downloadManager: DownloadManager) {
		self.downloadManager = downloadManager
	}

	func toggle() throws {
		switch state {
		case .playing:
			try pause()
		case .paused:
			try play()
		}
	}

	func play(_ episode: Episode) async throws {
		if !episode.downloaded {
			try await downloadManager.scheduleDownload(episode)
		}

		guard let fileURL = episode.fileURL else { throw Error.notDownloaded }

		try pause()
		let newItem = AVPlayerItem(url: fileURL)
		if let item = player.items().first {
			player.insert(newItem, after: item)
			player.remove(item)
			player.insert(item, after: newItem)
		} else {
			player.insert(newItem, after: nil)
		}
		try play()
	}

	func play() throws {
		try session.setActive(true)
		state = .playing
		player.play()
	}

	func pause() throws {
		try session.setActive(false, options: .notifyOthersOnDeactivation)
		state = .paused
		player.pause()
	}

	func seek(by amount: Double) {
		guard let duration = player.currentItem?.duration else { return }
		let currentTime = player.currentTime().seconds
		let seekedTime = currentTime + amount

		if seekedTime < duration.seconds {
			player.seek(to: CMTimeMake(value: Int64(seekedTime * 1000), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
		}
	}

	func enqueue(_ episode: Episode) async throws {
		// TODO: enable streaming from file here
		if !episode.downloaded {
			try await downloadManager.scheduleDownload(episode)
		}

		guard let location = episode.fileLocation else {
			print("episode didn't have a file location, can't enqueue...")
			throw Error.notDownloaded
		}

		player.insert(.init(url: URL.documentsDirectory.appending(path: location)), after: nil)
	}
}

extension PlayerManager {
	enum State {
		case playing
		case paused
	}

	enum Error: Swift.Error{
		case notDownloaded
	}
}
