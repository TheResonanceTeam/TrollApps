//
//  DynamicInstallButton.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI

struct DynamicButton: View {
    var initialText: String
    var action: ( @escaping (String) -> Void) -> Void

    @State private var buttonText: String

    init(initialText: String, action: @escaping ( @escaping (String) -> Void) -> Void) {
        self.initialText = initialText
        self.action = action
        self._buttonText = State(initialValue: initialText)
    }

    var body: some View {
        Button(action: {
            action { newText in
                buttonText = newText
            }
        }) {
            if buttonText == "Loading..." {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundColor(.white)
                    .padding(8)
            } else {
                Text(LocalizedStringKey(buttonText))
            }
        }
        
    }
}

struct DynamicInstallButton: View {
    @State private var DownloadingIPA = true
    @State private var InstallingIPAInfo: Application? = nil
    @State private var downloadError: Bool = false
        
    @EnvironmentObject var repoManager: RepositoryManager
    @EnvironmentObject var alertManager: AlertManager

    var appDetails: Application
    var selectedVersionIndex: Int
    var buttonStyle: String

    @State var isInstalled: Bool = false
    
    @State var updatingTrollApps: Bool = false
    
    func downloadAndInstallApp(updater: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            repoManager.isInstallingApp = true
            InstallingIPAInfo = appDetails
            DownloadingIPA = true
            updater("Loading...")
            
            let downloadURL = appDetails.versions?[selectedVersionIndex].downloadURL
            
            if let downloadURL = downloadURL {
                let formattedURL = downloadURL.replacingOccurrences(of: "apple-magnifier://install?url=", with: "")
                if DownloadIPA(formattedURL) {
                    DownloadingIPA = false
                    InstallIPA("/var/mobile/TrollApps-Tmp-IPA.ipa")
                    repoManager.isInstallingApp = false
                    InstallingIPAInfo = nil
                                        
                    DispatchQueue.main.async {
                        withAnimation {
                            repoManager.InstalledApps = GetApps()
                            
                            if !repoManager.IsAppInstalled(appDetails.bundleIdentifier ?? "") {
                                isInstalled = false

                                alertManager.showAlert(
                                    title: "UNKNOWN_ERROR_WHILE_INSTALLING",
                                    body: "PLEASE_RETRY_LATER"
                                )
                                
                                updater("GET")
                            } else {
                                isInstalled = true
                            }
                        }
                    }
                } else {
                    DownloadingIPA = false
                    repoManager.isInstallingApp = false
                    InstallingIPAInfo = nil
                    downloadError = true
                    
                    alertManager.showAlert(
                        title: "FAILED_TO_DOWNLOAD_OR_PARSE_APP",
                        body: "THIS_COULD_BE_MISSING_PERMS_OR_BROKEN_LINK"
                    )
                    
                    updater("GET")
                }
            } else {
                
                alertManager.showAlert(
                    title: "FAILED_TO_FETCH_APP_DOWNLOAD_URL",
                    body: "LIKELY_REPO_ISSUE"
                )

                updater("GET")
            }
        }
    }

    @ViewBuilder
    func appButton(json: Application) -> some View {
        if repoManager.IsAppInstalled(json.bundleIdentifier ?? "") || isInstalled {
            
            let appVersion = appDetails.versions?[selectedVersionIndex].version
            
            if let version = appVersion {
                
                let status = repoManager.showUpdateButton(version1: version, BundleID: json.bundleIdentifier ?? "")

                switch(status) {
                    case 0:
                    // Installed
                    Button("OPEN") {
                        OpenApp(json.bundleIdentifier ?? "")
                    }
                    .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: false) : AppStoreStyle(type: "blue", dissabled:false))

                    case 1:
                    // Need to Update
                    DynamicButton(initialText: "UPDATE") { updater in
                        let isTollStoreManaged = repoManager.IsTrollStoreManaged(json.bundleIdentifier ?? "")
                        if (isTollStoreManaged) {
                            if json.bundleIdentifier == Bundle.main.bundleIdentifier {
                                updatingTrollApps = true
                            } else {
                                downloadAndInstallApp(updater: updater)
                            }
                        } else {
                            
                            alertManager.showAlert(
                                title: "UNABLE_TO_UPDATE",
                                body: "NOT_TROLLSTORE_MANAGED"
                            )

                        }
                    }
                    .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: false) : AppStoreStyle(type: "blue", dissabled:false))

                    case 2:
                    // Older Version
                    Button("OLDER") {} .disabled(true)
                        .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: true) : AppStoreStyle(type: "blue", dissabled: true))

                    default:
                        EmptyView()
                }
            }
        } else {
            DynamicButton(initialText: "GET") { updater in
                if(!repoManager.isInstallingApp) {
                    downloadAndInstallApp(updater: updater)

                } else {
                    
                    alertManager.showAlert(
                        title: "UNABLE_TO_START_INSTALL",
                        body: "PLEASE_WAIT_FOR_CURRENT_INSTALL_TO_FINISH"
                    )
                    
                }
            }
            .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: false) : AppStoreStyle(type: "blue", dissabled:false))
        }
    }
    
    var body: some View {
        appButton(json: appDetails)
            .alert(isPresented: $updatingTrollApps, content: {
                Alert(
                    title: Text("TROLLAPPS_WILL_CLOSE"),
                    message: Text("DO_YOU_STILL_WISH_TO_UPDATE"),
                    primaryButton: .default(Text("YES")) {
                        let downloadURL = appDetails.versions?[selectedVersionIndex].downloadURL
                        
                        if let downloadURL = downloadURL {
                            _ = downloadURL.replacingOccurrences(of: "apple-magnifier://install?url=", with: "")
                            if let url = URL(string: "apple-magnifier://install?url=\(downloadURL)"), UIApplication.shared.canOpenURL(url) {
                                
                                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                        exit(0)
                                    }
                                })
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("CANCEL")) {}
                )
            })
    }
}


