//
//  TrollAppsApp.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

@main
struct TrollAppsApp: App {
    @StateObject private var repoManager = RepositoryManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repoManager)
                .onAppear {
                    if !repoManager.hasFetchedRepos {
                        repoManager.fetchRepos()
                    }
                }
        }
    }
}
