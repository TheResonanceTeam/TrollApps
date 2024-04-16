//
//  SourcesView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 15.11.2022.
//

import SwiftUI

struct SourcesView: View {
    @State private var repos: [RepoMemory] = []
    @State private var badRepos: [BadRepoMemory] = []

    @EnvironmentObject var repoManager: RepositoryManager
    @EnvironmentObject var alertManager: AlertManager

    @State private var repoMultiSelection = Set<UUID>()
    @State private var failedMultiSelection = Set<UUID>()
    
    @State private var showFailed: Bool = false

    @State private var editMode: EditMode = .inactive
        
    var body: some View {
        NavigationView {
            if !showFailed {
                List(selection: $repoMultiSelection) {
                    ForEach(repos.sorted(by: { $0.data.name ?? "UNNAMED_REPO" < $1.data.name ?? "UNNAMED_REPO" })) { repo in
                        RepoCell(repo: repo, removeRepos: removeRepos)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("REPOS")
                .onDisappear {
                    repoMultiSelection.removeAll()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if(editMode == .inactive) {
                            Button("Edit") {
                                editMode = .active
                            }
                        } else {
                            Button("Done") {
                                editMode = .inactive
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if repoMultiSelection.count == 0 {
                            if badRepos.count > 0 {
                                Button(action: {
                                    showFailed.toggle()
                                }) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.pink)
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if repoMultiSelection.count > 0 {
                            Button(action: {
                                let selectedUrls = repos.filter { repo in repoMultiSelection.contains(repo.id) }.map { $0.url }
                                UIPasteboard.general.string = reposEncode(reposUrl: selectedUrls)
                                
                                alertManager.showAlert(
                                    title: Text(LocalizedStringKey("COPIED_REPOS_TO_CLIPBOARD")),
                                    body: Text(LocalizedStringKey(""))
                                )

                            }) {
                                Text("EXPORT")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if repoMultiSelection.count > 0 {
                            Button(action: {
                                withAnimation {
                                    removeRepos(repoIds: repoMultiSelection)
                                }
                            }) {
                                Text("DELETE")
                                    .foregroundColor(Color.pink)
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if repoMultiSelection.count == 0 {
                            NavigationLink(destination: AddSourceView(onDismiss: {
                                updateUI()
                            })) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }.environment(\.editMode, $editMode)
            } else if badRepos.count > 0 {
                List(badRepos, selection: $failedMultiSelection) { badRepo in
                    withAnimation {
                        BadRepoCell(badRepo: badRepo, removeBadRepos: removeBadRepos)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("BROKEN_REPOS")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if(editMode == .inactive) {
                            Button("Edit") {
                                editMode = .active
                            }
                        } else {
                            Button("Done") {
                                editMode = .inactive
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if failedMultiSelection.count == 0 {
                            Button(action: {
                                showFailed.toggle()
                            }) {
                                Image(systemName: "arrow.backward")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if failedMultiSelection.count > 0 {
                            Button(action: {
                                let selectedUrls = repos.filter { repo in failedMultiSelection.contains(repo.id) }.map { $0.url }
                                UIPasteboard.general.string = reposEncode(reposUrl: selectedUrls)
                                
                                alertManager.showAlert(
                                    title: Text(LocalizedStringKey("COPIED_REPOS_TO_CLIPBOARD")),
                                    body: Text(LocalizedStringKey(""))
                                )

                            }) {
                                Text("EXPORT")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if failedMultiSelection.count > 0 {
                            Button(action: {
                                removeBadRepos(badRepoIds: failedMultiSelection)
                            }) {
                                Text("DELETE")
                                    .foregroundColor(Color.pink)
                            }
                        }
                    }
                }.environment(\.editMode, $editMode)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            withAnimation {
                if !repoManager.hasFetchedRepos {
                    repoManager.fetchRepos()
                }
                
                updateUI()
            }
        }
        .onOpenURL { url in
            if url.absoluteString.hasPrefix("trollapps://add?url=") {
                if let repoURL = url.queryParameters?["url"] {
                    if repoURL != "" {
                        
                        if (repoManager.RepoList.contains(repoURL)) {
                            
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("DUPLICATE_REPO")),
                                body: Text(LocalizedStringKey("ALREADY_ON_REPO_LIST"))
                            )

                        } else {
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("ADDING_REPO")),
                                body: Text(LocalizedStringKey("PLEASE_WAIT")),
                                showButtons: false
                            )
                                                            
                            repoManager.addRepo(repoURL, alertManager: alertManager) {
                                alertManager.isAlertPresented = false
                                updateUI()
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: repoManager.hasFinishedFetchingRepos) { _ in
            updateUI()
        }
    }
    
    func removeRepos(repoIds: Set<UUID>) {
        repoManager.removeRepos(repoIds: repoIds)
        updateUI()
    }
    
    func removeBadRepos(badRepoIds: Set<UUID>) {
        repoManager.removeBadRepos(repoIds: badRepoIds)
        updateUI()
        
        if badRepos.count == 0 {
            showFailed = false
        }
    }
    
    func updateUI() {
        repos = repoManager.ReposData
        badRepos = repoManager.BadRepos
    }
}
