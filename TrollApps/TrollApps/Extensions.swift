//
//  Extensions.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI
import CoreServices
import Foundation

public struct appstorestyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(Color.accentColor)
            .padding(.vertical, 12)
            .frame(width: 70, height: 29, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .fill(Color.gray)
                    .opacity(0.2)
            )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}

public struct somebuttonstyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.medium))
            .foregroundColor(Color.accentColor)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                    .fill(Color.gray)
                    .opacity(0.2)
                )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}

func GetApps() -> [String] {
    var apps: [String] = []
    for app in LSApplicationWorkspace().allInstalledApplications() as! [LSApplicationProxy] {
        apps.append((NSDictionary(contentsOfFile: "\(app.bundleURL.path)/Info.plist")?.value(forKey: "CFBundleIdentifier") ?? "Unknown") as! String)
    }
    return apps
}

func OpenApp(_ BundleID: String) {
    guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return }
    let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
    workspace?.perform(Selector(("openApplicationWithBundleID:")), with: BundleID)
}

