//
//  SourcesView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 15.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct SourcesView: View {
    @State private var repos: [RepoMemory] = []
    @State private var badRepos: [BadRepoMemory] = []

    @EnvironmentObject var repoManager: RepositoryManager

    @State private var isAddingURL: Bool = false
    @State private var isRequestingURL: Bool = false
    @State private var urlToAdd = ""

    @State private var repoMultiSelection = Set<UUID>()
    @State private var failedMultiSelection = Set<UUID>()
    
    @State private var showFailed: Bool = false
    @State var showCopied: Bool = false

    @State var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            if !showFailed {
                List(repos.sorted(by: { $0.data.name ?? "Unnamed Repo" < $1.data.name ?? "Unnamed Repo" }), selection: $repoMultiSelection) { repo in
                    NavigationLink(destination: SourceView(repo: repo.data)) {
                        HStack {
                            WebImage(url: URL(string:  repo.data.iconURL ?? ""))
                                .resizable()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                .padding(.trailing, 8)
                            VStack(alignment: .leading) {
                                Text(repo.data.name ?? "Unnamed Repo")
                                Text(repo.url)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .contextMenu
                    {
                        Button(action: {
                            UIPasteboard.general.string = repo.url
                        }, label:
                                {
                            Text("Copy Source URL")
                        })
                        Button(action: {
                            UIPasteboard.general.string = reposEncode(reposUrl: [repo.url])
                        }, label:
                                {
                            Text("Copy Repo[] URL")
                        })
                        Button(action: {
                            repoManager.removeRepos(repoIds: [repo.id])
                            
                            repos = repoManager.ReposData
                            badRepos = repoManager.BadRepos
                        }, label:
                                {
                            Text("Delete Repo")
                        })
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 20))
                .environment(\.defaultMinListRowHeight, 50)
                .navigationTitle("Repos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if repoMultiSelection.count == 0 {
                            if badRepos.count > 0 {
                                Button(action: {
                                    showFailed.toggle()
                                }) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if repoMultiSelection.count > 0 {
                            Button(action: {
                                let selectedUrls = repos.filter { repo in repoMultiSelection.contains(repo.id) }.map { $0.url }
                                UIPasteboard.general.string = reposEncode(reposUrl: selectedUrls)
                                
                                UIApplication.shared.alert(title: "Copied Repo(s) to clipboard", body: "", animated: false, withButton: true)
                            }) {
                                Text("Export")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if repoMultiSelection.count > 0 {
                            Button(action: {
                                repoManager.removeRepos(repoIds: repoMultiSelection)
                                
                                repos = repoManager.ReposData
                                badRepos = repoManager.BadRepos
                            }) {
                                Text("Delete")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                    
                    let allRepo = Repo(
                         name: "All Apps",
                         apps:  repos.flatMap { $0.data.apps }
                    )
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if repoMultiSelection.count == 0 {
                            NavigationLink(destination: SourceView(repo: allRepo)) {
                                Image(systemName: "magnifyingglass")
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if repoMultiSelection.count == 0 {
                            NavigationLink(destination: AddSourceView(onDismiss: {
                                repos = repoManager.ReposData
                                badRepos = repoManager.BadRepos
                            })) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }.environment(\.editMode, $editMode)
            } else if badRepos.count > 0 {
                List(badRepos, selection: $failedMultiSelection) { badRepo in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .frame(width: 48, height: 48)
                            .padding(.trailing, 8)
                        VStack(alignment: .leading) {
                            Text("Unable To Load Repo")
                            Text(badRepo.url)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .contextMenu
                    {
                        Button(action: {
                            UIPasteboard.general.string = badRepo.url
                        }, label:
                                {
                            Text("Copy Source URL")
                        })
                        Button(action: {
                            UIPasteboard.general.string = reposEncode(reposUrl: [badRepo.url])
                        }, label:
                                {
                            Text("Copy Repo[] URL")
                        })
                        Button(action: {
                            repoManager.removeBadRepos(repoIds: [badRepo.id])
                            
                            repos = repoManager.ReposData
                            badRepos = repoManager.BadRepos
                            
                            if badRepos.count == 0 {
                                showFailed = false
                            }
                        }, label:
                                {
                            Text("Delete Repo")
                        })
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 20))
                .environment(\.defaultMinListRowHeight, 50)
                .navigationTitle("Broken Repos")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if failedMultiSelection.count == 0 {
                            Button(action: {
                                showFailed.toggle()
                            }) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if failedMultiSelection.count > 0 {
                            Button(action: {
                                let selectedUrls = repos.filter { repo in failedMultiSelection.contains(repo.id) }.map { $0.url }
                                UIPasteboard.general.string = reposEncode(reposUrl: selectedUrls)
                                
                                UIApplication.shared.alert(title: "Copied Repo(s) to clipboard", body: "", animated: false, withButton: true)
                            }) {
                                Text("Export")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if failedMultiSelection.count > 0 {
                            Button(action: {
                                repoManager.removeBadRepos(repoIds: failedMultiSelection)
                                
                                repos = repoManager.ReposData
                                badRepos = repoManager.BadRepos
                                
                                if badRepos.count == 0 {
                                    showFailed = false
                                }
                            }) {
                                Text("Delete")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                }.environment(\.editMode, $editMode)
            }
        }.onAppear {
            if !repoManager.hasFetchedRepos {
                repoManager.fetchRepos()
            }
            
            repos = repoManager.ReposData
            badRepos = repoManager.BadRepos

        }
        .onOpenURL { url in
            if url.absoluteString.hasPrefix("trollapps://add?url=") {
                if let repoURL = url.queryParameters?["url"] {
                    if repoURL != "" {
                        isAddingURL = true
                        repoManager.addRepo(repoURL) {
                            repos = repoManager.ReposData
                            badRepos = repoManager.BadRepos
                            isAddingURL = false
                        }
                    }
                }
            }
        }
        .alert(isPresented: $isAddingURL) {
            Alert(title: Text("Adding Repo"), message: Text("Please wait..."))
        }
        .onChange(of: repoMultiSelection) { newValue in
            if newValue.count > 0 {
                if editMode == .inactive {
                    repoMultiSelection.removeAll()
                }
            }
        }
        .onChange(of: failedMultiSelection) { newValue in
            if newValue.count > 0 {
                if editMode == .inactive {
                    failedMultiSelection.removeAll()
                }
            } else if newValue.count == 0 {
                print("all gone")
                showFailed = false
            }
        }
        .onChange(of: repoManager.hasFinishedFetchingRepos) { newValue in
            repos = repoManager.ReposData
            badRepos = repoManager.BadRepos
        }
    }
}

struct AddSourceView: View {
    @EnvironmentObject var repoManager: RepositoryManager
    @State var RepoURL = ""
    @Environment(\.presentationMode) var presentationMode

    var onDismiss: () -> Void

    var body: some View {
        Form {
            Section(header: Text("Add Repos"), footer: Text("Please ensure you input a valid repo URL. It's suggested you copy and paste it here, rather than manually entering it.")) {
                TextField("Repo URL", text: $RepoURL)
                    .keyboardType(.URL)
                Button("Add Repos") {
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
