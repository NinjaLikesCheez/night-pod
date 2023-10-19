//
//  PodcastView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 01/10/2023.
//

// TODO: do this https://danielsaidi.com/blog/2023/02/09/adding-a-sticky-header-to-a-swiftui-scroll-view

import SwiftUI
import CachedAsyncImage

struct PodcastDetailView: View {
	let podcast: Podcast

	@Environment(DownloadManager.self) var downloadManager
	@Environment(PlayerManager.self) var playerManager

	@State private var filter: PodcastDetailViewFilter = .newestToOldest
	@State private var showingFilters = false

	enum PodcastDetailViewFilter {
		case newestToOldest
		case oldestToNewest
	}

	var filteredEpisodes: [Episode] {
		switch filter {
		case .oldestToNewest:
			return podcast.episodes.sorted(by: { $0.publishedDate < $1.publishedDate })
		case .newestToOldest:
			return podcast.episodes.sorted(by: { $0.publishedDate > $1.publishedDate })
		}
	}

	var body: some View {
		VStack {
			PodcastDetailHeaderView(podcast: podcast)

			Spacer()

			List {
				ForEach(filteredEpisodes) { episode in
					PodcastDetailRowView(episode: episode)
						.swipeActions(edge: .leading) {
							Button {
								Task {
									do {
										try await downloadEpisode(episode)
									} catch {
										print("download episode \(episode.title) failed: \(error)")
									}
								}
							} label: {
								Image(systemName: "arrow.down")
							}
							.tint(.green)

							Button {
								Task {
									do {
										try await playerManager.enqueue(episode)
									} catch {
										print("enqueue error: \(error)")
									}
								}
							} label: {
								Image(systemName: "tray.full")
							}
						}
						.onTapGesture {
							do {
								try playerManager.play(episode: episode)
							} catch {
								print("play error: \(error)")
							}
						}
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					showingFilters = true
				} label: {
					Image(systemName: "line.3.horizontal.decrease.circle")
				}
				.confirmationDialog("Select a filter", isPresented: $showingFilters) {
					Button("Newest First") { filter = .newestToOldest }
					Button("Oldest First") { filter = .oldestToNewest }
				} message: {
					Text("Select a new filter")
				}
			}

			ToolbarItem(placement: .topBarTrailing) {
				Button {
					downloadAllEpisodes()
				} label: {
					downloadManager.currentDownloadCount > 0
					? Image(systemName: "checkmark.circle")
					: Image(systemName: "arrow.down.circle.dotted")
				}
			}
		}
	}

	func downloadAllEpisodes() {
		podcast.episodes
			.filter { downloadManager.isDownloading(episode: $0) }
			.forEach { episode in
				Task {
					do {
						try await downloadManager.scheduleDownload(episode)
					} catch {
						print("schedule episode download failure: \(error). Episode: \(episode.title)")
					}
				}
			}
	}

	func downloadEpisode(_ episode: Episode) async throws {
		try await downloadManager.scheduleDownload(episode)
	}
}

struct PodcastDetailHeaderView: View {
	let podcast: Podcast

	var body: some View {
		HStack {
			CachedAsyncImage(
				url: podcast.imageURL,
				content: { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(maxWidth: 200, maxHeight: 200)
						.cornerRadius(25)
				},
				placeholder: {
					ProgressView()
						.aspectRatio(contentMode: .fit)
						.frame(maxWidth: 200, maxHeight: 200)
				}
			)
		}

		VStack {
			Text(podcast.title)
				.bold()
		}
	}
}

struct PodcastDetailRowView: View {
	var episode: Episode

	var body: some View {
		VStack {
			HStack {
				Text(episode.title)
				Spacer()
				Text(episode.publishedDate.podcastDetailRowString())
			}

			// TODO: This could be HTML, if so it should be formatted appropriately
			Text(episode.episodeDescription)
				.lineLimit(2)
				.font(.subheadline)
				.foregroundStyle(.gray)
		}
	}
}

private extension Date {
	func podcastDetailRowString() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d, yyyy"

		guard
			// Euro centralism :eyes:
			let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year,
			let dateYear = Calendar(identifier: .gregorian).dateComponents([.year], from: self).year,
			currentYear == dateYear
		else {
			return formatter.string(from: self)
		}

		formatter.dateFormat = "MMM d"
		return formatter.string(from: self)
	}
}
