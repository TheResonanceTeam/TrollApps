//
//  Extensions.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI
import CoreServices
import Foundation
import Combine

func InstallIPA(_ IPAPath: String) -> FunctionStatus {
    if let trollStoreApp = SBFApplication(applicationBundleIdentifier: "com.opa334.TrollStore") {
        let trollstoreHelperPath = trollStoreApp.bundleURL.path + "/trollstorehelper"
        let returnCode = spawnRoot(trollstoreHelperPath, ["install", IPAPath])
        
        if(returnCode != 0) {
            return FunctionStatus(error: true, message: ErrorMessage(title: "FAILED_TO_INSTALL", body: "INSTALLATION_RETURNED_ERROR \(returnCode)"))
        } else {
            
            NotificationCenter.default.post(name: Notification.Name("ApplicationsChanged"), object: nil)
            PassthroughSubject<Void, Never>().send()
            
            if FileManager.default.fileExists(atPath: IPAPath) {
                do {
                    try FileManager.default.removeItem(atPath: IPAPath)
                    return FunctionStatus(error: false)
                } catch {
                    print("Error removing .ipa file: \(error)")
                    return FunctionStatus(error: true, message: ErrorMessage(title: "ERROR_REMOVING_IPA_FILE_AFTER_INSTALL", body: "LIKELY_A_PERMS_ISSUE"))
                }
            } else {
                return FunctionStatus(error: true, message: ErrorMessage(title: "MISSING_DOWNLOADED_IPA", body: ""))
            }
        }
    } else {
        print("Error: TrollStore app not found.")
        return FunctionStatus(error: true, message: ErrorMessage(title: "TROLLSTORE_NOT_FOUND", body: ""))
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

func UnistallIPA(_ appID: String) -> FunctionStatus {
    if let trollStoreApp = SBFApplication(applicationBundleIdentifier: "com.opa334.TrollStore") {
        let trollstoreHelperPath = trollStoreApp.bundleURL.path + "/trollstorehelper"
        let returnCode = spawnRoot(trollstoreHelperPath, ["uninstall", appID])
        
        if(returnCode != 0) {
            return FunctionStatus(error: true, message: ErrorMessage(title: "FAILED_TO_UNINSTALL", body: "UNINSTALLATION_RETURNED_ERROR \(returnCode)"))
        } else {
            
            NotificationCenter.default.post(name: Notification.Name("ApplicationsChanged"), object: nil)
            PassthroughSubject<Void, Never>().send()
            
            return FunctionStatus(error: false)
        }
    } else {
        print("Error: TrollStore app not found.")
        return FunctionStatus(error: true, message: ErrorMessage(title: "TROLLSTORE_NOT_FOUND", body: ""))
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

extension String {
    func truncate(maxLines: Int) -> String {
        var lines = self.components(separatedBy: "\n")
        guard lines.count > maxLines else {
            return self
        }
        lines = Array(lines.prefix(maxLines))
        return lines.joined(separator: "\n")
    }
}

extension UIScrollView {
    
    private struct Keys {
        static var onValueChanged: UInt8 = 0
    }
    
    typealias ValueChangedAction = ((_ refreshControl: UIRefreshControl) -> Void)
    
    private var onValueChanged: ValueChangedAction? {
        get {
            objc_getAssociatedObject(self, &Keys.onValueChanged) as? ValueChangedAction
        }
        set {
            objc_setAssociatedObject(self, &Keys.onValueChanged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func onRefresh(_ onValueChanged: @escaping ValueChangedAction) {
        if refreshControl == nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(
                   self,
                   action: #selector(self.onValueChangedAction),
                   for: .valueChanged
               )
            self.refreshControl = refreshControl
        }
        self.onValueChanged = onValueChanged
    }
    
    @objc private func onValueChangedAction(sender: UIRefreshControl) {
        self.onValueChanged?(sender)
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

func DownloadIPA(_ IPA: String) -> FunctionStatus {
    guard let url = URL(string: IPA) else {
        print("Invalid URL")
        return FunctionStatus(error: true, message: ErrorMessage(title: "INVALID_DOWNLOAD_URL", body: "LIKELY_A_REPO_ISSUE"))
    }

    let IPAPath = "/var/mobile/TrollApps-Tmp-IPA.ipa"
    if FileManager.default.fileExists(atPath: IPAPath) {
        do {
            try FileManager.default.removeItem(atPath: IPAPath)
        } catch {
            print("Error removing existing .ipa file: \(error)")
            return FunctionStatus(error: true, message: ErrorMessage(title: "ERROR_REMOVING_EXISTING_IPA_FILE", body: "LIKELY_A_PERMS_ISSUE"))
        }
    }

    do {
        try Data(contentsOf: url).write(to: URL(fileURLWithPath: IPAPath))
        return FunctionStatus(error: false)
    } catch {
        print("Error downloading .ipa file: \(error)")
        return FunctionStatus(error: true, message: ErrorMessage(title: "ERROR_DOWNLOADING_AND_WRITING_IPA_FILE", body: "LIKELY_A_PERMS_ISSUE"))
    }
}

public struct AppStoreStyle: ButtonStyle {
    let type: String
    let dissabled: Bool

    public init(type: String, dissabled: Bool, extraWidth: CGFloat = 0) {
        self.type = type
        self.dissabled = dissabled
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(type == "blue" ? Color.white : Color.accentColor)
            .padding(.vertical, 5)
            .padding(.horizontal, 18)
            .frame(height: 30, alignment: .center)
            .frame(minWidth: 80)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .fill(type == "blue" ? Color.blue : Color.gray)
                    .opacity(dissabled ? 0.4 : type == "blue" ? 1 : 0.2)
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

struct BundledApp: Identifiable, Hashable {
    let id: String
    var name: String
    var version: String
    var isTrollStore: Bool
    var icon: UIImage
}

private func applicationIconImage() -> Int32 {
    return UIDevice.current.userInterfaceIdiom == .pad ? 8 : 10
}

func GetApps() -> [BundledApp] {
    var apps: [BundledApp] = []
    
    for app in LSApplicationWorkspace().allInstalledApplications() as! [LSApplicationProxy] {
        let appDict = NSDictionary(contentsOfFile: "\(app.bundleURL.path)/Info.plist")
        
        let parentDirectory = app.bundleURL.deletingLastPathComponent()
        let filePath = parentDirectory.appendingPathComponent("_TrollStore")
        let fileExists = FileManager.default.fileExists(atPath: filePath.path)
        
        let bundleID = (appDict?.value(forKey: "CFBundleIdentifier") ?? "Unknown") as! String
        
        
        let icon = UIImage._applicationIconImage(forBundleIdentifier: bundleID, format: applicationIconImage(), scale: UIScreen.main.scale) as! UIImage
        
        
        let bundledApp = BundledApp(
            id: bundleID,
            name: (
                appDict?.value(forKey: "CFBundleDisplayName") ?? 
                appDict?.value(forKey: "CFBundleName") ??
                appDict?.value(forKey: "CFBundleExecutable") ??
                "Unknown"
            ) as! String,
            version: (
                appDict?.value(forKey: "CFBundleShortVersionString") ??
                "Unknown"
            ) as! String,
            isTrollStore: fileExists,
            icon: icon
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
