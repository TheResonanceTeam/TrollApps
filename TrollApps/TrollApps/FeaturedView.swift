//
//  FeaturedView.swift
//  TrollApps
//
//  Created by Анохин Юрий on 21.11.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FeaturedView: View {
    
    var body: some View {
        Text("Feature view will be back in the next update <3")
    }
    
//    @Environment(\.scenePhase) var scenePhase
//    @State private var apps: [stuff] = []
//    @State private var installedAppsBundleIDs = [String]()
//    @State private var showAlert: Bool = false
//    @State private var alertToPresent: Alert?
//    
//    @State private var selectedVersionIndex: Int = 0
//    
//    var body: some View {
//        NavigationView {
//            let form = Form {
//                Section {
//                    ForEach(apps) { json in
//                        NavigationLink(destination: AppDetailsView(appDetails: json)) {
//                            Label {
//                                HStack {
//                                    Text(json.name)
//                                    Spacer()
//                                    DynamicInstallButton(appDetails: json, installedAppsBundleIDs: GetApps(), selectedVersionIndex: selectedVersionIndex)
//                                }
//                            } icon: {
//                                WebImage(url: URL(string: json.iconURL))
//                                    .resizable()
//                                    .frame(width: 30, height: 30)
//                                    .clipShape(RoundedRectangle(cornerRadius: 7))
//                            }
//                        }
//                    }
//                }
//            }
//                .environment(\.defaultMinListRowHeight, 50)
//                .navigationTitle("Featured")
//            //  from https://www.hackingwithswift.com/books/ios-swiftui/how-to-be-notified-when-your-swiftui-app-moves-to-the-background
//                .onChange(of: scenePhase) { newPhase in
//                    if newPhase == .active {
//                        print("Active, will refresh")
//                        Task(operation: refresh)
//                    }
//                }
//            if #available(iOS 15.0, *) {
//                form
//                    .refreshable {
//                        Task{await refresh()}
//                    }
//            } else {
//                form
//                    .toolbar{
//                        ToolbarItem(placement: .navigationBarTrailing){
//                            AsyncButton(action: refresh){
//                                Image(systemName: "arrow.clockwise")
//                            }
//                        }
//                    }
//            }
//        }
//        .alert(isPresented: $showAlert) {
//            alertToPresent ?? Alert(title: Text("Default Title"), message: Text("Default Message"))
//        }
//    }
//        
//    @Sendable
//    func refresh() async {
//        let currentInstalledAppsBundleIDs = GetApps()
//        DispatchQueue.main.async {
//            withAnimation {
//                self.installedAppsBundleIDs = currentInstalledAppsBundleIDs
//            }
//        }
//        
//        guard let updatedApps = await FetchFeaturedApps() else { return }
//        DispatchQueue.main.async {
//            withAnimation {
//                self.apps = updatedApps
//            }
//        }
//    }
}

struct FeaturedView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedView()
    }
}
