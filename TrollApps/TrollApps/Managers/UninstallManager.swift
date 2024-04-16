//
//  UninstallManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-20.
//

import Combine

func UninstallIPA(_ appID: String) -> FunctionStatus {
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
