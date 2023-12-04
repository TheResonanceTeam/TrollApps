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
    
    @State private var showAlert: Bool = false
    @State private var alertToPresent: Alert?
    
    var appDetails: Application
//    var refreshCallback: () -> Void
    @State var installedAppsBundleIDs = [String]()
    var selectedVersionIndex: Int
    @State var isInstalled: Bool = false


    @ViewBuilder
    func appButton(json: Application)->some View {
        if isAppInstalled(json.bundleIdentifier) || isInstalled {
            Button("OPEN") {
                OpenApp(json.bundleIdentifier)
            }
        } else {
            DynamicButton(initialText: "GET") { updater in
                if(InstallingIPA == false) {
                    DispatchQueue.global(qos: .utility).async {
                        InstallingIPA = true
                        InstallingIPAInfo = json
                        DownloadingIPA = true
                        updater("Loading...")
                        
                        // CHECK IF downloadURL != nil, and if so, try to instead use json.versions (which can also possibly = nil) and if it has atleast one value int the array use json.versions[0].downloadURL instead
                        
                        let downloadURL = appDetails.versions?[selectedVersionIndex].downloadURL ?? appDetails.downloadURL
                                                                        
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
                                
                                
                                let alert = Alert(
                                    title: Text("Failed to install app"),
                                    message: Text("This could be due to missing permissions."),
                                    dismissButton: .default(Text("Ok"))
                                )
                                
                                DispatchQueue.main.async {
                                    showAlert = true
                                    alertToPresent = alert
                                }
                            }
                        } else {
                            updater("GET")
                            let alert = Alert(
                                title: Text("Failed to fetch app download url"),
                                message: Text("Likely a repo issue."),
                                dismissButton: .default(Text("Ok"))
                            )
                            
                            DispatchQueue.main.async {
                                showAlert = true
                                alertToPresent = alert
                            }
                        }
                    }
                } else {
                    let alert = Alert(
                        title: Text("Unable to start installation"),
                        message: Text("Please wait for your other installation to finish."),
                        dismissButton: .default(Text("Ok"))
                    )

                    DispatchQueue.main.async {
                        showAlert = true
                        alertToPresent = alert
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                alertToPresent ?? Alert(title: Text("Default Title"), message: Text("Default Message"))
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


