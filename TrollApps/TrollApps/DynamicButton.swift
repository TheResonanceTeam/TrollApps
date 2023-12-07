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
    @State private var InstallingIPA = false
    @State private var DownloadingIPA = true
    @State private var InstallingIPAInfo: Application? = nil
    @State private var downloadError: Bool = false
    
    var appDetails: Application
//    var refreshCallback: () -> Void
    @State var installedAppsBundleIDs = [String]()
    var selectedVersionIndex: Int
    @State var isInstalled: Bool = false


    @ViewBuilder
    func appButton(json: Application)->some View {
        if isAppInstalled(json.bundleIdentifier ?? "") || isInstalled {
            Button("OPEN") {
                OpenApp(json.bundleIdentifier ?? "")
            }
        } else {
            DynamicButton(initialText: "GET") { updater in
                if(InstallingIPA == false) {
                    DispatchQueue.global(qos: .utility).async {
                        InstallingIPA = true
                        InstallingIPAInfo = json
                        DownloadingIPA = true
                        updater("Loading...")
                        
                        let downloadURL = appDetails.versions?[selectedVersionIndex].downloadURL
                                                                        
                        if let downloadURL = downloadURL {
                            let formattedURL = downloadURL.replacingOccurrences(of: "apple-magnifier://install?url=", with: "")
                            if DownloadIPA(formattedURL) {
                                DownloadingIPA = false
                                InstallIPA("/var/mobile/TrollApps-Tmp-IPA.ipa")
                                InstallingIPA = false
                                InstallingIPAInfo = nil
                                isInstalled = true
                            } else {
                                DownloadingIPA = false
                                InstallingIPA = false
                                InstallingIPAInfo = nil
                                downloadError = true
                                updater("GET")
                                
                                UIApplication.shared.alert(title: "Failed to install app", body: "This could be due to missing permissions.", animated: false, withButton: true)
                            }
                        } else {
                            UIApplication.shared.alert(title: "Failed to fetch app download url", body: "Likely a repo issue.", animated: false, withButton: true)
                        }
                    }
                } else {
                    UIApplication.shared.alert(title: "Unable to start installation", body: "Please wait for your other installation to finish.", animated: false, withButton: true)
                }
            }
        }
    }
    
    var body: some View {
        appButton(json: appDetails)
            .buttonStyle(AppStoreStyle())
    }

    func isAppInstalled(_ BundleID: String) -> Bool {
        installedAppsBundleIDs.contains(BundleID)
    }
}


