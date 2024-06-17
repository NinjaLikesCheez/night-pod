//
//  EpisodesView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI
import Kingfisher

struct EpisodesView: View {
	@Environment(PlayerManager.self) var player
	let podcast: Podcast

	@State private var filter: Filter = .newestToOldest
	@State private var isShowingFilters = false
	@State private var isShowingAlert = false
	@State private var alertMessage = ""

	var body: some View {
		NavigationStack {
			ScrollView {
				header
				content
			}
			.alert(isPresented: $isShowingAlert) {
				Alert(title: Text("Error!"), message: Text(alertMessage))
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

				KFImage(podcast.imageURL)
					.placeholder({ ImagePlaceholderView() })
					.resizable()
					.aspectRatio(contentMode: .fit)
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
			shuffleButton
			Image(systemName: "play.circle.fill")
				.font(.largeTitle)
				.foregroundColor(.green)
		}
		.font(.title3)
	}

	var shuffleButton: some View {
		Button {
			shuffleButtonPressed()
		} label: {
			Image(systemName: "shuffle")
		}
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
						do {
							try player.play(episode)
						} catch {
							isShowingAlert = true
							alertMessage = "Play error: \(error.localizedDescription)"
						}
					}
			}
		}
	}

	func listItemSubtitle(_ episode: Episode) -> String {
		// TODO: add downloading and progress...
		"\(episode.publishedDate.shortDateString()) \(episode.downloaded ? "· Downloaded" : "")"
	}

	func listItem(_ episode: Episode) -> some View {
		HStack {
			listItemImage(episode)

			VStack(alignment: .leading) {
				Text(episode.titleWithNumber)
					.font(.headline)
				// TODO: figure out how to report progress on a @Model
				Text(listItemSubtitle(episode))
					.font(.footnote)
					.foregroundStyle(.tertiary)
				if episode.progress > 0 {
					Text("\(episode.progress)% downloaded")
				}
			}
		}
	}

	func listItemImage(_ episode: Episode) -> some View {
		KFImage(episode.episodeImageURL)
			.placeholder({ ImagePlaceholderView() })
			.cancelOnDisappear(true)
			.downsampling(size: CGSize(width: 100, height: 100))
			.resizable()
			.aspectRatio(contentMode: .fit)
			.cornerRadius(5)
			.frame(width: 50, height: 50)
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

// MARK: Shuffle Button Behaviour
extension EpisodesView {
	func shuffleButtonPressed() {
		// TODO: add other shufflers here and get which to use from a config class you've yet to make.
//		let shuffler = RandomShuffle(items: podcast.episodes)
		let shuffler = MillerShuffle(items: podcast.episodes)

		do {
			try player.enqueue(episodes: shuffler.shuffle())
			try player.play()
		} catch {
			// TODO: handle errors better
			isShowingAlert = true
			alertMessage = "Enque error: \(error.localizedDescription)"
		}
	}
}

// MARK: Download Button Behaviour
