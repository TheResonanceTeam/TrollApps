//
//  SourceView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI

struct AppsView: View {
    @EnvironmentObject var repoManager: RepositoryManager
    @EnvironmentObject var alertManager: AlertManager

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredApps.sorted { $0.name < $1.name }) { app in
                    InstalledAppCell(app: app) {
                        repoManager.InstalledApps = GetApps()
                    }
                }
            }
            .listStyle(PlainListStyle())
            .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 20))
            .environment(\.defaultMinListRowHeight, 50)
            .listStyle(PlainListStyle())
            .navigationTitle("INSTALLED_APPS")
        }
        .navigationViewStyle(.stack)
    }
    
    var filteredApps: [BundledApp] {
        return repoManager.InstalledApps.filter { app in
            app.isTrollStore == true
        }
    }
}
