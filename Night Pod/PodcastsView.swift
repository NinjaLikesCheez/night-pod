//
//  ContentView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 30/09/2023.
//

import SwiftUI
import SwiftData
import CachedAsyncImage

struct EmptyPodcastsView: View {
	@Environment(\.modelContext) private var modelContext
	@State var podcast: Podcast?
	private let recommendedPodcastURL = URL(string: "https://audioboom.com/channels/2399216.rss")!

	var body: some View {
		VStack {
			Text("No Podcasts")
				.font(.largeTitle)
				.foregroundStyle(.tertiary)
		
			Text("Add one with the plus button!")
				.font(.footnote)
				.foregroundStyle(.tertiary)
				.padding(.bottom, 50)

			if let podcast {
				Button {
					Task {
						modelContext.insert(podcast)
					}
				} label: {
					CachedAsyncImage(
						url: podcast.imageURL,
						content: { image in
							image
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(maxWidth: 100, maxHeight: 100)
								.cornerRadius(25)
						},
						placeholder: {
							ZStack {
								ProgressView()
									.aspectRatio(contentMode: .fit)
									.frame(maxWidth: 100, maxHeight: 100)
							}
						}
					)
				}
				Text("How about this one?")
					.foregroundStyle(.tertiary)
			}
		}
		.task {
			self.podcast =  try? await Podcast.from(url: recommendedPodcastURL)
		}
	}
}

struct PodcastsView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var podcasts: [Podcast] = []
	@State private var showingAlert = false

	var podcastsList: some View {
		List {
			ForEach(podcasts) { podcast in
				NavigationLink {
					EpisodesView(podcast: podcast)
				} label: {
					RowView(podcast: podcast)
				}
			}
			.onDelete(perform: deletePodcasts)
		}
	}

	var body: some View {
		NavigationSplitView {
			Group {
				if podcasts.isEmpty {
					EmptyPodcastsView()
				} else {
					podcastsList
				}
			}
			.toolbar {
				if !podcasts.isEmpty {
					ToolbarItem(placement: .navigationBarTrailing) {
						EditButton()
					}
				}
				ToolbarItem {
					AddPodcastButton()
				}
			}
		} detail: {
			if let podcast = podcasts.first {
				EpisodesView(podcast: podcast)
			} else {
				Text("Add a pocast ^^")
			}
		}
	}

	private func deletePodcasts(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(podcasts[index])
			}
		}
	}
}

struct RowView: View {
	let podcast: Podcast

	var body: some View {
		HStack {
			CachedAsyncImage(
				url: podcast.imageURL,
				content: { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(maxWidth: 100, maxHeight: 100)
						.cornerRadius(25)
				},
				placeholder: {
					ZStack {
						ProgressView()
							.aspectRatio(contentMode: .fit)
							.frame(maxWidth: 100, maxHeight: 100)
					}
				}
			)

			Text(podcast.title)
				.bold()
		}

	}
}

//#Preview {
//	PodcastsView(podcasts: [])
//		.environment(PodcastManager())
////		.modelContainer(for: Podcast.self, inMemory: true)
//}

struct AddPodcastButton: View {
	@Environment(\.modelContext) private var modelContext
	@State private var showingAlert = false
	@State private var podcastURLString: String = ""

	var body: some View {
		Button {
			showingAlert = true
		} label: {
			Label("Add Item", systemImage: "plus")
		}
		.alert("Enter Podcast URL", isPresented: $showingAlert) {
			TextField("Enter podcast URL", text: $podcastURLString)
			Button("Add", action: addPodcast)
		} message: {
			Text("This should be an RSS feed")
		}
	}

	private func addPodcast() {
		guard
			let podcastURL = URL(string: podcastURLString)
		else {
			print("addPodcast URL Validation error: \(podcastURLString)")
			return
		}

		Task {
			do {
				modelContext.insert(try await Podcast.from(url: podcastURL))
			} catch {
				print("addPodcast - PodcastChannel init error: \(error)")
			}
		}
	}
}
