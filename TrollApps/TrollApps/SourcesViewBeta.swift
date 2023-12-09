//
//  SourcesViewBeta.swift
//  TrollApps
//
//  Created by Cleover on 2023-12-07.
//
//
// THIS FILE IS JANK
//
//import SwiftUI
//import SDWebImageSwiftUI
//
//struct SourcesViewBeta: View {
//    @State private var repos: [RepoMemory] = []
//    @State private var badRepos: [BadRepoMemory] = []
//    
//    @EnvironmentObject var repoManager: RepositoryManager
//    
//    @State private var isAddingURL: Bool = false
//    @State private var isRequestingURL: Bool = false
//    @State private var urlToAdd = ""
//    
//    @State private var repoMultiSelection = Set<UUID>()
//    @State private var failedMultiSelection = Set<UUID>()
//    
//    @State private var showFailed: Bool = false
//    @State private var showCopied: Bool = false
//    
//    @State private var editMode: Bool = false
//    
//    @State private var showFullUrls: Bool = false
//    
//    var body: some View {
//        
//        NavigationView {
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 0) {
//                    let allRepo = Repo(
//                        name: "All Apps",
//                        apps:  repos.flatMap { $0.data.apps }
//                    )
//                    
//                    Divider().padding(.horizontal, 5)
//                    NavigationLink(destination: SourceView(repo: allRepo)) {
//                        VStack(alignment: .leading) {
//                            Text("All Apps")
//                                .foregroundColor(Color.primary)
//                            Text("See all apps from all repos")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal, 13)
//                    }
//                    .padding(.vertical, 8)
//                    Divider().padding(.horizontal, 5)
//                    
//                    Section(header: 
//                                Text("**Repos**")
//                                    .padding(.leading, 15)
//                                    .padding(.top, 25)
//                                    .padding(.bottom, 5)
//                                    .font(.system(size: 15))
//                                    .foregroundColor(.gray)
//                    ) {
//                        Divider().padding(.horizontal, 5)
//                        ForEach(repos.sorted(by: { $0.data.name ?? "Unnamed Repo" < $1.data.name ?? "Unnamed Repo" })) { repo in
//                            NavigationLink(destination: SourceView(repo: repo.data)) {
//                                HStack {
//                                    if (editMode) {
//                                        Button(action: {
//                                            if repoMultiSelection.contains(repo.id) {
//                                                repoMultiSelection.remove(repo.id)
//                                            } else {
//                                                repoMultiSelection.insert(repo.id)
//                                            }
//                                        }) {
//                                            Image(systemName: repoMultiSelection.contains(repo.id) ? "checkmark.circle.fill" : "circle")
//                                                .foregroundColor(repoMultiSelection.contains(repo.id) ? Color.blue : Color.gray)
//                                                .font(.system(size: 22))
//                                                .padding(.trailing, 5)
//                                        }
//                                    }
//                                    WebImage(url: URL(string:  repo.data.iconURL ?? "https://raw.githubusercontent.com/TheResonanceTeam/TrollApps/main/TrollApps/TrollApps/Assets.xcassets/AppIcon.appiconset/256.png"))
//                                        .resizable()
//                                        .frame(width: 48, height: 48)
//                                        .clipShape(RoundedRectangle(cornerRadius: 7))
//                                        .padding(.trailing, 8)
//                                    VStack(alignment: .leading) {
//                                        Text(repo.data.name ?? "Unnamed Repo")
//                                            .foregroundColor(Color.primary)
//                                        CollapsibleText(text: repo.url, isExpanded: $showFullUrls, maxLines: 2)
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.horizontal, 13)
//                                .padding(.vertical, 10)
//                                .background(repoMultiSelection.contains(repo.id) ? Color.primary.opacity(0.18) : Color.primary.opacity(0))
//                            }
//                            .contextMenu
//                            {
//                                Button(action: {
//                                    UIPasteboard.general.string = repo.url
//                                }, label:
//                                        {
//                                    Text("Copy Source URL")
//                                })
//                                Button(action: {
//                                    UIPasteboard.general.string = reposEncode(reposUrl: [repo.url])
//                                }, label:
//                                        {
//                                    Text("Copy Repo[] URL")
//                                })
//                                Button(action: {
//                                    repoManager.removeRepos(repoIds: [repo.id])
//                                    
//                                    repos = repoManager.ReposData
//                                    badRepos = repoManager.BadRepos
//                                }, label:
//                                        {
//                                    Text("Delete Repo")
//                                })
//                            }
//                            Divider().padding(.horizontal, 5)
//                        }
//                    }
//                }
//                .navigationTitle("Sources")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: {
//                            editMode.toggle()
//                        }) {
//                            Text(editMode ? "Done" : "Edit")
//                        }
//                    }
//                    ToolbarItem(placement: .topBarLeading) {
//                        if repoMultiSelection.count == 0 {
//                            if badRepos.count > 0 {
//                                Button(action: {
//                                    showFailed.toggle()
//                                }) {
//                                    Image(systemName: "exclamationmark.triangle")
//                                        .foregroundColor(.red)
//                                }
//                            }
//                        }
//                    }
//                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        if repoMultiSelection.count > 0 {
//                            Button(action: {
//                                let selectedUrls = repos.filter { repo in repoMultiSelection.contains(repo.id) }.map { $0.url }
//                                UIPasteboard.general.string = reposEncode(reposUrl: selectedUrls)
//                                
//                                UIApplication.shared.alert(title: "Copied Repo(s) to clipboard", body: "", animated: false, withButton: true)
//                            }) {
//                                Text("Export")
//                            }
//                        }
//                    }
//                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        if repoMultiSelection.count > 0 {
//                            Button(action: {
//                                repoManager.removeRepos(repoIds: repoMultiSelection)
//                                
//                                repos = repoManager.ReposData
//                                badRepos = repoManager.BadRepos
//                            }) {
//                                Text("Delete")
//                                    .foregroundColor(Color.red)
//                            }
//                        }
//                    }
//                    ToolbarItem(placement: .topBarTrailing) {
//                        if repoMultiSelection.count == 0 {
//                            NavigationLink(destination: AddSourceView(onDismiss: {
//                                repos = repoManager.ReposData
//                                badRepos = repoManager.BadRepos
//                            })) {
//                                Image(systemName: "plus")
//                            }
//                        }
//                    }
//                }
//            }
//    }.onAppear {
//            if !repoManager.hasFetchedRepos {
//                repoManager.fetchRepos()
//            }
//            
//            repos = repoManager.ReposData
//            badRepos = repoManager.BadRepos
//            
//        }
//        .onChange(of: repoManager.hasFinishedFetchingRepos) { newValue in
//            repos = repoManager.ReposData
//            badRepos = repoManager.BadRepos
//        }
//    }
//}
