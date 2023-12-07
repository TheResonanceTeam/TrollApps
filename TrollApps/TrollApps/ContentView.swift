//
//  ContentView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
//            FeaturedView()
//                .tabItem {
//                    Image(systemName: "star.fill")
//                    Text("Featured")
//                }
//                .tag(0)
            SourcesView()
                .tabItem {
                    Label("Repos", systemImage: "globe.americas.fill")
                }
                .tag(0)
            OtherView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(1)
        }
        .onOpenURL { url in
            selectedTab = 0
        }
    }
}
