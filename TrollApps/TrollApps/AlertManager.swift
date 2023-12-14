//
//  AlertManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-12.
//

import SwiftUI
import Combine

class AlertManager: ObservableObject {
    @Published var isAlertPresented = false
    @Published var alertTitle = ""
    @Published var alertBody = ""
    @Published var showButtons = true
    @Published var canAnimate = true

    private var cancellables: Set<AnyCancellable> = []

    func showAlert(title: String, body: String, showButtons : Bool = true, canAnimate: Bool = true) {
        Just(())
            .receive(on: DispatchQueue.main)
            .sink { _ in
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)

                self.isAlertPresented = true
                self.alertTitle = title
                self.alertBody = body
                self.showButtons = showButtons
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
                    Text(LocalizedStringKey(alertManager.alertTitle))
                        .bold()
                    Divider()
                        .opacity(0.1)
                    Text(LocalizedStringKey(alertManager.alertBody))

                    if(alertManager.showButtons) {
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


