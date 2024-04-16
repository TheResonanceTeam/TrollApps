//
//  AppCell.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-16.
//

import SwiftUI
import Kingfisher

struct AppCell: View {
    let app : Application
    let showFullMode: Bool
    
    var body: some View {
        let version = (app.versions?[0].version != nil && app.versions?[0].version != "" ? (app.versions?[0].version ?? "") : "")
        let devName = (app.developerName != nil && app.developerName != "" ? (app.developerName ?? "") : "")
        
        VStack(alignment: .leading) {
            HStack {
                if(app.iconURL != "") {
                    KFImage(URL(string: app.iconURL))
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 7)
                    
                } else {
                    Image("MissingApp")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 7)
                }
                
                VStack(alignment: .leading) {
                    Text(app.name)
                    CollapsibleText(text: devName , isExpanded: .constant(false), maxLines: 1)
                        .font(.caption)
                        .foregroundColor(.gray)
                    CollapsibleText(text: version , isExpanded: .constant(false), maxLines: 1)
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
                                KFImage(URL(string: screenshots[index]))
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
        .background(
            NavigationLink("", destination: AppDetailsView(appDetails: app))
                .opacity(0)
        )
    }
}
