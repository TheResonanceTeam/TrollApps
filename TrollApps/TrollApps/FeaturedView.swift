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
    @State private var isshowingdesc = false
    @State private var apps: [stuff] = []
    @State private var installedAppsBundleIDs = [String]()
    @State private var InstallingIPA = false
    @State private var DownloadingIPA = true
    @State private var InstallingIPAInfo: stuff? = nil
    @State private var downloadError: Bool = false
    @ViewBuilder
    func appButton(json: stuff)->some View {
        if isAppInstalled(json.bundleid) {
            Button("OPEN") {
                OpenApp(json.bundleid)
            }
        } else {
            Button("GET") {
                DispatchQueue.global(qos: .utility).async {
                    InstallingIPA = true
                    InstallingIPAInfo = json
                    DownloadingIPA = true
                    if DownloadIPA(json.url.replacingOccurrences(of: "apple-magnifier://install?url=", with: "")) {
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
                    }
                }
            }
        }
    }
    
    var body: some View {
        if InstallingIPA {
            HStack {
                Text("\(DownloadingIPA ? "Download" : "Install")ing \(InstallingIPAInfo!.title)")
                WebImage(url: URL(string: InstallingIPAInfo!.urlimg))
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        } else {
            if isshowingdesc {
                Section {
                    NavigationView {
                        let form = Form {
                            //  show error at top of screen
                            if downloadError {
                                Section {
                                    Text("App download failed. Please check your internet and try again later. (You may need to force-quit and relaunch TrollApps.)")
                                        .foregroundColor(.red)
                                }
                            }
                            ForEach(apps) { json in
                                Section {
                                    Label {
                                        HStack {
                                            Text(json.title)
                                            Spacer()
                                            appButton(json: json)
                                                .buttonStyle(appstorestyle())
                                        }
                                    } icon: {
                                        WebImage(url: URL(string: json.urlimg))
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                    }
                                    VStack {
                                        Text(json.description)
                                            .opacity(0.3)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Button("Copy \(json.title) .IPA Link") {
                                            UIPasteboard.general.string = json.url
                                        }
                                        .buttonStyle(somebuttonstyle())
                                    }
                                }
                            }
                            //  show error at bottom of screen
                            /*if downloadError {
                                Section {
                                    Text("App download failed. Please check your internet and try again later. (You may need to force-quit and relaunch TrollApps.)")
                                        .foregroundColor(.red)
                                }
                            }*/
                        }
                            .environment(\.defaultMinListRowHeight, 50)
                            .navigationTitle("Featured")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading){
                                    Button {
                                        isshowingdesc.toggle()
                                    } label: {
                                        Image(systemName: "info.circle")
                                    }
                                }
                            }
                        //                    from https://www.hackingwithswift.com/books/ios-swiftui/how-to-be-notified-when-your-swiftui-app-moves-to-the-background
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
                }
            } else {
                NavigationView {
                    let form = Form {
                        Section {
                            ForEach(apps) { json in
                                Label {
                                    HStack {
                                        Text(json.title)
                                        Spacer()
                                        appButton(json: json)
                                            .buttonStyle(appstorestyle())
                                    }
                                } icon: {
                                    WebImage(url: URL(string: json.urlimg))
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                }
                            }
                        }
                        if downloadError {
                            Section {
                                Text("App download failed. Please check your internet and try again later. (You may need to force-quit and relaunch TrollApps.)")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                        .environment(\.defaultMinListRowHeight, 50)
                        .navigationTitle("Featured")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading){
                                Button {
                                    isshowingdesc.toggle()
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                            }
                        }
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
            }
        }
    }
    
    @Sendable
    func refresh()async{
        let currentInstalledAppsBundleIDs = GetApps()
        DispatchQueue.main.async {
            withAnimation{
                self.installedAppsBundleIDs=currentInstalledAppsBundleIDs
            }
        }
        guard let updatedApps = await FetchApps() else {return}
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
