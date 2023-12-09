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
        UIApplication.shared.alert(title: "Error: TrollStore app not found.", body: "", animated: false, withButton: true)
    }
    
    if FileManager.default.fileExists(atPath: IPAPath) {
        do {
            try FileManager.default.removeItem(atPath: IPAPath)
        } catch {
            UIApplication.shared.alert(title: "Error removing .ipa file:", body: "\(error)", animated: false, withButton: true)
            print("Error removing .ipa file: \(error)")
        }
    }
}

extension URL {
    // Helper method to parse query parameters from URL
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        var parameters = [String: String]()
        for queryItem in queryItems {
            parameters[queryItem.name] = queryItem.value
        }
        return parameters
    }
}

struct CollapsibleText: View {
    var text: String
    @Binding var isExpanded: Bool
    let maxLines: Int

    var body: some View {
        Text(text)
            .lineLimit(isExpanded ? nil : maxLines)
            .multilineTextAlignment(.leading)
    }
}

func reposEncode(reposUrl: [String]) -> String {
    let repoUrlString = reposUrl.map { ($0) }.joined(separator: ",")
    
    print(repoUrlString)

    if let data = repoUrlString.data(using: .utf8) {
        return "repo[" + data.base64EncodedString() + "]"
    }
    
    return ""
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
            .frame(width: 85, height: 29, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .fill(Color.gray)
                    .opacity(0.2)
            )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}

public struct AppStoreStyleBlue: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(Color.white)
            .padding(.vertical, 12)
            .frame(width: 85, height: 29, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .fill(Color.blue)
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

func compareVersions(_ version1: String, _ version2: String) -> Bool {
    let components1 = version1.components(separatedBy: CharacterSet(charactersIn: "."))
    let components2 = version2.components(separatedBy: CharacterSet(charactersIn: "."))
    
    for (component1, component2) in zip(components1, components2) {
        if let number1 = Int(component1), let number2 = Int(component2) {
            if number1 != number2 {
                return number1 > number2
            }
        } else {
            if component1 < component2 {
                return false
            } else if component1 > component2 {
                return true
            }
        }
    }
    
    return components1.count >= components2.count
}

struct BundledApp: Identifiable {
    let id: String
    var name: String
    var version: String
    var isTrollStore: Bool
}

func GetApps() -> [BundledApp] {
    var apps: [BundledApp] = []
    
    for app in LSApplicationWorkspace().allInstalledApplications() as! [LSApplicationProxy] {
        let appDict = NSDictionary(contentsOfFile: "\(app.bundleURL.path)/Info.plist")
        
        let parentDirectory = app.bundleURL.deletingLastPathComponent()
        let filePath = parentDirectory.appendingPathComponent("_TrollStore")
        let fileExists = FileManager.default.fileExists(atPath: filePath.path)

        let bundledApp = BundledApp(
            id: (appDict?.value(forKey: "CFBundleIdentifier") ?? "Unknown") as! String,
            name: (appDict?.value(forKey: "CFBundleDisplayName") ?? appDict?.value(forKey: "CFBundleName") ?? "Unknown") as! String,
            version: (appDict?.value(forKey: "CFBundleShortVersionString") ?? "Unknown") as! String,
            isTrollStore: fileExists
        )
        
        apps.append(bundledApp)
    }
    
    return apps
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
