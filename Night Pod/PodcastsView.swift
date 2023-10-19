//
//  ContentView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 30/09/2023.
//

import SwiftUI
import SwiftData
import CachedAsyncImage

struct PodcastsView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var podcasts: [Podcast] = []
	@State private var showingAlert = false

	var body: some View {
		NavigationSplitView {
			List {
				ForEach(podcasts) { podcast in
					NavigationLink {
						PodcastDetailView(podcast: podcast)
					} label: {
						RowView(podcast: podcast)
					}
				}
				.onDelete(perform: deletePodcasts)
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					EditButton()
				}
				ToolbarItem {
					AddPodcastButton()
				}
			}
		} detail: {
			if let podcast = podcasts.first {
				PodcastDetailView(podcast: podcast)
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
//				modelContext.insert(try await Podcast.from(url: URL(string: "https://audioboom.com/channels/2399216.rss")!))
			} catch {
				print("addPodcast - PodcastChannel init error: \(error)")
			}
		}
	}
}
