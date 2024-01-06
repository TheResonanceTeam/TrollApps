//
//  TrollAppsApp.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import SwiftUI

@main
struct TrollAppsApp: App {
    @StateObject private var repoManager = RepositoryManager()
    @StateObject private var alertManager = AlertManager()
    @StateObject private var queueManager = QueueManager()
    
    @StateObject private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ChangelogManagerView(
                content:
                    ZStack {
                        NavView()
                            .zIndex(2)
                        AlertManagerView()
                            .zIndex(3)
                    }
            )
            .environment(\.locale, .init(identifier: userSettings.lang))
            .environmentObject(repoManager)
            .environmentObject(alertManager)
            .environmentObject(queueManager)
            .environmentObject(userSettings)
            .onAppear {
                if !repoManager.hasFetchedRepos {
                    repoManager.fetchRepos()
                }
                clearTmpFolder()
            }
        }
    }
}

// Code for testing out getting downloaded ipa details
//import SwiftUI
//import ZIPFoundation
//import Security
//
//@main
//struct TrollAppsApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//struct ContentView: View {
//    @State private var downloadProgress: Double = 0.0
//
//    var body: some View {
//        VStack {
//            Text("Download and Extract Example")
//                .padding()
//
//            ProgressView("Download Progress", value: downloadProgress, total: 1.0)
//                .padding()
//
//            Button("Download and Extract") {
//                downloadAndExtractZIP()
//            }
//            .padding()
//        }
//    }
//
//    func downloadAndExtractZIP() {
//        guard let url = URL(string: "https://github.com/haxi0/Jaility/releases/download/3.1.1/Jaility-3.1.1.ipa") else {
//            print("Invalid URL")
//            return
//        }
//
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let destinationURL = documentsDirectory.appendingPathComponent("Jaility-3.1.1.ipa")
//
//        if FileManager.default.fileExists(atPath: destinationURL.path) {
//            do {
//                try FileManager.default.removeItem(at: destinationURL)
//                print("DELETED FILE")
//            } catch {
//                print("Error deleting existing file: \(error)")
//            }
//        }
//
//        let downloadTask = URLSession.shared.downloadTask(with: url) { (tempLocalURL, response, error) in
//            guard let tempLocalURL = tempLocalURL, error == nil else {
//                print("Download failed with error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            do {
//                try FileManager.default.moveItem(at: tempLocalURL, to: destinationURL)
//
//                if let archive = Archive(url: destinationURL, accessMode: .read) {
//                    
//
////                    archive.forEach { item in
////                        print(item.path)
////                    }
////                    
////                    if let entry = archive["Payload/Jaility.app/Info.plist"] {
////                        try archive.extract(entry, consumer: { (data) in
////                            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
////                            if let dictionary = plistData as? [String: Any] {
////                                // Process the dictionary
////                                for (key, value) in dictionary {
////                                    print("Key: \(key), Value: \(value)")
////                                    // Perform additional processing as needed
////                                }
////                            } else {
////                                print("Unsupported plist format.")
////                            }
////                        })
////                    } else {
////                        print("missing")
////                    }
//                    if let entry = archive["Payload/Jaility.app/Jaility"] {
//                        try archive.extract(entry, consumer: { (data) in
//                            
//                            func getStaticCodeRef(binaryPath: String) -> SecStaticCode? {
//                                guard !binaryPath.isEmpty else {
//                                    return nil
//                                }
//                                
//                                guard let binaryURL = CFURLCreateWithFileSystemPath(
//                                    kCFAllocatorDefault,
//                                    binaryPath as CFString,
//                                    CFURLPathStyle.cfurlposixPathStyle,
//                                    false
//                                ) else {
//                                    print("[getStaticCodeRef] failed to get URL to binary \(binaryPath)")
//                                    return nil
//                                }
//                                
//                                var codeRef: SecStaticCode?
//                                let result = SecStaticCodeCreateWithPathAndAttributes(
//                                    binaryURL,
//                                    SecCSFlags.defaultFlags,
//                                    nil,
//                                    &codeRef
//                                )
//                                
//                                CFRelease(binaryURL)
//                                
//                                if result != errSecSuccess {
//                                    print("[getStaticCodeRef] failed to create static code for binary \(binaryPath), error: \(result)")
//                                    return nil
//                                }
//                                
//                                return codeRef
//                            }
//                            
//                            let tmpPath = FileManager.default.temporaryDirectory
//                                .appendingPathComponent(UUID().uuidString)
//                            let tmpURL = URL(fileURLWithPath: tmpPath.absoluteString)
//                            
//                            do {
//                                try data.write(to: tmpURL, options: .atomic)
//                            }
//                            
//                            guard let codeRef = getStaticCodeRef(binaryPath: tmpPath.absoluteString) else {
//                                
//                            }
//                            
//                            guard codeRef != nil else {
//                                print("[dumpEntitlements] attempting to dump entitlements without a StaticCodeRef")
//                            }
//                            
//                            let kSecCodeInfoEntitlementsDict: CFStringRef = "entitlements" as CFString
//                            
//                            var signingInfo: CFDictionary?
//                            
//                            func copySigningInformation(code: SecStaticCode, flags: SecCSFlags) -> CFDictionary? {
//                                var signingInfo: CFDictionary?
//                                let result = SecCodeCopySigningInformation(code, flags, &signingInfo)
//                                
//                                if result != errSecSuccess {
//                                    print("[copySigningInformation] failed to copy signing information from static code, error: \(result)")
//                                    return nil
//                                }
//                                
//                                return signingInfo
//                            }
//                            
//                            
//                            let result = copySigningInformation(codeRef, .requirementInformation, &signingInfo)
//                            
//                            if let entitlements = CFDictionaryGetValue(signingInfo, Unmanaged.passUnretained(kSecCodeInfoEntitlementsDict).toOpaque()) {
//                            }
//                        })
//                    }
//                    
//
//                } else {
//                    print("Failed to open the archive")
//                }
//            } catch {
//                print("Error moving downloaded file: \(error)")
//            }
//        }
//
//        downloadTask.resume()
//    }
//}
