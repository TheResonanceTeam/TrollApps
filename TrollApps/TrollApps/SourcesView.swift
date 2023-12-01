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
    var name: String?
    var icon: String?
    var featuredApps: [String]?
    var apps: [stuff]
}

func fetchRepo(_ repoURL: String, completion: @escaping (Repo?) -> Void) {
    guard let url = URL(string: repoURL) else {
        print("Invalid URL")
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Oopsie: \(error)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        do {
            let decodedRepo = try decoder.decode(Repo.self, from: data)
            completion(decodedRepo)
        } catch {
            print("Oopsie: \(error)")
            completion(nil)
        }
    }.resume()
}

func FetchRepo(_ RepoURL: String) -> Repo? {
    var result: Repo?
    let semaphore = DispatchSemaphore(value: 0)

    fetchRepo(RepoURL) { repo in
        result = repo
        semaphore.signal()
    }

    semaphore.wait()
    return result
}

struct RepoAppsView: View {
    @AppStorage("repos") var Repos: [String] = ["https://raw.githubusercontent.com/Cleover/TrollStore-IPAs/main/apps.json"]

    @Environment(\.openURL) var openURL
    var body: some View {
        NavigationView {
            List {
                ForEach(Repos, id: \.self) { repo in
                    if let repoData = FetchRepo(repo) {
                        NavigationLink(destination: SourceView(repo: repoData), label: {
                            Text(repoData.name ?? "Unnamed Repo")
                        })
                    } else {
                        Section(header: Text("Failed to load data for this repo.")) {
                            Text("Please check your internet connection and try again later. (You may need to force-quit and relaunch TrollApps.)")
                        }
                    }
                    
                }
                .onDelete { IndexSet in
                    Repos.remove(atOffsets: IndexSet)
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
                    NavigationLink(destination: SourcesView(), label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
    }
}

struct SourcesView: View {
    @AppStorage("repos") var Repos: [String] = ["https://raw.githubusercontent.com/Cleover/TrollStore-IPAs/main/apps.json"]
    @State var RepoURL = ""
    @Environment(\.presentationMode) var presentationMode

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
                    presentationMode.wrappedValue.dismiss()

                    
                }.disabled(self.RepoURL.isEmpty)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct SourcesView_Previews: PreviewProvider {
    static var previews: some View {
        SourcesView()
    }
}
