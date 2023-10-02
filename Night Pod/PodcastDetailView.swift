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

	@State private var filter: PodcastDetailViewFilter = .decreasing
	@State private var showingFilters = false

	enum PodcastDetailViewFilter {
		case increasing
		case decreasing
//		TODO: Implement
//		case recent
	}

	var filteredEpisodes: [PodcastEpisode] {
		switch filter {
		case .increasing:
			return podcast.episodes.sorted(by: { $0.publishedDate < $1.publishedDate })
		case .decreasing:
			return podcast.episodes.sorted(by: { $0.publishedDate > $1.publishedDate })
		}
	}

	var body: some View {
		VStack {
			PodcastDetailHeaderView(podcast: podcast)

			Spacer()

			List {
				ForEach(filteredEpisodes) { episode in
					Text(episode.title)
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					showingFilters = true
				} label: {
					Image(systemName: "line.3.horizontal.decrease.circle")
				}
				.confirmationDialog("Select a filter", isPresented: $showingFilters) {
					Button("Increasing") { filter = .increasing }
					Button("Decreasing") { filter = .decreasing }
				} message: {
					Text("Select a new filter")
				}
			}
		}
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
