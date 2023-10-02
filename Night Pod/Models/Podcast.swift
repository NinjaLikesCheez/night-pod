//
//  PodcastChannel.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 30/09/2023.
//

import Foundation
import SwiftData
import XMLCoder
import FeedKit

@Model
final class PodcastMediaContent {
	let imageURL: URL?
	let audioURL: URL?

	init(_ content: MediaContent) {
		//image | audio
		if content.attributes?.medium == "image", let urlString = content.attributes?.url {
			imageURL = URL(string: urlString)
		}
		
		if content.attributes?.medium == "audio", let urlString = content.attributes?.url {
			audioURL = URL(string: urlString)
		}
	}
}

@Model
final class PodcastEpisode {
	let title: String
	let link: URL?
	// TODO: model season, episode, and special (/none) episode numbering
	let episodeNumber: Int
	let episodeDescription: String
	let guid: UUID
	let publishedDate: Date
	let mediaContents: [PodcastMediaContent]

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
	}
}

@Model
final class Podcast {
	@Attribute(.unique) 
	let title: String
	let channelDescription: String
	let link: URL?
	let imageURL: URL?
	let guid: UUID


	@Relationship(.unique, deleteRule: .cascade)
	let episodes: [PodcastEpisode]

	init(_ feed: RSSFeed) {
		title = feed.title ?? "No Title Provided"
		channelDescription = feed.description ?? "No Description Provided"
		link = feed.link != nil ? URL(string: feed.link!) : nil

		if let image = feed.image, let url = image.url {
			imageURL = URL(string: url)
		}

		guid = .init()
		episodes = (feed.items ?? [])
			.map { .init($0) }
	}

	static func from(url: URL) async throws -> Podcast {
		enum Error: Swift.Error {
			case decodeError
			case incorrectFeedType
		}

		// Decode XML to Podcast
		let (data, _) = try await URLSession.shared.data(from: url)
		#if DEBUG
		print("podcast data: \(String(data: data, encoding: .utf8)!)")
		#endif
		let feed = FeedParser(data: data).parse()

		switch feed {
		case .success(let feed):
			switch feed {
			case .rss(let rssFeed):
				return Podcast(rssFeed)
			default: throw Error.incorrectFeedType
			}
		case .failure(let error):
			print("Feed Parser error: \(error)")
			throw Error.decodeError
		}
	}
}
