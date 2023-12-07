//  SourceView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI
import SDWebImageSwiftUI

struct SourceView: View {
    @State private var searchText = ""
    var repo: Repo

    var body: some View {
        VStack {
            SearchBar(searchText: $searchText)
            List(filteredApps, id: \.self) { app in
                NavigationLink(destination: AppDetailsView(appDetails: app)) {
                    HStack {
                        WebImage(url: URL(string: app.iconURL))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        Text(app.name)
                    }
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
        .navigationTitle(repo.name ?? "Unnamed Repo")
        .navigationBarTitle("", displayMode: .inline)
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
        TextField("Search", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
    }
}
