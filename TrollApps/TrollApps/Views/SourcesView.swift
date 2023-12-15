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
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var userSettings: UserSettings

    @State private var isAddingURL: Bool = false
    @State private var isRequestingURL: Bool = false
    @State private var urlToAdd = ""

    @State private var repoMultiSelection = Set<UUID>()
    @State private var failedMultiSelection = Set<UUID>()
    
    @State private var showFailed: Bool = false
    @State private var showCopied: Bool = false

    @State private var editMode: EditMode = .inactive
    
    @State private var showFullUrls: Bool = false
    
    var body: some View {
        NavigationView {
            if !showFailed {
                List(selection: $repoMultiSelection) {
                    ForEach(repos.sorted(by: { $0.data.name ?? "UNNAMED_REPO" < $1.data.name ?? "UNNAMED_REPO" })) { repo in
                        HStack {
                            let iconSize : CGFloat = userSettings.compactRepoView ? 35 : 48

                            if(repo.data.iconURL == nil || repo.data.iconURL == "") {
                                Image("MissingRepo")
                                    .resizable()
                                    .frame(width: iconSize, height: iconSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .padding(.trailing, 7)
                            } else {
                                WebImage(url: URL(string: repo.data.iconURL ?? ""))
                                    .resizable()
                                    .frame(width: iconSize, height: iconSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .padding(.trailing, 7)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(repo.data.name ?? "UNNAMED_REPO")
                                if (!userSettings.compactRepoView) {
                                    CollapsibleText(text: repo.url, isExpanded: $showFullUrls, maxLines: 2)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .background(
                            NavigationLink("", destination: SourceView(repo: repo.data))
                                .opacity(0)
                        )
                        .contextMenu
                        {
                            Button(action: {
                                UIPasteboard.general.string = repo.url
                            }, label:
                                    {
                                Text("COPY_REPO_URL")
                            })
                            Button(action: {
                                UIPasteboard.general.string = reposEncode(reposUrl: [repo.url])
                            }, label:
                                    {
                                Text("COPY_REPO_BASE_URL")
                            })
                            Button(action: {
                                repoManager.removeRepos(repoIds: [repo.id])
                                
                                repos = repoManager.ReposData
                                badRepos = repoManager.BadRepos
                            }, label:
                                    {
                                Text("DELETE_REPO")
                            })
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 20))
                .environment(\.defaultMinListRowHeight, 50)
                .listStyle(PlainListStyle())
                .navigationTitle("REPOS")
                .onDisappear {
                    repoMultiSelection.removeAll()
                }
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
                                repoManager.removeRepos(repoIds: repoMultiSelection)
                                
                                repos = repoManager.ReposData
                                badRepos = repoManager.BadRepos
                            }) {
                                Text("DELETE")
                                    .foregroundColor(Color.red)
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
//                if #available(iOS 15.0, *) {
//                    listTest.refreshable {
//                        print("refresh")
//                    }
//                }else {
//                    
//                }
            } else if badRepos.count > 0 {
                List(badRepos, selection: $failedMultiSelection) { badRepo in
                    HStack {
                        let iconSize : CGFloat = userSettings.compactRepoView ? 35 : 48

                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .frame(width: iconSize, height: iconSize)
                            .padding(.trailing, 8)
                        VStack(alignment: .leading) {
                            Text("UNABLE_TO_LOAD_REPO")
                            if (!userSettings.compactRepoView) {
                                CollapsibleText(
                                    text: badRepo.url,
                                    isExpanded: $showFullUrls,
                                    maxLines: 2
                                )
                            }
                        }
                    }
                    .contextMenu
                    {
                        Button(action: {
                            UIPasteboard.general.string = badRepo.url
                        }, label:
                                {
                            Text("COPY_REPO_URL")
                        })
                        Button(action: {
                            UIPasteboard.general.string = reposEncode(reposUrl: [badRepo.url])
                        }, label:
                                {
                            Text("COPY_REPO_BASE_URL")
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
                            Text("DELETE_REPO")
                        })
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 20))
                .environment(\.defaultMinListRowHeight, 50)
                .listStyle(PlainListStyle())
                .navigationTitle("BROKEN_REPOS")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
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
                                repoManager.removeBadRepos(repoIds: failedMultiSelection)
                                
                                repos = repoManager.ReposData
                                badRepos = repoManager.BadRepos
                                
                                failedMultiSelection.removeAll()

                                if badRepos.count == 0 {
                                    showFailed = false
                                }
                            }) {
                                Text("DELETE")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                }.environment(\.editMode, $editMode)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
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
                        
                        if (repoManager.RepoList.contains(repoURL)) {
                            
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("DUPLICATE_REPO")),
                                body: Text(LocalizedStringKey("ALREADY_ON_REPO_LIST"))
                            )

                        } else {
                            isAddingURL = true
                            repoManager.addRepo(repoURL, alertManager: alertManager) {
                                repos = repoManager.ReposData
                                badRepos = repoManager.BadRepos
                                isAddingURL = false
                            }
                        }
                    }
                }
            }
        }
        .alert(isPresented: $isAddingURL) {
            Alert(title: Text("ADDING_REPO"), message: Text("PLEASE_WAIT"))
        }
        .onChange(of: repoManager.hasFinishedFetchingRepos) { _ in
            repos = repoManager.ReposData
            badRepos = repoManager.BadRepos
        }
    }
}

struct AddSourceView: View {
    @EnvironmentObject var repoManager: RepositoryManager
    @State var RepoURL = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var userSettings: UserSettings

    var onDismiss: () -> Void

    var body: some View {
        VStack {
            Form {
                Section(header: Text("ADD_REPOS"), footer: Text("ADD_REPOS_TOOLTIP")) {
                    TextField("REPO_URL", text: $RepoURL)
                        .keyboardType(userSettings.addRepoKeyboardType)
                    Button("ADD_REPOS") {
                        if (repoManager.RepoList.contains(RepoURL)) {
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("DUPLICATE_REPO")),
                                body: Text(LocalizedStringKey("ALREADY_ON_REPO_LIST"))
                            )
                        } else {
                            repoManager.addRepo(RepoURL, alertManager: alertManager) {
                                RepoURL = ""
                                presentationMode.wrappedValue.dismiss()
                                onDismiss()
                            }
                        }

                    }.disabled(self.RepoURL.isEmpty)
                    Button("ADD_REPO_FROM_CLIPBOARD") {
                        let pasteboard = UIPasteboard.general
                        if let RepoURL = pasteboard.string{
                            if (repoManager.RepoList.contains(RepoURL)) {
                                alertManager.showAlert(
                                    title: Text(LocalizedStringKey("DUPLICATE_REPO")),
                                    body: Text(LocalizedStringKey("ALREADY_ON_REPO_LIST"))
                                )
                            } else {
                                repoManager.addRepo(RepoURL, alertManager: alertManager) {
                                    presentationMode.wrappedValue.dismiss()
                                    onDismiss()
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationTitle("ADD_REPO")
    }
}
