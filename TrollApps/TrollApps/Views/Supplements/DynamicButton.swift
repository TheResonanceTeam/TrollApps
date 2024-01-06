//
//  DynamicInstallButton.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-01.
//

import SwiftUI

struct DynamicInstallButton: View {
    @EnvironmentObject var repoManager: RepositoryManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var queueManager: QueueManager

    var appDetails: Application
    var selectedVersionIndex: Int
    var buttonStyle: String
    
    @State var updatingTrollApps: Bool = false

    enum ButtonAction {
        case open, update, older, queued, get
    }

    @ViewBuilder
    func appButton(json: Application) -> some View {
        if repoManager.IsAppInstalled(json.bundleIdentifier ?? "") {
            if let version = appDetails.versions?[selectedVersionIndex].version {
                let status = repoManager.showUpdateButton(version1: version, BundleID: json.bundleIdentifier ?? "")
                
                switch status {
                case 0:
                    openButton(bundleIdentifier: json.bundleIdentifier ?? "")
                    
                case 1:
                    if queueManager.hasQueueItem(bundleIdentifier: appDetails.bundleIdentifier ?? "") {
                        queuedButton()
                    } else {
                        updateButton(bundleIdentifier: json.bundleIdentifier ?? "")
                    }
                case 2:
                    olderButton()
                    
                default:
                    EmptyView()
                }
            }
        } else {
            if queueManager.hasQueueItem(bundleIdentifier: appDetails.bundleIdentifier ?? "") {
                queuedButton()
            } else {
                getButton()
            }
        }
    }
    
    var body: some View {
        appButton(json: appDetails)
            .alert(isPresented: $updatingTrollApps, content: {
                Alert(
                    title: Text("TROLLAPPS_WILL_CLOSE"),
                    message: Text("DO_YOU_STILL_WISH_TO_UPDATE"),
                    primaryButton: .default(Text("YES")) {
                        updateTrollApps()
                    },
                    secondaryButton: .cancel(Text("CANCEL")) {}
                )
            })
    }

    private func openButton(bundleIdentifier: String) -> some View {
        let isMainBundle : Bool = bundleIdentifier == Bundle.main.bundleIdentifier
        return Button("OPEN") {
            if bundleIdentifier != Bundle.main.bundleIdentifier {
                OpenApp(bundleIdentifier)
            }
        }
        .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: false) : AppStoreStyle(type: "blue", dissabled: isMainBundle))
    }

    private func updateButton(bundleIdentifier: String) -> some View {
        Button("UPDATE") {
            let isTollStoreManaged = repoManager.IsTrollStoreManaged(bundleIdentifier)
            if isTollStoreManaged {
                if bundleIdentifier == Bundle.main.bundleIdentifier {
                    updatingTrollApps = true
                } else {
                    addAppToQueue()
                }
            } else {
                alertManager.showAlert(
                    title: Text(LocalizedStringKey("UNABLE_TO_UPDATE")),
                    body: Text(LocalizedStringKey("NOT_TROLLSTORE_MANAGED"))
                )
            }
        }
        .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: false) : AppStoreStyle(type: "blue", dissabled: false))
    }

    private func olderButton() -> some View {
        Button("OLDER") {}
        .disabled(true)
        .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: true) : AppStoreStyle(type: "blue", dissabled: true))
    }

    private func queuedButton() -> some View {
        
        // check if this download url matches the download url of the current item, if not, show a greyed out version.
        
        var isDissabled : Bool = false;
        
        if appDetails.versions?[selectedVersionIndex].downloadURL != queueManager.getQueueItem(bundleIdentifier: appDetails.bundleIdentifier ?? "")?.downloadURL {
            isDissabled = true
        }
        
        return Button("QUEUED") {
            queueManager.removeQueueItem(bundleIdentifier: appDetails.bundleIdentifier ?? "")
        }
        .buttonStyle(AppStoreStyle(type: "pink", dissabled: isDissabled))
        .disabled(isDissabled)
    }

    private func getButton() -> some View {
        Button("GET") {
            addAppToQueue()
        }
        .buttonStyle(buttonStyle == "Main" ? AppStoreStyle(type: "gray", dissabled: false) : AppStoreStyle(type: "blue", dissabled: false))
    }

    private func addAppToQueue() {
        if !queueManager.isProcessing {
            if queueManager.hasQueueItem(bundleIdentifier: appDetails.bundleIdentifier ?? "") {
                alertManager.showAlert(
                    title: Text("Item already in queue"),
                    body: Text(""),
                    showButtons: false, showBody: false
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    alertManager.isAlertPresented = false
                })
            } else {
                queueManager.addQueueItem(
                    item:
                        QueueItem(
                            action: .download,
                            icon: appDetails.iconURL,
                            name: appDetails.name,
                            bundleIdentifier: appDetails.bundleIdentifier,
                            downloadURL: appDetails.versions?[selectedVersionIndex].downloadURL
                        )
                )
            }
        }
    }

    private func updateTrollApps() {
        let downloadURL = appDetails.versions?[selectedVersionIndex].downloadURL

        if let downloadURL = downloadURL,
           let url = URL(string: downloadURL.replacingOccurrences(of: "apple-magnifier://install?url=", with: "")),
           UIApplication.shared.canOpenURL(url) {
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    exit(0)
                }
            })
        }
    }
}
