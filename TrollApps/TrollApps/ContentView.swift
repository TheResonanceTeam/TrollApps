//
//  ContentView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("FirstStart") var alertShouldBeShown = true
    var body: some View {
        TabView {
            AppsView()
                .tabItem {
                    Image(systemName: "apps.iphone")
                    Text("Apps")
                }
                .alert(isPresented: $alertShouldBeShown, content: {
                    Alert(title: Text("Welcome to TrollApps!"),
                          message: Text("This is an App Store of apps you can get to use with TrollStore. TrollApps needs to be used with a WiFi or either cellular connection, it won't work without WiFi or cellular. If no apps aren't showing this means you don't have a connection or it's not stable, or either it's an issue on my end. You have been warned. "),
                          dismissButton: Alert.Button.default(
                            Text("OK"), action: {
                                alertShouldBeShown = false
                            }
                          )
                    )
                })
            OtherView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Credits")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
