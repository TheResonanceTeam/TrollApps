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
                Text(buttonText)
            }
        }
        
    }
    
    
}

struct DynamicInstallButton: View {
    @State private var DownloadingIPA = true
    @State private var InstallingIPAInfo: Application? = nil
    @State private var downloadError: Bool = false
        
    @EnvironmentObject var repoManager: RepositoryManager

    var appDetails: Application
    var selectedVersionIndex: Int

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
                                UIApplication.shared.alert(title: "An unknown error occoured while installing this app.", body: "Please retry this installation another time.", animated: false, withButton: true)
                                
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
                    
                    UIApplication.shared.alert(title: "Failed to download and parse app", body: "This could be due to missing permissions, a broken download link.", animated: false, withButton: true)
                    
                    updater("GET")
                }
            } else {
                UIApplication.shared.alert(title: "Failed to fetch app download url", body: "Likely a repo issue.", animated: false, withButton: true)
                
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
                            UIApplication.shared.alert(title: "Unable to update.", body: "This application was not initially installed through TrollStore and, as a result, cannot install this update. Consider uninstalling the application, then reinstalling in TrollApps.", animated: false, withButton: true)
                        }
                    }
                    case 2:
                    // Older Version
                    Button("OLDER") {} .disabled(true)
                    
                    default:
                        EmptyView()
                }
            }
        } else {
            DynamicButton(initialText: "GET") { updater in
                if(!repoManager.isInstallingApp) {
                    downloadAndInstallApp(updater: updater)

                } else {
                    UIApplication.shared.alert(title: "Unable to start app installation.", body: "Please wait for the current installation to finish.", animated: false, withButton: true)
                }
            }
        }
    }
    
    var body: some View {
        appButton(json: appDetails)
            .alert(isPresented: $updatingTrollApps, content: {
                Alert(
                    title: Text("TrollApps will close and you will be transfered to TrollStore to complete the update process."),
                    message: Text("Do you still wish to update TrollApps?"),
                    primaryButton: .default(Text("Yes")) {
                        let downloadURL = appDetails.versions?[selectedVersionIndex].downloadURL
                        
                        if let downloadURL = downloadURL {
                            let formattedURL = downloadURL.replacingOccurrences(of: "apple-magnifier://install?url=", with: "")
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
                    secondaryButton: .cancel(Text("Cancel")) {}
                )
            })
    }
}


