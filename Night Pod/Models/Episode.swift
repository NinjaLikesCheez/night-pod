//
//  Episode.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 02/10/2023.
//

import Foundation
import SwiftData
import FeedKit

@Model
final class PodcastMediaContent {
	enum PodcastMediaContentType: Codable {
		case image
		case audio
		case unknown
	}

	let type: PodcastMediaContentType
	let url: URL?

	init(_ content: MediaContent) {
		if content.attributes?.medium == "image" {
			type = .image
		} else if content.attributes?.medium == "audio" {
			type = .audio
		} else {
			print("unknown media content type: \(content.attributes?.medium ?? "nil")")
			type = .unknown
		}

		if let urlString = content.attributes?.url {
			url = URL(string: urlString)
		}
	}
}

@Model
final class Episode {
	let title: String
	let link: URL?
	// TODO: model season, episode, and special (/none) episode numbering
	let episodeNumber: Int
	let episodeDescription: String
	let guid: UUID
	let publishedDate: Date
	let mediaContents: [PodcastMediaContent]

	var fileLocation: String?

	@Transient
	var fileURL: URL? {
		guard let fileLocation else { return nil }
		return URL.documentsDirectory.appending(path: fileLocation)
	}

	@Transient
	var progress: Int = 0

	var downloaded: Bool {
		guard let path = fileLocation else { return false }
		return FileManager.default.fileExists(atPath: URL.documentsDirectory.appending(path: path).path)
	}

	init(_ item: RSSFeedItem) {
		title = item.iTunes?.iTunesTitle ?? item.title ?? "No Title Provided"
		if let urlString = item.link, let url = URL(string: urlString) {
			link = url
		}
		episodeNumber = item.iTunes?.iTunesEpisode ?? 0
		episodeDescription = item.description ?? "No Description Provided"
		if let value = item.guid?.value, let uuid = UUID(uuidString: value) {
			guid = uuid
		} else {
			guid = UUID()
		}
		publishedDate = item.pubDate ?? Date()
		mediaContents = (item.media?.mediaContents ?? []).map { .init($0) }
		progress = 0
	}
}
