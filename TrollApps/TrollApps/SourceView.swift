//
//  SourceView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI
import SDWebImageSwiftUI

struct SourceView: View {
    var repo: Repo
    @State var InstallingIPA = false
    @State var DownloadingIPA = true
    @State var InstallingIPAInfo: stuff? = nil
    
    @State private var searchText = ""
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        if InstallingIPA {
            HStack {
                Text("\(DownloadingIPA ? "Download" : "Install")ing \(InstallingIPAInfo!.name)")
                WebImage(url: URL(string: InstallingIPAInfo!.iconURL))
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        } else {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Form {
                Section() {
                    ForEach(filteredApps) { app in
                        NavigationLink(destination: AppDetailsView(appDetails: app)) {
                            Section {
                                Label {
                                    HStack {
                                        Text(app.name)
//                                        Spacer()
//                                        Button(IsAppInstalled(app.bundleIdentifier) ? "OPEN" : "GET") {
//                                            if IsAppInstalled(app.bundleIdentifier) {
//                                                OpenApp(app.bundleIdentifier)
//                                            } else {
//                                                // MISSING GET CODE
//                                            }
//                                        }
//                                        .buttonStyle(AppStoreStyle())
                                    }
                                } icon: {
                                    WebImage(url: URL(string: app.iconURL))
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                            }
                        }
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle(repo.name ?? "Unnamed Repo")
            .navigationBarTitle("", displayMode: .inline)

        }
    }
    
    var filteredApps: [stuff] {
        if searchText.isEmpty {
            return mergeApps(appList: repo.apps)
        } else {
            return mergeApps(appList: repo.apps).filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}



struct SourceView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRepo = Repo(
            name: "test repo",
            apps: []
        )

        SourceView(repo: sampleRepo)
    }
}
