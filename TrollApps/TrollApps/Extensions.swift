//
//  Extensions.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI
import CoreServices
import Foundation

func InstallIPA(_ IPAPath: String) {
    if let trollStoreApp = SBFApplication(applicationBundleIdentifier: "com.opa334.TrollStore") {
        let trollstoreHelperPath = trollStoreApp.bundleURL.path + "/trollstorehelper"
        spawnRoot(trollstoreHelperPath, ["install", IPAPath])
    } else {
        print("Error: TrollStore app not found.")
    }
    
    if FileManager.default.fileExists(atPath: IPAPath) {
        do {
            try FileManager.default.removeItem(atPath: IPAPath)
        } catch {
            print("Error removing .ipa file: \(error)")
        }
    }
}

struct CollapsibleText: View {
    var text: String
    @Binding var isExpanded: Bool
    let maxLines: Int

    var body: some View {
        Text(text)
            .lineLimit(isExpanded ? nil : maxLines)
    }
}

// TODO: Fix up this function for better handeling
func mergeApps(appList: [Application]) -> [Application] {
    var uniqueAppsSet = Set<String>()
    var uniqueApps = [Application]()

    for app in appList {
        if uniqueAppsSet.insert(app.bundleIdentifier).inserted {
            
            var builtApp = app
            
            if (app.downloadURL != nil) {
                let builtVersion = Version(
                    version: app.version ?? "0.0.0",
                    date: app.versionDate ?? "",
                    localizedDescription: app.localizedDescription,
                    downloadURL: app.downloadURL ?? "",
                    size: app.size
                )
                
                if builtApp.versions == nil {
                    builtApp.versions = [builtVersion]
                } else {
                    builtApp.versions?.append(builtVersion)
                }
            }

            uniqueApps.append(builtApp)
        } else {
            if let existingAppIndex = uniqueApps.firstIndex(where: { $0.bundleIdentifier == app.bundleIdentifier }) {                
                let builtVersion = Version(
                    version: app.version ?? "0.0.0",
                    date: app.versionDate ?? "",
                    localizedDescription: app.localizedDescription,
                    downloadURL: app.downloadURL ?? "",
                    size: app.size
                )
                
                if uniqueApps[existingAppIndex].versions == nil {
                    uniqueApps[existingAppIndex].versions = [builtVersion]
                } else {
                    uniqueApps[existingAppIndex].versions?.append(builtVersion)
                }
            }
        }
    }

    return uniqueApps
}

func DownloadIPA(_ IPA: String) -> Bool {
    guard let url = URL(string: IPA) else {
        print("Invalid URL")
        return false
    }

    let IPAPath = "/var/mobile/TrollApps-Tmp-IPA.ipa"
    if FileManager.default.fileExists(atPath: IPAPath) {
        do {
            try FileManager.default.removeItem(atPath: IPAPath)
        } catch {
            print("Error removing existing .ipa file: \(error)")
            return false
        }
    }

    do {
        try Data(contentsOf: url).write(to: URL(fileURLWithPath: IPAPath))
        return true
    } catch {
        print("Error downloading .ipa file: \(error)")
        return false
    }
}


public struct AppStoreStyle: ButtonStyle {
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

public struct AppStoreIconStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(Color.accentColor)
            .padding(.vertical, 12)
            .frame(width: 29, height: 29, alignment: .center)
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

func IsAppInstalled(_ BundleID: String) -> Bool {
    return GetApps().contains(BundleID)
}

func OpenApp(_ BundleID: String) {
    guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return }
    let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
    workspace?.perform(Selector(("openApplicationWithBundleID:")), with: BundleID)
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

var currentUIAlertController: UIAlertController?

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController?.dismiss(animated: animated)
        }
    }
    func alert(title: String = "Alert", body: String, animated: Bool = true, withButton: Bool = true) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if withButton { currentUIAlertController?.addAction(.init(title: "OK", style: .cancel)) }
            self.present(alert: currentUIAlertController!)
        }
    }
    func confirmAlert(title: String = "Alert", body: String, onOK: @escaping () -> (), noCancel: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if !noCancel {
                currentUIAlertController?.addAction(.init(title: "Cancel", style: .cancel))
            }
            currentUIAlertController?.addAction(.init(title: "OK", style: noCancel ? .cancel : .default, handler: { _ in
                onOK()
            }))
            self.present(alert: currentUIAlertController!)
        }
    }
    func change(title: String = "Alert", body: String) {
        DispatchQueue.main.async {
            currentUIAlertController?.title = title
            currentUIAlertController?.message = body
        }
    }
    
    func present(alert: UIAlertController) {
        if var topController = self.windows[0].rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
        }
    }
}
