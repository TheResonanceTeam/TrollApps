//
//  OtherView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage

struct OtherView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Options"), footer: Text("The Delete Cache button should be used if the app weights a bit too much on your Device.")) {
                    Button("Delete Cache") {
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                    }
                }
                
                Section(header: Text("Thanks to..."), footer: Text("Biggest thanks to these wonderful apps, articles and people! Without them, this project won't be possible or would not even exist!")) {
                    Label {
                        HStack {
                            Button("@AppInstalleriOS - REALLY helped the project") {
                                openURL(URL(string: "https://twitter.com/AppInstalleriOS")!)
                            }
                        }
                    } icon: {
                        WebImage(url: URL(string: "https://appinstallerios.com/Img/AppInstalleriOSIcon.png"))
                            .resizable()
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
                        WebImage(url: URL(string: "https://media.discordapp.net/attachments/969879614379921418/1040888990368284702/talhah.png"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        Button("Interactful App - GET Button Style") {
                            openURL(URL(string: "https://apps.apple.com/us/app/interact-a-field-guide/id1528095640")!)
                        }
                    } icon: {
                        WebImage(url: URL(string: "https://cdn.discordapp.com/attachments/969879614379921418/1040884975098150912/interactful.png"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("iOScreator - JSON Fetching") {
                                openURL(URL(string: "https://www.ioscreator.com/tutorials/swiftui-json-list-tutorial")!)
                            }
                        }
                    } icon: {
                        WebImage(url: URL(string: "https://cdn.discordapp.com/attachments/969879614379921418/1040887934640979988/iOScreator.png"))
                            .resizable()
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
                        WebImage(url: URL(string: "https://cdn-teams-slug.flaticon.com/andrean-prabowo.jpg"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                }
                
                Section(header: Text("Other projects used and their licenses")) {
                    Button("SDWebImageSwiftUI Project") {
                        openURL(URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI")!)
                    }
                    Button("SDWebImageSwiftUI MIT License") {
                        openURL(URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI/blob/master/LICENSE")!)
                    }
                }
                
                Section(header: Text("Help the project"), footer: Text("If you are having any issues with this project, you can report a bug by pressing the button above. Please describe the problem properly, so I can fix it. :)")) {
                    Button("Report a Bug!") {
                        openURL(URL(string: "https://github.com/haxi0/TrollApps/issues/new")!)
                    }.foregroundColor(Color.red)
                }
            }.navigationTitle("Other")
        }
    }
}
