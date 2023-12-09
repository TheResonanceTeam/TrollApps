//  SourceView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI
import SDWebImageSwiftUI

struct AppsView: View {
    @EnvironmentObject var repoManager: RepositoryManager
    @State private var searchText = ""

    func commonView() -> some View {
        List(filteredApps) { app in
            HStack {
//                WebImage(url: URL(string: app.iconURL))
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .clipShape(RoundedRectangle(cornerRadius: 7))
                VStack(alignment: .leading) {
                    Text(app.name)
                    Text(app.id)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
        .listStyle(PlainListStyle())
        .navigationTitle("Installed Apps")
        .navigationBarTitle("", displayMode: .inline)
    }


    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                commonView()
            }
            .searchable(text: $searchText)
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle("Installed Apps")
            .navigationBarTitle("", displayMode: .inline)
        } else {
            VStack {
                SearchBar(searchText: $searchText)
                commonView()
            }
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle("Installed Apps")
            .navigationBarTitle("", displayMode: .inline)
        }
    }
    
    var filteredApps: [BundledApp] {
        return repoManager.InstalledApps.filter { app in
            app.isTrollStore == true
        }
    }
}
