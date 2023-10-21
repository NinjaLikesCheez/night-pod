//
//  EpisodesView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 19/10/2023.
//

import SwiftUI
import CachedAsyncImage

struct EpisodesView: View {
	let podcast: Podcast

	var body: some View {
		NavigationStack {
			ScrollView {
				header
				content
			}
		}
	}

	var header: some View {
		// TODO: Continue with this: https://github.com/danielsaidi/ScrollKit/blob/main/Sources/ScrollKit/Previews/SpotifyPreviewScreen.swift#L33
		ScrollViewHeader {
			ZStack {
				LinearGradient(
					colors: [.brown, .black],
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

	var title: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(podcast.title)
				.bold()
				.font(.title2)
				.frame(maxWidth: .infinity, alignment: .leading)
			
			Text("Subtitle")
				.bold()
				.font(.footnote)

			Text("Producer · Release")
				.bold()
				.font(.footnote)
				.foregroundColor(.secondary)
		}
	}

	var buttons: some View {
		HStack(spacing: 15) {
			Image(systemName: "heart")
			Image(systemName: "arrow.down.circle")
			Image(systemName: "ellipsis")
			Spacer()
			Image(systemName: "shuffle")
			Image(systemName: "play.circle.fill")
				.font(.largeTitle)
				.foregroundColor(.green)
		}
		.font(.title3)
	}

	var list: some View {
		LazyVStack(alignment: .leading, spacing: 30) {
			ForEach(podcast.episodes) { episode in
				listItem(episode)
			}
		}
	}

	func listItem(_ episode: Episode) -> some View {
		VStack(alignment: .leading) {
			Text(episode.title)
				.font(.headline)
			Text(episode.episodeDescription)
				.font(.footnote)
				.foregroundColor(.secondary)
		}
	}
}
