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
            SourcesView()
                .tabItem {
                    Label("Sources", systemImage: "shippingbox")
                }
                .tag(0)
//            AppsView()
//                .tabItem {
//                    Label("Apps", systemImage: "app.badge.checkmark")
//                }
//                .tag(1)
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



