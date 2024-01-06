//
//  DownloadManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-17.
//

import SwiftUI

class DownloadDelegate: NSObject, ObservableObject, URLSessionDownloadDelegate {
    var queueItem: QueueItem
    var completion: (FunctionStatus) -> Void
    var queueManager: QueueManager

    init(queueItem: QueueItem, queueManager: QueueManager, completion: @escaping (FunctionStatus) -> Void) {
        self.queueItem = queueItem
        self.completion = completion
        self.queueManager = queueManager
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            
            let destinationFolderURL = URL(fileURLWithPath: "/var/mobile/.TrollApps/tmp/")
            let IPAPathURL = destinationFolderURL
                .appendingPathComponent(queueItem.id.uuidString)
                .appendingPathExtension(".ipa")
            
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)

            try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: IPAPathURL.path))
                        
            DispatchQueue.main.async {
                self.queueManager.updateQueueItemProgress(itemID: self.queueItem.id, progress: 100)
            }
            completion(FunctionStatus(error: false))
        } catch {
            print(error)
            completion(FunctionStatus(error: true, message: ErrorMessage(title: "ERROR_MOVING_IPA_FILE", body: error.localizedDescription)))
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentComplete = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.queueManager.updateQueueItemProgress(itemID: self.queueItem.id, progress: percentComplete * 100)
        }
    }
}

func downloadIPA(_ queueItem: QueueItem, queueManager: QueueManager, completion: @escaping (FunctionStatus) -> Void) {

    let downloadDelegate = DownloadDelegate(queueItem: queueItem, queueManager: queueManager, completion: completion)

    guard let url = URL(string: queueItem.downloadURL ?? "") else {
        completion(FunctionStatus(error: true, message: ErrorMessage(title: "INVALID_DOWNLOAD_URL", body: "LIKELY_A_REPO_ISSUE")))
        return
    }

    let downloadTask = URLSession(configuration: .default, delegate: downloadDelegate, delegateQueue: nil).downloadTask(with: url)
    downloadTask.resume()
}
