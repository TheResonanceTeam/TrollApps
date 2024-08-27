//
//  SettingsView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import SwiftUI
import Kingfisher

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    
    @State private var safemode = true
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var alertManager: AlertManager
    
    @StateObject private var cacheSize = ImageCacheViewModel()

    var body: some View {
        VStack {
            Form {
                Section {
                    Button("JOIN_OUR_DISCORD") {
                        openURL(URL(string: "https://discord.gg/PrF6XqpGgX")!)
                    }
                    .buttonStyle(LongButtonStyle(type: "pink", dissabled: false))
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Section(header: Text("OPTIONS"), footer: Text("CLEAR_CACHE_TOOLTIP")) {
                    
                    Button(action: {
                        alertManager.showAlert(
                            title: Text(LocalizedStringKey("CLEARING_IMAGE_CACHE")),
                            body: Text(LocalizedStringKey("PLEASE_WAIT")),
                            showButtons: false
                        )
                        ImageCache.default.clearCache()
                        URLCache.shared.removeAllCachedResponses()
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                            
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("SUCCESS")),
                                body: Text(LocalizedStringKey("THE_APP_WILL_NOW_QUIT")),
                                showButtons: false
                            )
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                    exit(0)
                                }
                            })
                        }
                     }) {
                         HStack {
                             Text("CLEAR_IMAGE_CACHE")
                             Spacer()
                             Text(cacheSize.diskCacheSize)
                                 .onAppear {
                                     cacheSize.calculateDiskCacheSize()
                                 }
                         }
                     }
                    Button("RESET_REPOS") {
                        
                        alertManager.showAlert(
                            title: Text(LocalizedStringKey("RESETING_REPOS")),
                            body: Text(LocalizedStringKey("PLEASE_WAIT")),
                            showButtons: false
                        )
                        
                        if let bundleID = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundleID)
                        }
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                            
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("SUCCESS")),
                                body: Text(LocalizedStringKey("THE_APP_WILL_NOW_QUIT")),
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
                    .foregroundColor(Color.pink)
                    Button("RELOAD_SPRINGBOARD") {
                        
                        alertManager.showAlert(
                            title: Text(LocalizedStringKey("RELOADING_SPRINGBOARD")),
                            body: Text(LocalizedStringKey("PLEASE_WAIT"))
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            guard let window = UIApplication.shared.windows.first else { return }
                            while true {
                                window.snapshotView(afterScreenUpdates: false)
                            }
                        })
                    }
                    Button("Show \"Whats New\" Popup") {
                        UserDefaults.standard.set("", forKey: "appVersion")
                        
                        alertManager.showAlert(
                            title: Text("The app will close."),
                            body: Text("Please re-open the app to view the \"Whats New\" popup"),
                            showButtons: false
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                exit(0)
                            }
                        })
                    }
                }
                
                Section(header: Text("APP_SETTINGS")) {
                    Toggle("COMPACT_REPO_VIEW", isOn: $userSettings.compactRepoView)
                    Toggle("Skip Install Prompt", isOn: $userSettings.skipInstallPrompt)

                    let keyboardNames = [
                        "URL",
                        "Normal"
                    ]

                    let keyboardOptions: [UIKeyboardType] = [
                        .URL,
                        .alphabet
                    ]
                    
                    Picker("ADD_REPO_KEYBOARD_TYPE", selection: $userSettings.addRepoKeyboardType) {
                        ForEach(keyboardNames.indices, id: \.self) { index in
                            Text(keyboardNames[index]).tag(keyboardOptions[index])
                        }
                    }
                    .pickerStyle(.menu)
                                        
                    Text(String(format:  NSLocalizedString("CURRENT_BLUR_STRENGTH %@", comment: "Current Blur Strength"), "\(Int(userSettings.blurStrength))"))
                    
                    Slider(value: $userSettings.blurStrength, in: 0...20)
                    
                    let langNames = [
                      "English",
                      "简体中文",
                      "繁體中文",
                      "Deutsch",
                      "Bahasa Indonesia",
                      "العربية",
                      "Norsk bokmål"
                    ];
                    
                    let langOptions = [
                        "en",
                        "zh-hans",
                        "zh-hant",
                        "de",
                        "id",
                        "ar",
                        "nb"
                    ];

                    Picker("APP_LANGUAGE", selection: $userSettings.lang) {
                        ForEach(langOptions.indices, id: \.self) { index in
                            Text(langNames[index]).tag(langOptions[index])
                        }
                    }
                    .onChange(of: userSettings.lang) { newLang in
                        alertManager.showAlert(
                            title: Text(LocalizedStringKey("LANG_SWITCHED")),
                            body: Text(LocalizedStringKey("PLEASE_RESTART_THIS_APP_FOR_THIS_TO_TAKE_EFFECT")),
                            showButtons: true
                        )
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("DEVELOPERS")) {
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
                            Button("kixrd") {
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
                
                Section(header: Text("TRANSLATORS"), footer: Text("THANKS_TO_TRANSLATORS")) {
                    VStack(alignment: .leading) {
                        Text("ting0441")
                        Text("🇨🇳 Chinese (Simplified) - (简体中文)")
                            .font(.footnote)
                    }
                    .padding(.vertical, 0.5)
                    VStack(alignment: .leading) {
                        Text("olivertzeng")
                        Text("🇹🇼 Chinese (Traditional) - (繁體中文)")
                            .font(.footnote)
                    }
                    .padding(.vertical, 0.5)
                    VStack(alignment: .leading) {
                        Text("vale_epr")
                        Text("🇩🇪 German - Deutsch")
                            .font(.footnote)
                    }
                    .padding(.vertical, 0.5)
                    VStack(alignment: .leading) {
                        Text("ferdy_sambo")
                        Text("🇮🇩 Indonesian - Bahasa Indonesia")
                            .font(.footnote)
                    }
                    .padding(.vertical, 0.5)
                    VStack(alignment: .leading) {
                        Text("cartisburger")
                        Text("🇦🇪 Arabic - العربية")
                            .font(.footnote)
                    }
                    .padding(.vertical, 0.5)
                    VStack(alignment: .leading) {
                        Text("realbonnie39")
                        Text("🇳🇴 Norwegian - Norsk bokmål")
                            .font(.footnote)
                    }
                    .padding(.vertical, 0.5)
                }
                
                Section(header: Text("OTHER_PROJECTS_AND_LICENSES")) {
                    Button("Kingfisher") {
                        openURL(URL(string: "https://github.com/onevcat/Kingfisher")!)
                    }
                    Button("BottomSheet") {
                        openURL(URL(string: "https://github.com/lucaszischka/BottomSheet")!)
                    }
                    Button("SwipeActions") {
                        openURL(URL(string: "https://github.com/aheze/SwipeActions")!)
                    }
                    Button("SwiftUI Introspect") {
                        openURL(URL(string: "https://github.com/siteline/swiftui-introspect")!)
                    } 
                }
                
                Section(header: Text("HELP_THE_PROJECT")) {
                    Button("REPORT_A_BUG") {
                        openURL(URL(string: "https://discord.gg/PrF6XqpGgX")!)
                    }.foregroundColor(Color.pink)
                    Button("JSON_TEMPLATE") {
                        openURL(URL(string: "https://raw.githubusercontent.com/TheResonanceTeam/.default-sources/main/haxi0_2.0.json")!)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationTitle("SETTINGS")
        .navigationBarTitle("", displayMode: .inline)
    }
}

class ImageCacheViewModel: ObservableObject {
    @Published var diskCacheSize: String = "Loading..."

    func calculateDiskCacheSize() {
        ImageCache.default.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                DispatchQueue.main.async {
                    self.diskCacheSize = String(format: "%.2f MB", Double(size) / 1024 / 1024)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.diskCacheSize = "Unknown"
                }
            }
        }
    }
}
