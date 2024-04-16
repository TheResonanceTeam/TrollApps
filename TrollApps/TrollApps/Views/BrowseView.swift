//
//  BrowseView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-09.
//

import SwiftUI

struct AppListView: View {
    var apps: [Application]
    var showFullMode: Bool

    var body: some View {
        List(apps.sorted { $0.name < $1.name }, id: \.self) { app in
            AppCell(app: app, showFullMode: showFullMode)
                .listRowInsets(EdgeInsets())
        }
        .listStyle(PlainListStyle())
    }
}

struct BrowseView: View {
    @State private var searchText = ""
    @State private var showFullMode: Bool = false
    @State private var apps: [Application] = []
    @EnvironmentObject var repoManager: RepositoryManager

    var body: some View {
        NavigationView {
            VStack {
                if #available(iOS 15.0, *) {
                    AppListView(apps: filteredApps, showFullMode: showFullMode)
                        .searchable(text: $searchText)
                } else {
                    SearchBar(searchText: $searchText)
                    AppListView(apps: filteredApps, showFullMode: showFullMode)
                }
            }
            .navigationTitle("BROWSE")
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {
                        showFullMode.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .onAppear {
                apps = repoManager.ReposData.flatMap { $0.data.apps }
            }
            .onChange(of: repoManager.hasFinishedFetchingRepos) { _ in
                apps = repoManager.ReposData.flatMap { $0.data.apps }
            }
        }
        .navigationViewStyle(.stack)
    }

    var filteredApps: [Application] {
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
