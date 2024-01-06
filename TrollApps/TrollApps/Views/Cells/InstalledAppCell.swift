//
//  InstalledAppCell.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-16.
//

import SwiftUI

struct InstalledAppCell: View {
    let app : BundledApp
    let refreshApps: () -> Void

    @EnvironmentObject var alertManager: AlertManager

    var body: some View {
        HStack(alignment: .top) {
            Image(uiImage: app.icon)
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(app.name)
                Text(app.id)
                    .font(.caption)
                    .foregroundColor(.gray)
                CollapsibleText(text: app.version , isExpanded: .constant(false), maxLines: 1)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
                                    
            let isMainBundle : Bool = app.id == Bundle.main.bundleIdentifier
            Button("OPEN") {
                if app.id != Bundle.main.bundleIdentifier {
                    OpenApp(app.id)
                }
            }
            .buttonStyle(AppStoreStyle(type: "gray", dissabled: isMainBundle))
            .disabled(isMainBundle)
            
        }
        .frame(maxWidth: .infinity)
        .contextMenu
        {
            if(app.id != "com.opa334.TrollStore" && app.id != Bundle.main.bundleIdentifier) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        let uninstallIPAStatus = UninstallIPA(app.id)
                        
                        if(!uninstallIPAStatus.error) {
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey("UNINSTALLED_APP \(app.name)")),
                                body: Text(LocalizedStringKey(""))
                            )
                            
                            refreshApps()
                        } else {
                            alertManager.showAlert(
                                title: Text(LocalizedStringKey(uninstallIPAStatus.message?.title ?? "")),
                                body: Text(LocalizedStringKey(uninstallIPAStatus.message?.body ?? ""))
                            )
                        }
                    })
                }, label:
                {
                    Text("UNINSTALL_APP")
                })
            } else {
                Button("UNINSTALL_APP") {} .disabled(true)
            }
        }
    }
}
