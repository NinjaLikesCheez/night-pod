//
//  EpisodesView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI
import CachedAsyncImage

struct EpisodesView: View {
	@Environment(PlayerManager.self) var player
	let podcast: Podcast

	@State private var filter: Filter = .newestToOldest
	@State private var isShowingFilters = false

	var body: some View {
		NavigationStack {
			ScrollView {
				header
				content
			}
		}
	}

	var header: some View {
		ScrollViewHeader {
			ZStack {
				LinearGradient(
					colors: [.clear, .clear], // TODO: update this to primary color of the image
					startPoint: .top,
					endPoint: .bottom
				)

				CachedAsyncImage(
					url: podcast.imageURL,
					content: { image in
						image
							.resizable()
							.aspectRatio(contentMode: .fit)
					},
					placeholder: {
						ZStack {
							ProgressView()
								.aspectRatio(contentMode: .fit)
						}
					}
				)
				.aspectRatio(1, contentMode: .fit)
				.cornerRadius(5)
				.shadow(radius: 10)
				.padding(.top, 60)
				.padding(.horizontal, 20)
			}
		}
		.frame(height: 280)
	}

	var content: some View {
		VStack(spacing: 20) {
			title
			buttons
			list
		}
		.padding()
	}

	var subtitle: String {
		[podcast.owner, podcast.category]
			.compactMap { $0 }
			.joined(separator: " · ")
	}


	var title: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(podcast.title)
				.bold()
				.font(.title2)
				.frame(maxWidth: .infinity, alignment: .leading)

			Text(subtitle)
				.bold()
				.font(.footnote)
				.foregroundColor(.secondary)
		}
	}

	var buttons: some View {
		HStack(spacing: 15) {
			favouriteButton
			// TODO: make this popup a menu showing the size and number of episodes that will be downloaded with a confirmation
			Image(systemName: "arrow.down.circle")
			filterButton
			Image(systemName: "ellipsis")
			Spacer()
			Image(systemName: "shuffle")
			Image(systemName: "play.circle.fill")
				.font(.largeTitle)
				.foregroundColor(.green)
		}
		.font(.title3)
	}

	var favouriteButton: some View {
		Button {
			podcast.isFavorited.toggle()
		} label: {
			Image(systemName: podcast.isFavorited ? "heart.fill" : "heart")
		}
		.foregroundStyle(podcast.isFavorited ? .red : .primary)
	}

	var list: some View {
		LazyVStack(alignment: .leading, spacing: 30) {
			ForEach(filteredEpisodes) { episode in
				listItem(episode)
					.onTapGesture {
						// TODO: handler error
						Task {
							try await player.play(episode)
						}
					}
			}
		}
	}

	func listItem(_ episode: Episode) -> some View {
		HStack {
			VStack {
				Text(episode.titleWithNumber)
					.font(.headline)
				// TODO: figure out how to report progress on a @Model
				if episode.progress > 0 {
					Text("\(episode.progress)% downloaded")
				}
			}
		}
	}

	func listItemImage(_ episode: Episode) -> some View {
		CachedAsyncImage(
			url: episode.episodeImageURL,
			content: { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
			},
			placeholder: {
				ZStack {
					ProgressView()
						.aspectRatio(contentMode: .fit)
				}
			}
		)
		.cornerRadius(5)
	}
}

// MARK: - Filter behaviour
extension EpisodesView {
	enum Filter: CaseIterable {
		case newestToOldest
		case oldestToNewest

		var title: String {
			switch self {
			case .newestToOldest: return "Newest First"
			case .oldestToNewest: return "Oldest First"
			}
		}
	}

	var filteredEpisodes: [Episode] {
		switch filter {
		case .newestToOldest: return podcast.episodes.sorted(by: { $0.publishedDate > $1.publishedDate })
		case .oldestToNewest: return podcast.episodes.sorted(by: { $0.publishedDate < $1.publishedDate })
		}
	}

	var filterButton: some View {
		Menu {
			Button {
				filter = .newestToOldest
			} label: {
				HStack {
					Text(filter.title)
					if filter == .newestToOldest {
						Image(systemName: "checkmark")
					}
				}
			}

			Button {
				filter = .oldestToNewest
			} label: {
				HStack {
					Text(filter.title)
					if filter == .oldestToNewest {
						Image(systemName: "checkmark")
					}
				}
			}
		} label: {
			Image(systemName: "line.3.horizontal.decrease.circle")
		}
		.foregroundStyle(.primary)
	}
}
