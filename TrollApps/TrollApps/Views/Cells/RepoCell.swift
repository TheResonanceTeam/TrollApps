//
//  RepoCell.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-16.
//

import SwiftUI
import Kingfisher
import SwipeActions

struct RepoCell: View {
    @EnvironmentObject var userSettings: UserSettings
    
    let repo : RepoMemory
    let removeRepos: (Set<UUID>) -> Void
    
    var body: some View {
        SwipeView {
            HStack {
                let iconSize : CGFloat = userSettings.compactRepoView ? 35 : 48
                
                if(repo.data.iconURL == nil || repo.data.iconURL == "") {
                    Image("MissingRepo")
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding(.trailing, 7)
                } else {
                    KFImage(URL(string: repo.data.iconURL ?? ""))
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding(.trailing, 7)
                }
                
                VStack(alignment: .leading) {
                    Text(repo.data.name ?? "UNNAMED_REPO")
                    if (!userSettings.compactRepoView) {
                        CollapsibleText(text: repo.url, isExpanded: .constant(false), maxLines: 2)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(repo.data.apps.count)")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .opacity(0.75)
                }
                .padding(.trailing, 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
            .background(
                NavigationLink("", destination: SourceView(repo: repo.data))
                    .padding(.trailing, 15)
//                    .opacity(0)
            )
            .background(
                Color.white.opacity(0.001)
            )
            .contextMenu
            {
                Button(action: {
                    UIPasteboard.general.string = repo.url
                }, label:
                        {
                    Text("COPY_REPO_URL")
                })
                Button(action: {
                    UIPasteboard.general.string = reposEncode(reposUrl: [repo.url])
                }, label:
                        {
                    Text("COPY_REPO_BASE_URL")
                })
                Button(action: {
                    withAnimation {
                        removeRepos([repo.id])
                    }
                }, label:
                        {
                    Text("DELETE_REPO")
                })
            }
        } trailingActions: { _ in
            SwipeAction(systemImage: "trash", backgroundColor: .pink, highlightOpacity: 1) {
                withAnimation {
                    removeRepos([repo.id])
                }
            }
            .allowSwipeToTrigger()
        }
        .swipeActionsStyle(.mask)
        .swipeMinimumDistance(35)
        .swipeActionCornerRadius(0)
        .swipeSpacing(0)
        .swipeActionsMaskCornerRadius(0)
    }
}
