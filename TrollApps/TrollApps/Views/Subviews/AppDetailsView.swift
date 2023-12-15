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
    
    @State private var selectedVersionIndex: Int = 0
    @State private var expandDescription: Bool = false
    @State private var expandVersionDescription: Bool = false
    @State private var expandVersion: Bool = false

    let maxLines: Int = 3
    
    var body: some View {
                
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                
                let version = appDetails.versions?[selectedVersionIndex].version ?? "UNKNOWN_VERSION"
                
                HStack {
                    if(appDetails.iconURL != "") {
                        WebImage(url: URL(string: appDetails.iconURL))
                            .resizable()
                            .frame(width: 115, height: 115)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .padding(.trailing, 7)
                        
                    } else {
                        Image("MissingApp")
                            .resizable()
                            .frame(width: 115, height: 115)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .padding(.trailing, 7)
                    }

                    VStack(alignment: .leading) {
                        Text(appDetails.name)
                            .font(.title2.bold())
                        
                        Text(appDetails.developerName ?? "UNKNOWN_DEVELOPER")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        CollapsibleText(
                            text: version,
                            isExpanded: $expandVersion,
                            maxLines: 1
                        )
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
//                        Spacer()
                                                
                        HStack {
                            DynamicInstallButton(appDetails: appDetails, selectedVersionIndex: selectedVersionIndex, buttonStyle: "Details")
                            
                            if let versions = appDetails.versions, versions.count == 1 {
                                
                            } else if let versions = appDetails.versions {
                                Picker("SELECT_VERSION", selection: $selectedVersionIndex) {
                                    ForEach(0..<versions.count, id: \.self) { index in
                                        Text(versions[index].absoluteVersion ?? versions[index].version)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                    }
                }
                .padding()
                
                let subtitle = appDetails.subtitle ?? ""

                if(!subtitle.isEmpty) {
                    Section {
                        Text(subtitle)
                            .font(.subheadline)
                            .padding(15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(backgroundFillColor)
                            )
                    }
                    .padding(.horizontal, 15)
                }
                
                let versionDesc = appDetails.versions?[selectedVersionIndex].localizedDescription ?? ""

                if(!versionDesc.isEmpty) {
                    Section {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("WHATS_NEW")
                                .font(.title2.bold())
                            
                            Text("VERSION \(version)")
                                .font(.subheadline)
                                .padding(.bottom, 1.5)
                            CollapsibleText(
                                text: versionDesc,
                                isExpanded: $expandVersionDescription,
                                maxLines: maxLines
                            ).onTapGesture {
                                withAnimation {
                                    expandVersionDescription.toggle()
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
                                    .frame(width: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 10)
                
                let description = appDetails.localizedDescription ?? ""
                
                if(!description.isEmpty) {
                    Section {
                        VStack(alignment: .leading, spacing: 5) {
                            CollapsibleText(
                                text: description,
                                isExpanded: $expandDescription,
                                maxLines: maxLines
                            ).onTapGesture {
                                withAnimation {
                                    expandDescription.toggle()
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
            }
            .padding(.bottom, 20)
        }
        .navigationBarTitle("", displayMode: .inline)
        
        var backgroundFillColor: Color {
            if let customTintColor = appDetails.tintColor, !customTintColor.isEmpty {
                if let color = Color(hex: customTintColor) {
                    return color.opacity(0.5)
                } else {
                    return colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(.systemGray6)
                }
            } else {
                return colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(.systemGray6)
            }
        }

    }
}
