//
//  AppDetailsView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-11-30.
//

import SwiftUI
import SDWebImageSwiftUI

struct AppDetailsView: View {
    var appDetails: stuff

    @State private var InstallingIPA = false
    @State private var DownloadingIPA = true
    @State private var InstallingIPAInfo: stuff? = nil
    @State private var downloadError: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertToPresent: Alert?
    @State private var installedAppsBundleIDs = [String]()
    
    @ViewBuilder
    func appButton(json: stuff)->some View {
        if isAppInstalled(appDetails.bundleIdentifier) {
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
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                HStack {
                    WebImage(url: URL(string: appDetails.iconURL))
                        .resizable()
                        .frame(width: 115, height: 115)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding(.trailing, 7)
                    
                    VStack(alignment: .leading) {
                        Text(appDetails.name)
                            .font(.title.bold())
                        Text(appDetails.developerName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(appDetails.version)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        appButton(json: appDetails)
                            .buttonStyle(AppStoreStyle())
                    }
                }
                .padding()
                
                Text(appDetails.localizedDescription)
                    .padding(.horizontal, 15)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(appDetails.screenshotURLs?.indices ?? 0..<0, id: \.self) { index in
                            if let screenshotURL = appDetails.screenshotURLs?[index] {
                                WebImage(url: URL(string: screenshotURL))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 275)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))

                            }
                        }
                    }
                    .padding(.horizontal, 10)
                                    }
                .padding(.top, 10)
            }
            .padding(.bottom, 20)
        }
        .onAppear { Task { await refresh() } }
        .navigationBarTitle("", displayMode: .inline)
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
    }
    func isAppInstalled(_ BundleID: String) -> Bool {
        installedAppsBundleIDs.contains(BundleID)
    }
}

private func InstallIPA(downloadURL: String) {
    if let url = URL(string: "apple-magnifier://install?url=" + downloadURL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct AppDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStuff = stuff(
            name: "Paperback",
            bundleIdentifier: "dev.faizandurrani.moe.paperback.app",
            version: "0.8.6",
            versionDate: "2023-08-05",
            size: 10727226,
            downloadURL: "https://github.com/swaggyP36000/TrollStore-IPAs/releases/download/08-05-2023/Paperback-0.8.6.ipa",
            developerName: "",
            localizedDescription: "",
            iconURL: "https://raw.githubusercontent.com/swaggyP36000/TrollStore-IPAs/main/icons/dev.faizandurrani.moe.paperback.app.png",
        featured: true,
            screenshotURLs: [
                "https://i.imgur.com/W2j590N.png",
                "https://i.imgur.com/W2j590N.png",
                "https://i.imgur.com/W2j590N.png"
            ]
        )
        
        // Use the sample instance in your AppDetailsView preview
        AppDetailsView(appDetails: sampleStuff)

    }
}
