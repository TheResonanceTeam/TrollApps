//
//  Buttons.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import SwiftUI

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
