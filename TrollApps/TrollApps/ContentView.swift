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
            AppsView()
                .tabItem {
                    Image(systemName: "apps.iphone")
                    Text("Apps")
                }
            OtherView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}
