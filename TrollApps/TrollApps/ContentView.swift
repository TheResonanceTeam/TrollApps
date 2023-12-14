//
//  ContentView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

struct ContentView: View {
    
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
            selectedTab = 1
        }
        .scaleEffect(
            userSettings.reducedMotion || !alertManager.canAnimate ? 1 :
                alertManager.isAlertPresented ? 0.75 : 1)
        
        
        .animation(.spring(), value: alertManager.isAlertPresented)
        
       
    }
}





//import SwiftUI
//import PopupView
//
//struct ContentView: View {
//
//    @State var showingPopup = false
//    @State var isShrunk = false
//
//    var body: some View {
//        Button("Show Alert") {
//            showingPopup = true
//            
//        }
//        .scaleEffect(isShrunk ? 0.8 : 1.0)
//        .popup(isPresented: $showingPopup) {
//            Text("NOT_TROLLSTORE_MANAGED")
//                .foregroundColor(.white)
//                .padding(EdgeInsets(top: 60, leading: 32, bottom: 16, trailing: 32))
//                .frame(maxWidth: .infinity)
//                .background(Color.red)
//        } customize: {
//            $0
//                .type(.toast)
//                .position(.top)
//                .autohideIn(2)
//        }
//    }
//}
