//
//  FeaturedView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 21.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FeaturedView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.scenePhase) var scenePhase
    @State private var isDetailViewPresented = false
    @State private var apps: [stuff] = []
    @State private var installedAppsBundleIDs = [String]()
    @State private var InstallingIPA = false
    @State private var DownloadingIPA = true
    @State private var InstallingIPAInfo: stuff? = nil
    @State private var downloadError: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertToPresent: Alert?
    
    @ViewBuilder
    func appButton(json: stuff)->some View {
        if isAppInstalled(json.bundleIdentifier) {
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
                        if DownloadIPA(json.downloadURL.replacingOccurrences(of: "apple-magnifier://install?url=", with: "")) {
                            DownloadingIPA = false
                            InstallIPA("/var/mobile/TrollApps-Tmp-IPA.ipa")
                            InstallingIPA = false
                            InstallingIPAInfo = nil
                            Task { await refresh() }
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
        }
    }
    
    var body: some View {
        NavigationView {
            let form = Form {
                Section {
                    ForEach(apps) { json in
                        NavigationLink(destination: AppDetailsView(appDetails: json)) {
                            Label {
                                HStack {
                                    Text(json.name)
                                    Spacer()
                                    appButton(json: json)
                                        .buttonStyle(AppStoreStyle())
                                }
                            } icon: {
                                WebImage(url: URL(string: json.iconURL))
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                            }
                        }
                    }
                }
            }
                .onAppear { Task { await refresh() } }
                .environment(\.defaultMinListRowHeight, 50)
                .navigationTitle("Featured")
            //  from https://www.hackingwithswift.com/books/ios-swiftui/how-to-be-notified-when-your-swiftui-app-moves-to-the-background
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        print("Active, will refresh")
                        Task(operation: refresh)
                    }
                }
            if #available(iOS 15.0, *) {
                form
                    .refreshable {
                        Task{await refresh()}
                    }
            } else {
                form
                    .toolbar{
                        ToolbarItem(placement: .navigationBarTrailing){
                            AsyncButton(action: refresh){
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
            }
        }
        .alert(isPresented: $showAlert) {
            alertToPresent ?? Alert(title: Text("Default Title"), message: Text("Default Message"))
        }
    }
    
    @Sendable
    func refresh() async {
        let currentInstalledAppsBundleIDs = GetApps()
        DispatchQueue.main.async {
            withAnimation{
                self.installedAppsBundleIDs=currentInstalledAppsBundleIDs
            }
        }
        guard let updatedApps = await FetchFeaturedApps() else { return }
        DispatchQueue.main.async {
            withAnimation{
                self.apps=updatedApps
            }
        }
    }
    func isAppInstalled(_ BundleID: String) -> Bool {
        installedAppsBundleIDs.contains(BundleID)
    }
}

struct FeaturedView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedView()
    }
}
