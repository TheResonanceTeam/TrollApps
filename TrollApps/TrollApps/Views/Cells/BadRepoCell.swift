//
//  BadRepoCell.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-16.
//

import SwiftUI
import SwipeActions

struct BadRepoCell: View {
    @EnvironmentObject var userSettings: UserSettings
    
    let badRepo : BadRepoMemory
    let removeBadRepos: (Set<UUID>) -> Void
    
    var body: some View {
        SwipeView {
            HStack {
                let iconSize : CGFloat = userSettings.compactRepoView ? 35 : 48

                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.pink)
                    .frame(width: iconSize, height: iconSize)
                    .padding(.trailing, 8)
                VStack(alignment: .leading) {
                    Text("UNABLE_TO_LOAD_REPO")
                    if (!userSettings.compactRepoView) {
                        CollapsibleText(
                            text: badRepo.url,
                            isExpanded: .constant(false),
                            maxLines: 2
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
            .background(
                Color.white.opacity(0.001)
            )
            .contextMenu
            {
                Button(action: {
                    UIPasteboard.general.string = badRepo.url
                }, label:
                        {
                    Text("COPY_REPO_URL")
                })
                Button(action: {
                    UIPasteboard.general.string = reposEncode(reposUrl: [badRepo.url])
                }, label:
                        {
                    Text("COPY_REPO_BASE_URL")
                })
                Button(action: {
                    withAnimation {
                        removeBadRepos([badRepo.id])
                    }
                }, label:
                        {
                    Text("DELETE_REPO")
                })
            }
        } trailingActions: { _ in
            SwipeAction(systemImage: "trash", backgroundColor: .pink, highlightOpacity: 1) {
                withAnimation {
                    removeBadRepos([badRepo.id])
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
