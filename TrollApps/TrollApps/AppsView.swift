//
//  AppsView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct AppsView: View {
    @Environment(\.openURL) var openURL
    @State private var isshowingdesc = false
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(FetchApps()) { json in
                    Section(header: Text(json.title)) {
                        Label {
                            HStack {
                                Text(json.title)
                                Spacer()
                                Button(IsAppInstalled(json.bundleid) ? "OPEN" : "GET") {
                                    if IsAppInstalled(json.bundleid) {
                                        OpenApp(json.bundleid)
                                    } else {
                                        openURL(URL(string: json.link)!)
                                    }
                                }
                                .buttonStyle(appstorestyle())
                            }
                        } icon: {
                            WebImage(url: URL(string: json.urlimg))
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        if isshowingdesc {
                            VStack {
                                Text(json.description)
                                    .opacity(0.3)
                                    .transition(.scale)
                                Button("Copy \(json.title) .IPA Link") {
                                    UIPasteboard.general.string = json.url
                                }
                                .buttonStyle(somebuttonstyle())
                            }
                        }
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle("Apps")
            .toolbar {
                Button {
                    withAnimation {
                        isshowingdesc.toggle()
                    }
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
}
