//
//  TrollAppsApp.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
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
                NavView()
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
