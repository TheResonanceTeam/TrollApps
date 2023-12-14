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
    @StateObject private var alertManager = AlertManager()
    @StateObject private var userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .zIndex(2)
                AlertManagerView()
                    .zIndex(3)
            }
            .environment(\.locale, .init(identifier: userSettings.lang))
            .environmentObject(repoManager)
            .environmentObject(alertManager)
            .environmentObject(userSettings)
            .onAppear {
                if !repoManager.hasFetchedRepos {
                    repoManager.fetchRepos()
                }
            }
        }
    }
}
