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
        let (foregroundColor, fill) = colors(forType: type)

        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(dissabled ? Color.accentColor : foregroundColor)
            .padding(.vertical, 5)
            .padding(.horizontal, 18)
            .frame(height: 30, alignment: .center)
            .frame(minWidth: 80)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .fill(fill)
                    .opacity(dissabled ? 0.4 : type == "blue" || type == "pink" ? 1 : 0.2)
            )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}

public struct LongButtonStyle: ButtonStyle {
    let type: String
    let dissabled: Bool

    public init(type: String, dissabled: Bool, extraWidth: CGFloat = 0) {
        self.type = type
        self.dissabled = dissabled
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        let (foregroundColor, fill) = colors(forType: type)

        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(dissabled ? Color.accentColor : foregroundColor)
            .padding(.vertical, 5)
            .padding(.horizontal, 18)
            .frame(height: 50, alignment: .center)
            .frame(width: 350)
            .background(
                RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                    .fill(fill)
                    .opacity(dissabled ? 0.4 : type == "blue" || type == "pink" ? 1 : 0.2)
            )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}

private func colors(forType type: String) -> (Color, Color) {
    var foregroundColor : Color
    var fill : Color

    switch type {
    case "blue":
        foregroundColor = Color.white
        fill = Color.blue
    case "gray":
        foregroundColor = Color.accentColor
        fill = Color.gray
    case "pink":
        foregroundColor = Color.white
        fill = Color.pink
    default:
        foregroundColor = Color.accentColor
        fill = Color.gray
    }

    return (foregroundColor, fill)
}
