//
//  AppDelegate.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-04.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var repoManager: RepositoryManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Hit 1")
        self.launchOptions = launchOptions
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("Hit 2")

        guard let scheme = url.scheme, scheme == "trollapps" else { return false }

        if url.host == "add" {
            if let repoURL = url.queryParameters?["repo"] {
                guard let repoManager = self.repoManager else { return false }

                repoManager.addRepo(repoURL) {
                    print("Added Repo: " + repoURL)
                }
                return true
            }
        }

        return false
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }

        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}
