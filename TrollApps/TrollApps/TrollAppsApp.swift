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

//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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


//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        if url.scheme == "trollapps" {
//            handleTrollAppsURL(url)
//            return true
//        }
//        return false
//    }
//
//    func handleTrollAppsURL(_ url: URL) {
//    print(url)
//        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
//           let queryItems = components.queryItems {
//            for item in queryItems {
//                if item.name == "url" {
//                    if let urlString = item.value, let url = URL(string: urlString) {
//                        print("Received URL: \(url)")
//                    }
//                }
//            }
//        }
//    }
//}
