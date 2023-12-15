//
//  Apps.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

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
                    return FunctionStatus(error: true, message: ErrorMessage(title: "ERROR_REMOVING_IPA_FILE_AFTER_INSTALL", body: "LIKELY_A_PERMS_ISSUE"))
                }
            } else {
                return FunctionStatus(error: true, message: ErrorMessage(title: "MISSING_DOWNLOADED_IPA", body: ""))
            }
        }
    } else {
        return FunctionStatus(error: true, message: ErrorMessage(title: "TROLLSTORE_NOT_FOUND", body: "TROLLSTORE_IS_REQUIRED"))
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
        return FunctionStatus(error: true, message: ErrorMessage(title: "TROLLSTORE_NOT_FOUND", body: "TROLLSTORE_IS_REQUIRED"))
    }
}

func DownloadIPA(_ IPA: String) -> FunctionStatus {
    guard let url = URL(string: IPA) else {
        return FunctionStatus(error: true, message: ErrorMessage(title: "INVALID_DOWNLOAD_URL", body: "LIKELY_A_REPO_ISSUE"))
    }

    let IPAPath = "/var/mobile/TrollApps-Tmp-IPA.ipa"
    if FileManager.default.fileExists(atPath: IPAPath) {
        do {
            try FileManager.default.removeItem(atPath: IPAPath)
        } catch {
            return FunctionStatus(error: true, message: ErrorMessage(title: "ERROR_REMOVING_EXISTING_IPA_FILE", body: "LIKELY_A_PERMS_ISSUE"))
        }
    }

    do {
        try Data(contentsOf: url).write(to: URL(fileURLWithPath: IPAPath))
        return FunctionStatus(error: false)
    } catch {
        return FunctionStatus(error: true, message: ErrorMessage(title: "ERROR_DOWNLOADING_AND_WRITING_IPA_FILE", body: "LIKELY_A_PERMS_ISSUE"))
    }
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
