//
//  AsyncView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 28.06.2024.
//

import SwiftUI

/// Conveniene container view for Previews with async state. E.g. when loading mocks
struct AsyncView<Content: View, S: Sendable>: View {
    let task: () async -> S
    @State var state: S
    @ViewBuilder let content: (S) -> Content

    var body: some View {
        content(state)
            .task {
                state = await task()
            }
    }
}

#Preview {
    AsyncView(
        task: {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            return "Loaded Example"
        },
        state: "Loading",
        content: { text in
            Text(text)
        }
    )
}
