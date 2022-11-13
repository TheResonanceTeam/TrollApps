//
//  OtherView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

struct OtherView: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Thanks to..."), footer: Text("Biggest thanks to these wonderful apps, articles and people! Without them, this project won't be possible or would not even exist!")) {
                    Label {
                        HStack {
                            Button("Interactful App - GET Button Style") {
                                openURL(URL(string: "https://apps.apple.com/us/app/interact-a-field-guide/id1528095640")!)
                            }
                        }
                    } icon: {
                        AsyncImage(url: URL(string: "https://cdn.discordapp.com/attachments/969879614379921418/1040884975098150912/interactful.png")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.black
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("AppInstaller iOS - JSON Fetching") {
                                openURL(URL(string: "https://twitter.com/AppInstalleriOS")!)
                            }
                        }
                    } icon: {
                        AsyncImage(url: URL(string: "https://appinstallerios.com/Img/AppInstalleriOSIcon.png")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.black
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("@talhah58 - App Idea") {
                                openURL(URL(string: "https://twitter.com/talhah58")!)
                            }
                        }
                    } icon: {
                        AsyncImage(url: URL(string: "https://media.discordapp.net/attachments/969879614379921418/1040888990368284702/talhah.png")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.black
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("Andrean Prabowo - Undo free icon") {
                                openURL(URL(string: "https://www.flaticon.com/free-icon/undo_3272462?term=rounded%20arrow&page=1&position=24&page=1&position=24&related_id=3272462&origin=search")!)
                            }
                        }
                    } icon: {
                        AsyncImage(url: URL(string: "https://cdn-teams-slug.flaticon.com/andrean-prabowo.jpg")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.black
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    
                }
            }
            .navigationTitle("Credits")
        }
        .navigationViewStyle(.stack)
    }
}

struct OtherView_Previews: PreviewProvider {
    static var previews: some View {
        OtherView()
    }
}
