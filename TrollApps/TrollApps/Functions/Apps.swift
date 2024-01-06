//
//  Apps.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import Combine

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

func clearTmpFolder() {
    let TempFolderURL = URL(fileURLWithPath: "/var/mobile/.TrollApps/tmp/")
    let TempPathURL = TempFolderURL
    
    do {
        if FileManager.default.fileExists(atPath: TempPathURL.path) {
            try FileManager.default.removeItem(at: TempPathURL)
            print("Successfully deleted /tmp/ folder.")
        } else {
            print("/tmp/ folder does not exist.")
        }
    } catch {
        print("Error deleting /tmp/ folder: \(error.localizedDescription)")
    }
}
