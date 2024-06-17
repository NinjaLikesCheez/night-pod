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

	var state: State = .stopped

	init(downloadManager: DownloadManager) {
		self.downloadManager = downloadManager
	}

	func toggle() throws {
		switch state {
		case .playing:
			try pause()
		case .paused:
			try play()
		case .stopped:
			break
		}
	}

	var isPlaying: Bool {
		switch state {
		case .playing:
			true
		case .paused:
			false
		case .stopped:
			false
		}
	}

	var isActive: Bool {
		state != .stopped
	}

	func play(_ episode: Episode) throws {
		// Stream if
		let url: URL
		if let location = episode.fileURL {
			url = location
		} else if let audioURL = episode.audioURL {
			url = audioURL
		} else {
			throw Error.noAudioURL
		}

		try pause()
		let newItem = AVPlayerItem(url: url)
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

	func enqueue(episode: Episode) throws {
		// Stream if not already downloaded
		guard let location = episode.fileLocation else {
			guard let audioURL = episode.audioURL else {
				throw Error.noAudioURL
			}

			player.insert(.init(url: audioURL), after: nil)
			return
		}

		player.insert(.init(url: URL.documentsDirectory.appending(path: location)), after: nil)
	}

	func enqueue(episodes: [Episode]) throws {
		try episodes.forEach { try enqueue(episode: $0) }
	}
}

extension PlayerManager {
	enum State {
		case playing
		case paused
		case stopped
	}

	enum Error: Swift.Error{
		case notDownloaded
		case noAudioURL
	}
}
