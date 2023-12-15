//
//  BrowseView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-09.
//

import SwiftUI
import SDWebImageSwiftUI

struct BrowseView: View {
    @State private var searchText = ""
    @State private var showFullVersion: Bool = false
    @State private var showFullMode: Bool = false

    @State private var apps: [Application] = []
    @EnvironmentObject var repoManager: RepositoryManager
    @StateObject private var alertManager = AlertManager()

    func commonView() -> some View {
        List(filteredApps.sorted { $0.name < $1.name }, id: \.self) { app in
            
            let version = (app.versions?[0].version != nil && app.versions?[0].version != "" ? (app.versions?[0].version ?? "") : "")
            let devName = (app.developerName != nil && app.developerName != "" ? (app.developerName ?? "") : "")
            
            VStack(alignment: .leading) {
                HStack {
                    WebImage(url: URL(string: app.iconURL))
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .padding(.trailing, 8)
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
                if showFullMode {
                    let screenshots = app.screenshotURLs ?? []
                    if(screenshots.count > 0 ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(screenshots.indices, id: \.self) { index in
                                    WebImage(url: URL(string: screenshots[index]))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                }
            }
            .background(
                NavigationLink("", destination: AppDetailsView(appDetails: app))
                    .opacity(0)
            )
        }
        .environment(\.defaultMinListRowHeight, 50)
        .listStyle(PlainListStyle())
        .navigationTitle("BROWSE")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    showFullMode.toggle()
                }) {
                    Image(systemName: "info.circle")
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                VStack {
                    commonView()
                }
                .searchable(text: $searchText)
                .environment(\.defaultMinListRowHeight, 50)
                .navigationTitle("BROWSE")
            } else {
                VStack {
                    SearchBar(searchText: $searchText)
                    commonView()
                }
                .environment(\.defaultMinListRowHeight, 50)
                .navigationTitle("BROWSE")
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            apps = repoManager.ReposData.flatMap { $0.data.apps }
        }
        .onChange(of: repoManager.hasFinishedFetchingRepos) { _ in
            apps = repoManager.ReposData.flatMap { $0.data.apps }
        }
    }
    
    var filteredApps: [Application] {
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
