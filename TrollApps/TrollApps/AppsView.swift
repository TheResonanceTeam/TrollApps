//
//  AppsView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

struct AppsView: View {
    @Environment(\.openURL) var openURL
    @ObservedObject var fetch = fetchtd()
    
    var body: some View {
        NavigationView {
            List(fetch.jsonstuff) { json in
                Label {
                    HStack {
                        Text(json.title)
                        Spacer()
                        Button("GET") {
                            openURL(URL(string: json.link)!)
                        }.buttonStyle(appstorestyle())
                    }
                } icon: {
                    AsyncImage(url: URL(string: json.urlimg)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.black
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }.navigationTitle("Apps")
        }
    }
}

struct AppsView_Previews: PreviewProvider {
    static var previews: some View {
        AppsView()
    }
}
