//
//  NavView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import SwiftUI

struct NavView: View {
    
    @State private var selectedTab = 0
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        TabView(selection: $selectedTab) {
            FeaturedView()
                .tabItem {
                    Label("FEATURED", systemImage: "star.fill")
                }
                .tag(0)
            NewsView()
                .tabItem {
                    Label("NEWS", systemImage: "newspaper.fill")
                }
                .tag(1)
            SourcesView()
                .tabItem {
                    Label("REPOS", systemImage: "shippingbox")
                }
                .tag(2)
            AppsView()
                .tabItem {
                    Label("APPS", systemImage: "app")
                }
                .tag(3)
            BrowseView()
                .tabItem {
                    Label("BROWSE", systemImage: "magnifyingglass")
                }
                .tag(4)
        }
        .onOpenURL { url in
            selectedTab = 2
        }
        .blur(radius: alertManager.isAlertPresented ? userSettings.blurStrength : 0.1
        )
        .animation(.spring(), value: alertManager.isAlertPresented)
    }
}
