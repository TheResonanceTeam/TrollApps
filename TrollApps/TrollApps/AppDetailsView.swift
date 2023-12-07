//
//  AppDetailsView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-11-30.
//

import SwiftUI
import SDWebImageSwiftUI

struct AppDetailsView: View {
    @Environment(\.colorScheme) var colorScheme

    var appDetails: Application

    @State private var installedAppsBundleIDs = [String]()
    
    @State private var selectedVersionIndex: Int = 0
    @State private var isExpanded: Bool = false
    
    let maxLines: Int = 3
    
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
                        Text(appDetails.versions?[selectedVersionIndex].absoluteVersion ?? appDetails.versions?[selectedVersionIndex].version ?? "Unknown Version")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        
                        HStack {
                            DynamicInstallButton(appDetails: appDetails, installedAppsBundleIDs: GetApps(), selectedVersionIndex: selectedVersionIndex)
                            
                            Button(action: {
                                guard let window = UIApplication.shared.windows.first else { return }
                                while true {
                                    window.snapshotView(afterScreenUpdates: false)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                }
                            }
                            .buttonStyle(AppStoreIconStyle())
                        }

                        
                    }
                }
                .padding()
                                
                if let versions = appDetails.versions, versions.count == 1 {
                    
                } else if let versions = appDetails.versions {
                    Picker("Select Version", selection: $selectedVersionIndex) {
                        ForEach(0..<versions.count, id: \.self) { index in
                            Text(versions[index].absoluteVersion ?? versions[index].version)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal, 15)
                }
                
                let versionDesc = appDetails.versions?[selectedVersionIndex].localizedDescription

                if(versionDesc != nil && versionDesc != "") {
                    Section {
                        VStack(alignment: .leading, spacing: 5) {
                            CollapsibleText(
                                text: appDetails.versions?[selectedVersionIndex].localizedDescription ?? "",
                                isExpanded: $isExpanded,
                                maxLines: maxLines
                            )
                            
                            if !isExpanded {
                                Button("Read More") {
                                    withAnimation {
                                        isExpanded.toggle()
                                    }
                                }
                            } else if isExpanded {
                                Button("Read Less") {
                                    withAnimation {
                                        isExpanded.toggle()
                                    }
                                }
                            }
                        }
                        .padding(15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(backgroundFillColor)
                        )
                    }
                    .padding(.horizontal, 15)
                }

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
        
        var backgroundFillColor: Color {
            return colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(.systemGray6)
        }
    }

    
    @Sendable
    func refresh() async {
        let currentInstalledAppsBundleIDs = GetApps()
        DispatchQueue.main.async {
            withAnimation {
                self.installedAppsBundleIDs = currentInstalledAppsBundleIDs
            }
        }
    }
}
