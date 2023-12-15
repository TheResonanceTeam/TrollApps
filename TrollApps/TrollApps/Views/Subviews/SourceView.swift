//  SourceView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI
import SDWebImageSwiftUI

struct SourceView: View {
    @State private var searchText = ""
    @EnvironmentObject var repoManager: RepositoryManager
    @StateObject private var alertManager = AlertManager()
    
    @State private var showFullVersion: Bool = false

    var repo: Repo

    func commonView() -> some View {
        List {
            ForEach(filteredApps.sorted { $0.name < $1.name }, id: \.self) { app in
                let version = (app.versions?[0].version != nil && app.versions?[0].version != "" ? (app.versions?[0].version ?? "") : "")
                let devName = (app.developerName != nil && app.developerName != "" ? (app.developerName ?? "") : "")
                
                HStack {

                    if(app.iconURL != "") {
                        WebImage(url: URL(string: app.iconURL))
                            .resizable()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.trailing, 7)
                        
                    } else {
                        Image("MissingRepo")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.trailing, 7)
                    }

                    VStack(alignment: .leading) {
                        Text(app.name)
                        CollapsibleText(text: devName , isExpanded: $showFullVersion, maxLines: 1)
                            .font(.caption)
                            .foregroundColor(.gray)
                        CollapsibleText(text: version , isExpanded: $showFullVersion, maxLines: 1)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    DynamicInstallButton(appDetails: app, selectedVersionIndex: 0, buttonStyle: "Main")
                }
                
                .background(
                    NavigationLink("", destination: AppDetailsView(appDetails: app))
                        .opacity(0)
                )
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
        .listStyle(PlainListStyle())
        .navigationTitle(repo.name ?? "UNNAMED_REPO")
        .navigationBarTitle("", displayMode: .inline)
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                commonView()
            }
            .searchable(text: $searchText)
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle(repo.name ?? "UNNAMED_REPO")
            .navigationBarTitle("", displayMode: .inline)
        } else {
            VStack {
                SearchBar(searchText: $searchText)
                commonView()
            }
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle(repo.name ?? "UNNAMED_REPO")
            .navigationBarTitle("", displayMode: .inline)
        }
    }
    
    var filteredApps: [Application] {
        if searchText.isEmpty {
            return repo.apps
        } else {
            return repo.apps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(height: 36)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)

                TextField("SEARCH", text: $searchText)
                    .padding(.horizontal, 3)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
            }
        }
        .padding(.horizontal)
    }
}
