//
//  DownloadManager.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 02/10/2023.
//

import Foundation
import Observation

@Observable
class Download: NSObject {
	enum State {
		case notStarted
		case inProgress
		case finished
		case failed(Error)
	}

	let url: URL
	var state: State = .notStarted
	var progress: Int = 0
	let episode: Episode
	let session: URLSession

	// TODO: Use NSProgress for progress tracking
	init(_ url: URL, session: URLSession, episode: Episode) {
		self.url = url
		self.session = session
		self.episode = episode
	}

	func download() async throws {}

	func move(from path: URL) {
		do {
			guard let podcastDirectory = URL(string: "Podcast", relativeTo: URL.documentsDirectory) else {
				print("failed to make link to podcast directory")
				return
			}

			if !FileManager.default.fileExists(atPath: podcastDirectory.path) {
				try FileManager.default.createDirectory(at: podcastDirectory, withIntermediateDirectories: true)
			}

			let newFileLocation = podcastDirectory.appending(path: episode.title)
			if FileManager.default.fileExists(atPath: newFileLocation.path) {
				try FileManager.default.removeItem(at: newFileLocation)
			}
			try FileManager.default.moveItem(at: path, to: newFileLocation)
			episode.fileLocation = newFileLocation.relativePath
		} catch {
			print("move download error: \(error)")
			state = .failed(error)
		}
	}
}

extension Download: URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		print("did finish downloading: \(location)")
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		let progress = Int(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100)
		print("progress: \(progress)")
	}
}

@Observable
class DownloadManager: NSObject {
	private var session: URLSession = .init(
		configuration: .default
//		configuration: .background(withIdentifier: "kim.cracksby.Night-Pod.background")
	)
	private var manager: FileManager = .default
	private var active: [URL: Episode] = [:]
	var currentDownloadCount: Int { active.count }

	enum Error: Swift.Error {
		case failedToSave(Swift.Error)
	}

	func isDownloading(episode: Episode) -> Bool {
		active.contains(where: { $0.value == episode })
	}

	func scheduleDownload(_ episode: Episode, force: Bool = false) async throws {
		if force, let location = episode.fileLocation {
			try manager.removeItem(at: URL.documentsDirectory.appending(path: location))
		} else if !force, episode.fileLocation != nil {
			// Don't download something that exists
			return
		}

		guard let url = episode.mediaContents.first(where: { $0.type == .audio })?.url else {
			return
		}
		active[url] = episode
		defer { active[url] = nil }

		// Use AsyncBytes so we can do progess reporting
		let (bytes, response) = try await session.bytes(from: url)

		let length = Int(response.expectedContentLength)
		var data = Data(capacity: length)

		var previousProgress = 0
		for try await byte in bytes {
			data.append(byte)
			let progress = Int((Double(data.count) / Double(length)) * 100)
			if previousProgress < progress {
				previousProgress = progress
				episode.progress = progress
				print("progress: \(progress)")
			}
		}

		try write(data, for: episode)
	}

	private func write(_ data: Data, for episode: Episode) throws {
		do {
			let documentDirectory = try manager.url(
				for: .documentDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: true
			)

			guard let podcastDirectory = URL(string: "Podcast", relativeTo: documentDirectory) else {
				print("failed to make link to podcast directory")
				return
			}

			if !manager.fileExists(atPath: podcastDirectory.path) {
				try manager.createDirectory(at: podcastDirectory, withIntermediateDirectories: true)
			}

			let newFileLocation = podcastDirectory.appending(path: "\(episode.title).mp3")

			if manager.fileExists(atPath: newFileLocation.path) {
				try manager.removeItem(at: newFileLocation)
			}

			try data.write(to: newFileLocation, options: .atomic)
			episode.fileLocation = newFileLocation.relativePath
		} catch {
			print("move download error: \(error)")
			throw Error.failedToSave(error)
		}
	}
}
