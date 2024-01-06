//  SourceView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI

struct SourceView: View {
    @State private var searchText = ""
    @EnvironmentObject var repoManager: RepositoryManager
    @StateObject private var alertManager = AlertManager()
    
    @State private var showFullVersion: Bool = false

    var repo: Repo

    func commonView() -> some View {
        List {
            ForEach(filteredApps.sorted { $0.name < $1.name }, id: \.self) { app in
                AppCell(app: app, showFullMode: false)
                    .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Text("")
//                    Button(action: {
////                        openURL(URL(string: repo.website ?? "")!)
//                    }) {
//                        Image(systemName: "globe")
//                    }
                }
            }
        }
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

//
//.toolbar {
//    ToolbarItem(placement: .topBarTrailing) {
//        if repo.website != nil && repo.website != "" {
//            Button(action: {
//                openURL(URL(string: repo.website ?? "")!)
//            }) {
//                Image(systemName: "globe")
//                    .foregroundColor(.white)
//            }
//        }
//    }
//}
