//
//  NavView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import SwiftUI
import SwiftUIIntrospect

struct NavView: View {
    
    @State private var selectedTab = 0
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var queueManager: QueueManager

    var body: some View {
        ZStack {
            
            TabView(selection: $selectedTab) {
                QueueManagerView(content: FeaturedView()).tag(0).tabItem { Label("FEATURED", systemImage: "star.fill") }
                QueueManagerView(content: SourcesView()).tag(1).tabItem { Label("REPOS", systemImage: "shippingbox") }
                QueueManagerView(content: AppsView()).tag(2).tabItem { Label("APPS", systemImage: "app") }
                QueueManagerView(content: BrowseView()).tag(3).tabItem { Label("BROWSE", systemImage: "magnifyingglass") }
                //            QueueManagerView(content: NewsView()).tag(1).tabItem { Label("NEWS", systemImage: "newspaper.fill") }
            }
            .introspect(.tabView, on: .iOS(.v14, .v15, .v16, .v17)) { tabView in
                tabView.tabBar.isHidden = !queueManager.canClose
                tabView.tabBar.isTranslucent = true
                
                let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                
                tabView.tabBar.standardAppearance = tabBarAppearance
                
                if #available(iOS 15.0, *) {
                    tabView.tabBar.scrollEdgeAppearance = tabBarAppearance
                }
            }
        }
        .onOpenURL { url in
            selectedTab = 1
        }
        .blur(radius: alertManager.isAlertPresented ? userSettings.blurStrength : 0.1
        )
        .animation(.spring(), value: alertManager.isAlertPresented)
    }
}
