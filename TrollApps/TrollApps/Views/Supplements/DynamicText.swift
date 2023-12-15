//
//  DynamicText.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import SwiftUI

struct CollapsibleText: View {
    var text: String
    @Binding var isExpanded: Bool
    let maxLines: Int

    var body: some View {
        Text(text)
            .lineLimit(isExpanded ? nil : maxLines)
            .multilineTextAlignment(.leading)
    }
}
