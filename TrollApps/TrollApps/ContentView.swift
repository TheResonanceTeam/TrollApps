//
//  ContentView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FeaturedView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Featured")
                }
            SourcesView()
                .tabItem {
                    Label("Sources", systemImage: "globe.americas.fill")
                }
            OtherView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}
