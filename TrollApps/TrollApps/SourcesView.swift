//
//  SourcesView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 15.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct SourcesView: View {
    @State private var results: [RepoMemory] = []
    @EnvironmentObject var repoManager: RepositoryManager

    var body: some View {
        NavigationView {
            List {
                ForEach(results.reversed().indices, id: \.self) { index in
                    switch results[index].data {
                    case .success(let repo):
                        NavigationLink(destination: SourceView(repo: repo), label: {
                            Text(repo.name ?? "Unnamed Repo")
                        })
                    case .failure(let error):
                        Section(header: Text("Failed to load data for this repo.")) {
                            Text("Please check your internet connection and try again later. (You may need to force-quit and relaunch TrollApps.)")
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        repoManager.removeRepo(repoMemory: results[index])
                    }
                    
                    results = repoManager.ReposData
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    EditButton()
                }
            }
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle("Sources")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(destination: AddSourceView(onDismiss: {
                        results = repoManager.ReposData
                    }), label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }.onAppear {
            if !repoManager.hasFetchedRepos {
                repoManager.fetchRepos()
            }
            
            results = repoManager.ReposData
        }
    }
}

struct AddSourceView: View {
    @EnvironmentObject var repoManager: RepositoryManager
    @State var RepoURL = ""
    @Environment(\.presentationMode) var presentationMode

    // Closure to be executed on dismiss
    var onDismiss: () -> Void

    var body: some View {
        Form {
            Section(header: Text("Add your source"), footer: Text("Please make sure to enter a valid URL source, it's better to copy and paste it here instead of just entering it by yourself.")) {
                TextField("Source URL", text: $RepoURL)
                    .keyboardType(.URL)
                Button("Add Source") {
                    repoManager.addRepo(RepoURL) {
                        RepoURL = ""
                        presentationMode.wrappedValue.dismiss()
                        onDismiss()
                    }
                }.disabled(self.RepoURL.isEmpty)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
