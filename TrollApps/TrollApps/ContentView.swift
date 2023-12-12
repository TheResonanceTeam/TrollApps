//
//  ContentView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    @State private var selectedAppIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeaturedView()
                .tabItem {
                    Label("FEATURED", systemImage: "star.fill")
                }
                .tag(0)
            SourcesView()
                .tabItem {
                    Label("SOURCES", systemImage: "shippingbox")
                }
                .tag(1)
            BrowseView()
                .tabItem {
                    Label("BROWSE", systemImage: "magnifyingglass")
                }
                .tag(2)
            AppsView()
                .tabItem {
                    Label("APPS", systemImage: "app")
                }
                .tag(3)
            OtherView()
                .tabItem {
                    Label("SETTINGS", systemImage: "gearshape")
                }
                .tag(4)
        }
        .onOpenURL { url in
            selectedTab = 0
        }
    }
}



