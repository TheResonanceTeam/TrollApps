//
//  SourcesView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 15.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct Repo: Decodable, Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var apps: [RepoApp]
}

struct RepoApp: Decodable, Identifiable {
    let id = UUID()
    var title: String
    var url: String
    var bundleid: String
    var urlimg: String
    var completed: Bool
}

func FetchRepo(_ RepoURL: String) -> Repo? {
    do {
        return try decoder.decode(Repo.self, from: try! Data(contentsOf: URL(string: RepoURL)!))
    } catch {
        print("oopsie: \(error)")
        return nil
    }
}

struct RepoAppsView: View {
    @AppStorage("repos") var Repos: [String] = ["https://raw.githubusercontent.com/haxi0/TrollApps-Static-API/main/ExampleRepo.json"]
    @Environment(\.openURL) var openURL
    var body: some View {
        NavigationView {
            Form {
                ForEach(Repos, id: \.self) { repo in
                    Section(header: Text(FetchRepo(repo)!.name)) {
                        ForEach(FetchRepo(repo)!.apps) { app in
                            Section {
                                Label {
                                    HStack {
                                        Text(app.title)
                                        Spacer()
                                        Button(IsAppInstalled(app.bundleid) ? "OPEN" : "GET") {
                                            if IsAppInstalled(app.bundleid) {
                                                OpenApp(app.bundleid)
                                            } else {
                                                openURL(URL(string: "apple-magnifier://install?url=\(app.url)")!)
                                            }
                                        }
                                        .buttonStyle(appstorestyle())
                                    }
                                } icon: {
                                    WebImage(url: URL(string: app.urlimg))
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                            }
                        }
                    }
                }
                NavigationLink(destination: SourcesView(), label: {
                    Text("Manage Sources")
                })
            }
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle("Sources & Apps")
        }
    }
}

struct SourcesView: View {
    @AppStorage("repos") var Repos: [String] = ["https://raw.githubusercontent.com/haxi0/TrollApps-Static-API/main/ExampleRepo.json"]
    @State var RepoURL = ""
    var body: some View {
        Form {
            
            Section(header: Text("Add your source"), footer: Text("Please make sure to enter a valid URL source, it's better to copy and paste it here instead of just entering it by yourself.")) {
                TextField("Source URL", text: $RepoURL)
                    .keyboardType(.URL)
                Button("Add Source") {
                    if !Repos.contains(RepoURL) {
                        Repos.append(RepoURL)
                        RepoURL = ""
                    }
                }.disabled(self.RepoURL.isEmpty)
            }
            ForEach(Repos, id: \.self) { repo in
                Label {
                    Text(FetchRepo(repo)!.name)
                } icon: {
                    WebImage(url: URL(string: FetchRepo(repo)!.icon))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
            .onDelete { IndexSet in
                Repos.remove(atOffsets: IndexSet)
            }
        }
    }
}

struct SourcesView_Previews: PreviewProvider {
    static var previews: some View {
        SourcesView()
    }
}
