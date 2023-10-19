//
//  Night_PodApp.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 30/09/2023.
//

import SwiftUI
import SwiftData

@main
struct Night_PodApp: App {
	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			Podcast.self,
			Episode.self
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var downloadManager = DownloadManager()
	var playerManager: PlayerManager

	init() {
		playerManager = PlayerManager(downloadManager: downloadManager)
	}

	var body: some Scene {
		WindowGroup {
			VStack {
				PodcastsView()
//				if playerManager.state == .playing {
					Player()
//				}
			}
		}
		.environment(playerManager)
		.environment(downloadManager)
		.modelContainer(sharedModelContainer)
	}
}
