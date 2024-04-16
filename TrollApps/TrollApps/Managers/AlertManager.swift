//
//  AlertManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-12.
//

import SwiftUI
import Combine

struct ErrorMessage: Hashable {
    var title: String
    var body: String
}

struct FunctionStatus: Hashable {
    var error : Bool
    var message : ErrorMessage?
}

class AlertManager: ObservableObject {
    @Published var isAlertPresented = false
    @Published var alertTitle = Text("")
    @Published var alertBody = Text("")
    @Published var showButtons = true
    @Published var showBody = true
    @Published var canAnimate = true
    @Published var showIPADetails = true
    @Published var IPAUUID = UUID()

    private var cancellables: Set<AnyCancellable> = []

    func showAlert(title: Text, body: Text, showButtons : Bool = true, showBody : Bool = true, canAnimate: Bool = true) {
        Just(())
            .receive(on: DispatchQueue.main)
            .sink { _ in
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
                self.isAlertPresented = true
                self.alertTitle = title
                self.alertBody = body
                self.showButtons = showButtons
                self.showBody = showBody
                self.canAnimate = canAnimate
                self.showIPADetails = false

            }
            .store(in: &cancellables)
    }
    
    func showIPADetails(id: UUID, canAnimate: Bool = true) {
        Just(())
            .receive(on: DispatchQueue.main)
            .sink { _ in
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
                self.isAlertPresented = true
                self.showIPADetails = true
                self.IPAUUID = id
                self.showButtons = true
                self.canAnimate = canAnimate
            }
            .store(in: &cancellables)
    }
}

struct AlertManagerView: View {
    
    @EnvironmentObject var alertManager: AlertManager

    var body: some View {
        ZStack {
            if alertManager.isAlertPresented {
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.1)
                VStack(alignment: .center) {
                    if alertManager.showIPADetails {
                        Text("Details Here")
                            .bold()
                    } else {
                        alertManager.alertTitle
                            .bold()

                        if alertManager.showBody || alertManager.showButtons {
                            Divider()
                                .opacity(0.1)
                        }
                        
                        if alertManager.showBody {
                            alertManager.alertBody
                        }
                    }

                    if alertManager.showButtons {
                        VStack {
                            Divider()

                            Text("OK")
                                .bold()

                            .frame(maxWidth: 270)
                            .padding(.vertical, 6)
                        }
                        .background(
                            Color(.systemGray5)
                                .opacity(0.1)
                        )
                        .onTapGesture {
                           withAnimation {
                               alertManager.isAlertPresented = false
                           }
                        }
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical)
                .frame(maxWidth: 300)
                .background(
                    Color(.systemGray5)
                        .cornerRadius(16)
                        .opacity(0.95)
                        .blur(radius: 0.5))
            }
        }
        .opacity(alertManager.isAlertPresented ? 1 : 0.25)
        .animation(.spring().speed(2), value: alertManager.isAlertPresented)
    }
}


