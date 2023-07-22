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
    guard let url = URL(string: RepoURL) else {
        print("Invalid URL")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        return try decoder.decode(Repo.self, from: data)
    } catch {
        print("oopsie: \(error)")
        return nil
    }
}

struct RepoAppsView: View {
    @AppStorage("repos") var Repos: [String] = ["https://raw.githubusercontent.com/haxi0/TrollApps-Static-API/main/ExampleRepo.json"]
    @State var InstallingIPA = false
    @State var DownloadingIPA = true
    @State var InstallingIPAInfo: RepoApp? = nil
    @Environment(\.openURL) var openURL
    var body: some View {
        if InstallingIPA {
            HStack {
                Text("\(DownloadingIPA ? "Download" : "Install")ing \(InstallingIPAInfo!.title)")
                WebImage(url: URL(string: InstallingIPAInfo!.urlimg))
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        } else {
            NavigationView {
                Form {
                    ForEach(Repos, id: \.self) { repo in
                        if let repoData = FetchRepo(repo) {
                            Section(header: Text(repoData.name)) {
                                ForEach(repoData.apps) { app in
                                    Section {
                                        Label {
                                            HStack {
                                                Text(app.title)
                                                Spacer()
                                                Button(IsAppInstalled(app.bundleid) ? "OPEN" : "GET") {
                                                    if IsAppInstalled(app.bundleid) {
                                                        OpenApp(app.bundleid)
                                                    } else {
                                                        DispatchQueue.global(qos: .utility).async {
                                                            InstallingIPA = true
                                                            InstallingIPAInfo = app
                                                            DownloadingIPA = true
                                                            DownloadIPA(app.url)
                                                            DownloadingIPA = false
                                                            InstallIPA("/var/mobile/TrollApps-Tmp-IPA.ipa")
                                                            InstallingIPA = false
                                                            InstallingIPAInfo = nil
                                                        }
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
                        } else {
                            Section(header: Text("Failed to load data for this repo.")) {
                                Text("Please check your internet connection and try again later. (You may need to force-quit and relaunch TrollApps.)")
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
                if let repoData = FetchRepo(repo) {
                    Label {
                        Text(repoData.name)
                    } icon: {
                        WebImage(url: URL(string: FetchRepo(repo)!.icon))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                } else {
                    Text("Failed to load data for this repo")
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
