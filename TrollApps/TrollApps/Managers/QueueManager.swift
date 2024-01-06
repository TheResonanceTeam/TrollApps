//
//  QueueManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-16.
//

import SwiftUI
import BottomSheet
import SwipeActions
import Kingfisher

enum ActionType: String, Decodable, Equatable, Hashable {
    case download
    case install
    case uninstall
    case finished
}

struct QueueItem: Equatable, Hashable {
    var id = UUID()
    
    var action: ActionType
    
    var icon: String
    var name: String
    
    var bundleIdentifier: String?
    var downloadURL: String?
    
    var progress : Double = 0
    
    var error :Bool = false
    var message : ErrorMessage = ErrorMessage(title: "", body: "")
    
    var queued = false
}


class QueueManager: ObservableObject {
    @Published var queue : [QueueItem] = []
    @Published var isProcessing : Bool = false
    @Published var hasFinished : Bool = false
    @Published var promptInstall : Bool = false

    @Published var canClose : Bool = true

    func addQueueItem(item: QueueItem) {
        queue.append(item)
    }
    
    func removeQueueItem(itemID: UUID) {
        if let index = queue.firstIndex(where: { $0.id == itemID }) {
            queue.remove(at: index)
        }
    }
    
    func removeQueueItem(bundleIdentifier: String) {
        if let index = queue.firstIndex(where: { $0.bundleIdentifier == bundleIdentifier }) {
            queue.remove(at: index)
        }
    }
    
    func hasQueueItem(bundleIdentifier: String) -> Bool {
        return queue.contains { $0.bundleIdentifier == bundleIdentifier }
    }
    
    func updateQueueItemProgress(itemID: UUID, progress: Double) {
        if let index = queue.firstIndex(where: { $0.id == itemID }) {
            queue[index].progress = progress
        }
    }
    
    func getQueueItem(bundleIdentifier: String) -> QueueItem? {
        if let index = queue.firstIndex(where: { $0.bundleIdentifier == bundleIdentifier }) {
            return queue[index]
        }
        
        return nil
    }
}

struct QueueManagerView<Content: View>: View {
    @EnvironmentObject var queueManager: QueueManager
    @EnvironmentObject var repoManager: RepositoryManager
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var alertManager: AlertManager

    @State private var bottomSheetPosition: BottomSheetPosition = .hidden
    @State private var showPadding = false
    @State private var isKeyboardVisible = false

    private var device : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var content: Content
    
    @State private var popupHeigth : BottomSheetPosition = .absoluteBottom(165)
    @State private var popdownHeight : BottomSheetPosition = .absoluteBottom(105)

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .padding(.bottom, showPadding && queueManager.queue.count > 0 && !isKeyboardVisible ? 20 : 0)
                .onAppear {
                    if device == .pad {
                        popupHeigth = .absoluteBottom(150)
                        popdownHeight = .absoluteBottom(90)
                    }
                    
                    bottomSheetPosition = queueManager.queue.count > 0 ? popdownHeight : .hidden
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                        self.isKeyboardVisible = true
                        bottomSheetPosition = .hidden
                    }

                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
                        self.isKeyboardVisible = false
                        bottomSheetPosition = queueManager.queue.count > 0 ? popdownHeight : .hidden
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self)
                }
                .onChange(of: queueManager.queue) { newQueue in
                    if (!isKeyboardVisible) {
                        if bottomSheetPosition != .relativeTop(0.975) {
                            bottomSheetPosition = queueManager.queue.count > 0 ? popupHeigth : .hidden
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if newQueue == queueManager.queue {
                                    if bottomSheetPosition == popupHeigth {
                                        bottomSheetPosition = popdownHeight
                                    }
                                }
                            }
                        } else if queueManager.queue.count == 0 {
                            bottomSheetPosition = .hidden
                        }
                    }
                }
                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                    queueManager.isProcessing ? .relativeTop(0.975) : popdownHeight,
                    .relativeTop(0.975)
                ], headerContent: {
                    VStack(alignment: .leading) {
                        Text("\(queueManager.queue.count) Apps Queued")
                            .font(.title.bold())
                            .padding(.top, queueManager.canClose ? 0 : 5)
                            .animation(nil, value: UUID())
                        if queueManager.isProcessing {
                            Text("During large app installations the app may appear frozen, kindly allow up to a minute for the installation process.")
                                .padding(.top, 5)
                                .animation(nil, value: UUID())
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                }) {
                    VStack {
                        ScrollView {
                            VStack {
                                Divider()
                                ForEach(queueManager.queue, id: \.self) { queueItem in
                                    SwipeView {
                                        HStack {
                                            if(queueItem.icon != "") {
                                                KFImage(URL(string: queueItem.icon)!)
                                                    .loadDiskFileSynchronously()
                                                    .cacheMemoryOnly()
                                                    .resizable()
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .frame(width: 43, height: 43)
                                                    .padding(.trailing, 7)
                                                    .id(UUID())
                                            } else {
                                                Image("MissingApp")
                                                    .resizable()
                                                    .frame(width: 43, height: 43)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .padding(.trailing, 7)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text(queueItem.name)
                                                
                                                if queueItem.error {
                                                    Text(queueItem.message.title)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                } else if queueManager.isProcessing {
                                                    if queueItem.queued {
                                                        Text("Queued \(queueItem.action.rawValue.capitalized)")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                    } else {
                                                        if queueItem.action != .finished {
                                                            ProgressView("\(queueItem.action.rawValue.capitalized)ing...", value: queueItem.progress, total: 100)
                                                                .font(.caption)
                                                                .foregroundColor(.gray)
                                                        } else {
                                                            Text("Finished")
                                                                .font(.caption)
                                                                .foregroundColor(.gray)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // Button to view downloaded ipa details
                                            
//                                            if queueManager.promptInstall {
//                                                if queueManager.queue.contains(where: { !$0.error }) {
//                                                    Spacer()
//                                                    Button(action: {
//                                                        alertManager.showIPADetails(id: queueItem.id)
//                                                    }) {
//                                                        Image(systemName: "info.circle")
//                                                            .font(.system(size: 20))
//                                                            .foregroundColor(Color.white)
//                                                    }
//                                                }
//                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.init(top: 5, leading: 15, bottom: 5, trailing: 15))
                                        .background(
                                            Color.white.opacity(0.001)
                                        )
                                    } trailingActions: { _ in
                                        if !queueManager.isProcessing || queueManager.promptInstall {
                                            SwipeAction(systemImage: "trash", backgroundColor: .pink, highlightOpacity: 1) {
                                                if queueManager.promptInstall {
                                                    let _ = DeleteIPA(queueItem.id)
                                                }
                                                
                                                withAnimation {
                                                    queueManager.removeQueueItem(itemID: queueItem.id)
                                                }
                                            }
                                            .allowSwipeToTrigger()
                                        }
                                    }
                                    .swipeMinimumDistance(20)
                                    
                                    Divider().opacity(0.3)
                                }
                            }
                            .padding(.top, 10)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        showPadding = true
                                    }
                                }
                            }
                        }
                        Spacer()
                        Divider()
                            .padding(.bottom, 5)
                        if queueManager.promptInstall {
                            if queueManager.queue.contains(where: { !$0.error }) {
                                Button("Install Apps") {
                                    queueManager.promptInstall = false
                                    processInstalls(index: 0)
                                }
                                .buttonStyle(LongButtonStyle(type: "blue", dissabled: false))
                            }
                            Button("Clear Queue") {
                                clearTmpFolder()
                                queueManager.promptInstall = false
                                queueManager.isProcessing = false
                                queueManager.hasFinished = false
                                queueManager.canClose = true
                                withAnimation {
                                    queueManager.queue.removeAll()
                                }
                            }
                            .buttonStyle(LongButtonStyle(type: "gray", dissabled: false))
                        } else if !queueManager.hasFinished {
                            Button("Confirm") {
                                bottomSheetPosition = .relativeTop(0.975)
                                queueManager.isProcessing = true
                                queueManager.canClose = false
                                
                                let dispatchGroup = DispatchGroup()
                                
                                for (index, _) in queueManager.queue.enumerated() {
                                    dispatchGroup.enter()
                                    
                                    if queueManager.queue[index].action == .download {
                                        downloadIPA(queueManager.queue[index], queueManager: queueManager) { status in
                                            DispatchQueue.main.async {
                                                if status.error {
                                                    if let statusMessage = status.message {
                                                        queueManager.queue[index].message = statusMessage
                                                        queueManager.queue[index].error = true
                                                    }
                                                } else {
                                                    queueManager.queue[index].queued = true
                                                    queueManager.queue[index].action = .install
                                                    queueManager.queue[index].progress = 0
                                                }
                                                dispatchGroup.leave()
                                            }
                                        }
                                    }
                                }
                                
                                dispatchGroup.notify(queue: .main) {
                                    if userSettings.skipInstallPrompt {
                                        processInstalls(index: 0)
                                    } else {
                                        queueManager.promptInstall = true
                                    }
                                }
                            }
                            .disabled(queueManager.isProcessing)
                            .buttonStyle(LongButtonStyle(type: "blue", dissabled: queueManager.isProcessing))
                            Button("Clear Queue") {
                                withAnimation {
                                    queueManager.queue.removeAll()
                                }
                            }
                            .buttonStyle(LongButtonStyle(type: "gray", dissabled: queueManager.isProcessing))
                            .disabled(queueManager.isProcessing)
                        } else {
                            Button("Close Queue") {
                                queueManager.queue.removeAll()
                                queueManager.hasFinished = false
                                queueManager.canClose = true
                                repoManager.InstalledApps = GetApps()
                            }
                            .buttonStyle(LongButtonStyle(type: "gray", dissabled: false))
                        }
                    }
                    .padding(.bottom, queueManager.canClose ? 95 : 40)
                }
                .enableFloatingIPadSheet(false)
                .dragIndicatorColor(Color.gray)
                .isResizable(queueManager.canClose)
                .sheetWidth(.relative(1))
        }
    }
    
    
    func processInstalls(index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            guard index < queueManager.queue.count else {
                
                // Do uninstalls here
                
                // temp:
                queueManager.hasFinished = true
                queueManager.isProcessing = false
                return
            }
            
            let currentItem = queueManager.queue[index]
            
            if currentItem.action == .install {
                
                queueManager.queue[index].queued = false

                InstallIPA(currentItem.id, queueManager: queueManager) { status in
                    DispatchQueue.main.async {
                        if status.error {
                            if let statusMessage = status.message {
                                queueManager.queue[index].message = statusMessage
                                queueManager.queue[index].error = true
                            }
                        } else {
                            queueManager.queue[index].action = .finished
                        }
                        
                        processInstalls(index: index + 1)
                    }
                }
            } else {
                processInstalls(index: index + 1)
            }
        })
    }
}

