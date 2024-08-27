//
//  ChangelogManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-23.
//

import SwiftUI
import BottomSheet

struct ListItem: Hashable {
    var icon : String
    var text : String
    var subtext : String
    var color : Color
}

struct ChangelogManagerView<Content: View>: View {
    @State private var bottomSheetPosition: BottomSheetPosition = .hidden
    @State private var page: Int32 = 0
    @Environment(\.openURL) var openURL

    var whatsNewItems: [ListItem] = [
        ListItem(
            icon: "note.text",
            text: "Minor Improvements",
            subtext: "Finally fixed the \"Unistall\" typo when removing apps on the Apps tab.",
            color: Color.blue
        ),
        ListItem(
            icon: "checkmark.seal.fill",
            text: "Out of Beta",
            subtext: "Version 2.3 is finally officially released, with some bugfixes and performance improvements.",
            color: Color.red
        ),
        ListItem(
            icon: "exclamationmark.bubble.fill",
            text: "Feedback needed!",
            subtext: "If you haven't already, please join our Discord server to give us valuable feedback for future update!.",
            color: Color.purple
        ),
    ]

    
    var discordItems : [ListItem] = [
        ListItem(
            icon: "sparkles",
            text: "TrollApps Betas",
            subtext: "Get the latest TrollApps betas!",
            color: Color.pink
        ),
        ListItem(
            icon: "note.text",
            text: "Feature Requests",
            subtext: "Suggest new additions / changes to the app!",
            color: Color.blue
        ),
        ListItem(
            icon: "questionmark.circle",
            text: "TrollApps Support",
            subtext: "Report bugs you find in the app!",
            color: Color.red
        ),
        ListItem(
            icon: "bell.badge",
            text: "New Version Notifications",
            subtext: "Get (optional) new version alerts!",
            color: Color.green
        ),
        ListItem(
            icon: "plus",
            text: "And More",
            subtext: "All this and more in our discord <3",
            color: Color.orange
        ),
    ]

    var content: Content
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .onAppear {
                    showChangelog()
                }
                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                    .relativeTop(0.975)
                ]) {
                    if page == 0 {
                        VStack {
                            Text("Whats New In Version " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))
                                .font(.title.bold())
                                .padding(.top, 40)
                                .padding(.bottom, 25)
                            ScrollView {
                                ForEach(whatsNewItems, id: \.self) { item in
                                    VStack {
                                        HStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(item.color)
                                                    .frame(width: 50, height: 50)
                                                
                                                Image(systemName: item.icon)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 20)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text(item.text)
                                                Text(item.subtext)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.leading, 5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.init(top: 10, leading: 35, bottom: 10, trailing: 35))
                                    }
                                }
                            }
                            Spacer()
                            Divider()
                            Button("View Full Changelog") {
                                openURL(URL(string: "https://github.com/TheResonanceTeam/TrollApps/releases/latest")!)
                            }
                            .buttonStyle(LongButtonStyle(type: "pink", dissabled: false))
                            Button("Next") {
                                withAnimation(Animation.easeInOut(duration: 0.25)) {
                                    page = 1
                                }
                            }
                            .buttonStyle(LongButtonStyle(type: "blue", dissabled: false))
                            .padding(.bottom, 50)
                        }
                        .opacity(page == 0 ? 1 : 0)
                    } else if page == 1 {
                        VStack {
                            Text("Join Our Discord")
                                .font(.title.bold())
                                .padding(.top, 40)
                                .padding(.bottom, 25)
                            ScrollView {
                                ForEach(discordItems, id: \.self) { item in
                                    VStack {
                                        HStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(item.color)
                                                    .frame(width: 50, height: 50)
                                                
                                                Image(systemName: item.icon)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 20)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text(item.text)
                                                Text(item.subtext)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.leading, 5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.init(top: 10, leading: 35, bottom: 10, trailing: 35))
                                    }
                                }
                            }
                            Spacer()
                            Divider()
                            Button("Back") {
                                withAnimation {
                                    page = 0
                                }
                            }
                            .buttonStyle(LongButtonStyle(type: "grey", dissabled: false))
                            Button("Join Discord") {
                                openURL(URL(string: "https://discord.gg/PrF6XqpGgX")!)
                            }
                            .buttonStyle(LongButtonStyle(type: "pink", dissabled: false))
                            Button("Dismiss") {
                                withAnimation(Animation.easeInOut(duration: 0.25)) {
                                    bottomSheetPosition = .hidden
                                }
                                UserDefaults.standard.set(version, forKey: "appVersion")
                            }
                            .buttonStyle(LongButtonStyle(type: "blue", dissabled: false))
                            .padding(.bottom, 50)
                        }
                        .opacity(page == 1 ? 1 : 0)
                    }
                }
                .enableFloatingIPadSheet(false)
                .sheetWidth(.relative(1))
                .showDragIndicator(false)
        }
    }

    func showChangelog() {
        let storedVersion = UserDefaults.standard.string(forKey: "appVersion") ?? ""

        if storedVersion != version {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    bottomSheetPosition = .relativeTop(0.975)
                }
            }
        }
    }
}
