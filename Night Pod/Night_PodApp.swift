//
//  Night_PodApp.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 30/09/2023.
//

import SwiftUI
import SwiftData
import Kingfisher

@main
struct Night_PodApp: App {
	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			Podcast.self,
			Episode.self
		])

		do {
			return try ModelContainer(
				for: schema,
				configurations: [
					.init(schema: schema, isStoredInMemoryOnly: false)
				]
			)
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var playerManager = PlayerManager(downloadManager: DownloadManager())

	init() {
		KingfisherManager.shared.defaultOptions = [.backgroundDecode]
	}

	var body: some Scene {
		WindowGroup {
			VStack {
				PodcastsView()
				if playerManager.isActive {
					Player()
				}
			}
		}
		.environment(playerManager)
		.modelContainer(sharedModelContainer)
	}
}
