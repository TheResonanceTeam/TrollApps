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
    @State private var isExpanded: Bool = false
    
    let maxLines: Int = 3

    let description: String = {
        let versionDesc = appDetails.versions?[selectedVersionIndex].localizedDescription ?? ""
        return versionDesc
    }()
    
    let truncatedDescription: String = {
        let versionDesc = appDetails.versions?[selectedVersionIndex].localizedDescription ?? ""
        return versionDesc.truncate(maxLines: maxLines)
    }()
    
    var shouldShowReadMoreButton: Bool {
        let fullHeight = getHeight(for: description)
        let truncatedHeight = getHeight(for: truncatedDescription)
        return fullHeight > truncatedHeight
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
                        Text(appDetails.developerName ?? "Unknown Developer")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(appDetails.versions?[selectedVersionIndex].absoluteVersion ?? appDetails.versions?[selectedVersionIndex].version ?? "Unknown Version")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        
                        DynamicInstallButton(appDetails: appDetails, selectedVersionIndex: selectedVersionIndex)
                                .buttonStyle(AppStoreStyleBlue())
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
                
                let versionDesc = appDetails.versions?[selectedVersionIndex].localizedDescription ?? ""

                if(!versionDesc.isEmpty) {
                    Section {
                        VStack(alignment: .leading, spacing: 5) {
                            CollapsibleText(
                                text: description,
                                isExpanded: $isExpanded,
                                maxLines: isExpanded ? nil : maxLines
                            )
            
                            if !isExpanded && shouldShowReadMoreButton {
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
        .navigationBarTitle("", displayMode: .inline)
        
        var backgroundFillColor: Color {
            return colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(.systemGray6)
        }

        func getHeight(for text: String) -> CGFloat {
            let font = Font.system(size: 14)
            let attributedText = NSAttributedString(
                string: text,
                attributes: [.font: font]
            )
            let constraintRect = CGSize(
                width: UIScreen.main.bounds.width - 30,  // Adjust the width as needed
                height: .greatestFiniteMagnitude
            )
            let boundingBox = attributedText.boundingRect(
                with: constraintRect,
                options: [.usesLineFragmentOrigin],
                context: nil
            )
            return boundingBox.height
        }
    }
}
