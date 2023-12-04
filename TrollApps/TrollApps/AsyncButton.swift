//
//  AsyncButton.swift
//
//  Borrowed from https://www.swiftbysundell.com/articles/building-an-async-swiftui-button/
//

import Foundation
import SwiftUI

struct AsyncButton<Label: View>: View {
	var action: () async -> Void
	@ViewBuilder var label: () -> Label

	@State private var isPerformingTask = false

	var body: some View {
		Button(
			action: {
				withAnimation{
					isPerformingTask = true
				}
				Task {
					await action()
					withAnimation{
						isPerformingTask = false
					}
				}
			},
			label: {
				ZStack {
					label().opacity(isPerformingTask ? 0 : 1)

					if isPerformingTask {
						ProgressView()
					}
				}
			}
		)
		.disabled(isPerformingTask)
	}
}
