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
final class Podcast {
	@Attribute(.unique) 
	let title: String
	let channelDescription: String
	let link: URL?
	let imageURL: URL?
	let guid: UUID
	let owner: String?
	let category: String?
	var isFavorited: Bool

	let episodes: [Episode]

	private init(_ feed: RSSFeed) {
		title = feed.title ?? "No Title Provided"
		channelDescription = feed.description ?? "No Description Provided"
		link = feed.link != nil ? URL(string: feed.link!) : nil
		owner = feed.iTunes?.iTunesOwner?.name ?? feed.managingEditor
		category = feed.iTunes?.iTunesCategories?.first?.attributes?.text

		if let image = feed.image, let url = image.url {
			imageURL = URL(string: url)
		}

		guid = .init()
		episodes = (feed.items ?? [])
			.map { .init($0) }
		isFavorited = false
	}

	static func from(url: URL) async throws -> Podcast {
		enum Error: Swift.Error {
			case decodeError
			case incorrectFeedType
		}

		// Decode XML to Podcast
		let (data, _) = try await URLSession.shared.data(from: url)
		let feed = FeedParser(data: data).parse()

		switch feed {
		case .success(let feed):
			switch feed {
			case .rss(let rssFeed):
				let podcast = Podcast(rssFeed)
//				podcast.episodes.forEach { $0.podcast = podcast }
				return podcast
			default: throw Error.incorrectFeedType
			}
		case .failure(let error):
			print("Feed Parser error: \(error)")
			throw Error.decodeError
		}
	}
}
