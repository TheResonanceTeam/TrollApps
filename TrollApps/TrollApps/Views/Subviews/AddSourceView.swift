//
//  AddSourceView.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-16.
//

import SwiftUI

struct AddSourceView: View {
    @EnvironmentObject var repoManager: RepositoryManager
    @State var RepoURL = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var userSettings: UserSettings

    var onDismiss: () -> Void

    var body: some View {
        VStack {
            Form {
                Section(header: Text("ADD_REPOS"), footer: Text("ADD_REPOS_TOOLTIP")) {
                    TextField("REPO_URL", text: $RepoURL)
                        .keyboardType(userSettings.addRepoKeyboardType)
                    Button("ADD_REPOS") {
                        if (repoManager.RepoList.contains(RepoURL)) {
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("DUPLICATE_REPO")),
                                body: Text(LocalizedStringKey("ALREADY_ON_REPO_LIST"))
                            )
                        } else {
                            repoManager.addRepo(RepoURL, alertManager: alertManager) {
                                RepoURL = ""
                                presentationMode.wrappedValue.dismiss()
                                onDismiss()
                            }
                        }

                    }.disabled(self.RepoURL.isEmpty)
                    Button("ADD_REPO_FROM_CLIPBOARD") {
                        let pasteboard = UIPasteboard.general
                        if let RepoURL = pasteboard.string{
                            if (repoManager.RepoList.contains(RepoURL)) {
                                alertManager.showAlert(
                                    title: Text(LocalizedStringKey("DUPLICATE_REPO")),
                                    body: Text(LocalizedStringKey("ALREADY_ON_REPO_LIST"))
                                )
                            } else {
                                repoManager.addRepo(RepoURL, alertManager: alertManager) {
                                    presentationMode.wrappedValue.dismiss()
                                    onDismiss()
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationTitle("ADD_REPO")
    }
}
