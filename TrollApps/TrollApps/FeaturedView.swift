//
//  FeaturedView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 21.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FeaturedView: View {
    
        var body: some View {
            Text("Featured view will be back in the next update <3")
        }
    
    
//    struct RepoFeaturedApps: Decodable, Identifiable, Equatable, Hashable {
//        let id = UUID()
//        var name: String?
//        var apps: [Application]
//    }
//    
//    @EnvironmentObject var repoManager: RepositoryManager
//    @State private var featuredApps: [RepoFeaturedApps] = []
//
//    var body: some View {
//        NavigationView {
//            List {
////                Section(header: Text(repo.data.name ?? "Unnamed Repo")) {
////                    NavigationLink(destination: AppDetailsView(appDetails: app)) {
////                        HStack {
////                            WebImage(url: URL(string: app.iconURL ?? ""))
////                                .resizable()
////                                .frame(width: 30, height: 30)
////                                .clipShape(RoundedRectangle(cornerRadius: 7))
////                            Text(app.name)
////                        }
////                    }
////                }
//            }
//            .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 20))
//            .environment(\.defaultMinListRowHeight, 50)
//            .navigationTitle("Featured")
//        }.onAppear {
//            if !repoManager.hasFetchedRepos {
//                repoManager.fetchRepos()
//            }
//            
//            
//            for repo in repoManager.ReposData {
//                for featuredApp in repo.data.featuredApps ?? [] {
//                    if let app = repo.data.apps.first(where: { $0.bundleIdentifier == featuredAppBundleId }) {
//                        // featuredApps.append()
//                    } else {
//                        
//                    }
//                }
//            }
//        }
//    }
}
