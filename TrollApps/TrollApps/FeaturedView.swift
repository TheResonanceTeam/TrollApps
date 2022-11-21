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
    @ViewBuilder
    func appButton(json: stuff)->some View {
        if isAppInstalled(json.bundleid) {
            Button("OPEN") {
                OpenApp(json.bundleid)
            }
        } else {
            Button("GET") {
                openURL(URL(string: json.url)!)
            }
        }
    }
    var body: some View {
        if isshowingdesc {
            Section {
                NavigationView {
                    let form = Form {
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
