//
//  OtherView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct OtherView: View {
    @Environment(\.openURL) var openURL
    @State private var safemode = true
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var alertManager: AlertManager

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("OPTIONS"), footer: Text("DELETE_CACHE_TOOLTIP")) {
                    Button("DELETE_CACHE") {
                        
                        alertManager.showAlert(
                            title: "CLEARING_CACHE",
                            body: "PLEASE_WAIT",
                            showButtons: false
                        )
                        
                        SDImageCache.shared.clearMemory()
                        SDImageCache.shared.clearDisk()
                        URLCache.shared.removeAllCachedResponses()
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                            
                            alertManager.showAlert(
                                title: "SUCCESS",
                                body: "THE_APP_WILL_NOW_QUIT",
                                showButtons: false
                            )
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                    exit(0)
                                }
                            })
                        }
                    }
                    Button("RESET_REPOS") {
                        
                        alertManager.showAlert(
                            title: "RESETING_REPOS",
                            body: "PLEASE_WAIT",
                            showButtons: false
                        )
                        
                        if let bundleID = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundleID)
                        }
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                            
                            alertManager.showAlert(
                                title: "SUCCESS",
                                body: "THE_APP_WILL_NOW_QUIT",
                                showButtons: false
                            )
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                    exit(0)
                                }
                            })
                        }
                    }
                    .foregroundColor(Color.red)
                    Button("RELOAD_SPRINGBOARD") {
                        
                        alertManager.showAlert(
                            title: "RELOADING_SPRINGBOARD",
                            body: "PLEASE_WAIT"
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            guard let window = UIApplication.shared.windows.first else { return }
                            while true {
                                window.snapshotView(afterScreenUpdates: false)
                            }
                        })
                    }
                }
                
                Section(header: Text("APP_SETTINGS")) {
                    Toggle("REDUCED_MOTION", isOn: $userSettings.reducedMotion)
                    
                    let langOptions = ["en", "zh", "de", "id", "ar"]

                    
                    Picker("APP_LANGUAGE", selection: $userSettings.lang) {
                        ForEach(langOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("DEVELOPERS")) {
                    Label {
                        HStack {
                            Button("Haxi0") {
                                openURL(URL(string: "https://www.github.com/Haxi0")!)
                            }
                        }
                    } icon: {
                        Image("Haxi0Icon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("Cleover") {
                                openURL(URL(string: "https://www.github.com/Cleover")!)
                            }
                        }
                    } icon: {
                        Image("CleoverIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("BonnieDev") {
                                openURL(URL(string: "https://www.github.com/Bonnie39")!)
                            }
                        }
                    } icon: {
                        Image("BonnieDevIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                }
                
                Section(header: Text("THANKS_TO"), footer: Text("THANKS_TO_TOOLTIP")) {
                    Label {
                        HStack {
                            Button("@AppInstalleriOS") {
                                openURL(URL(string: "https://twitter.com/AppInstalleriOS")!)
                            }
                        }
                    } icon: {
                        Image("AppInstalleriOSIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("@sourceloc") {
                                openURL(URL(string: "https://twitter.com/sourceloc")!)
                            }
                        }
                    } icon: {
                        Image("sourcelocationIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("@talhah58") {
                                openURL(URL(string: "https://twitter.com/talhah58")!)
                            }
                        }
                    } icon: {
                        Image("TalhahIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        Button("Interactful App") {
                            openURL(URL(string: "https://apps.apple.com/us/app/interact-a-field-guide/id1528095640")!)
                        }
                    } icon: {
                        Image("InteractfulIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("iOScreator") {
                                openURL(URL(string: "https://www.ioscreator.com/tutorials/swiftui-json-list-tutorial")!)
                            }
                        }
                    } icon: {
                        Image("iOScreatorIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    Label {
                        HStack {
                            Button("Andrean Prabowo") {
                                openURL(URL(string: "https://www.flaticon.com/free-icon/undo_3272462?term=rounded%20arrow&page=1&position=24&page=1&position=24&related_id=3272462&origin=search")!)
                            }
                        }
                    } icon: {
                        Image("AndreanPrabowoIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                }
                
                
                
                Section(header: Text("OTHER_PROJECTS_AND_LICENSES")) {
                    Button("SDWebImageSwiftUI Project") {
                        openURL(URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI")!)
                    }
                    Button("SDWebImageSwiftUI MIT License") {
                        openURL(URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI/blob/master/LICENSE")!)
                    }
                }
                
                Section(header: Text("HELP_THE_PROJECT")) {
                    Button("JOIN_OUR_DISCORD") {
                        openURL(URL(string: "https://discord.gg/PrF6XqpGgX")!)
                    }
                    Button("REPORT_A_BUG") {
                        openURL(URL(string: "https://discord.gg/PrF6XqpGgX")!)
                    }.foregroundColor(Color.red)
                    Button("JSON_TEMPLATE") {
                        openURL(URL(string: "https://raw.githubusercontent.com/TheResonanceTeam/.default-sources/main/haxi0_2.0.json")!)
                    }
                }
            }
            .navigationTitle("SETTINGS")
        }
        .navigationViewStyle(.stack)
    }
}
