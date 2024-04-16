//
//  FeaturedView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 21.11.2022.
//

import SwiftUI

struct FeaturedView: View {
    
    @State private var showFullVersion: Bool = false
    
    @State private var repos: [RepoMemory] = []
    @EnvironmentObject var repoManager: RepositoryManager

    var body: some View {
        NavigationView {
            List {
                ForEach(repos.sorted(by: { $0.data.name ?? "UNNAMED_REPO" < $1.data.name ?? "UNNAMED_REPO" })) { repo in
                    if (repo.data.featuredApps ?? []).count > 0 {
                        Section(header: Text(repo.data.name ?? "UNNAMED_REPO")) {
                            ForEach(repo.data.featuredApps ?? [], id: \.self) { featuredAppId in
                                ForEach(repoManager.fetchAppsInRepo(repoInput: repo.data, bundleIdInput: featuredAppId), id: \.self) { app in
                                    AppCell(app: app, showFullMode: false)
                                        .listRowInsets(EdgeInsets())
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("FEATURED")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            repos = repoManager.ReposData
        }
        .onChange(of: repoManager.hasFinishedFetchingRepos) { _ in
            repos = repoManager.ReposData
        }
    }
}
