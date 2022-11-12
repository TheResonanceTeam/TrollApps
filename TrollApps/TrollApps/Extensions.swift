//
//  Extensions.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI

public struct appstorestyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(Color.accentColor)
            .padding(.vertical, 12)
            .foregroundColor(Color.white)
            .frame(width: 70, height: 29, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .fill(Color.gray)
                    .opacity(0.2)
            )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}
