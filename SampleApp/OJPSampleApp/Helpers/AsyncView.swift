//
//  AsyncView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 28.06.2024.
//

import SwiftUI

/// Conveniene container view for Previews with async state. E.g. when loading mocks
struct AsyncView<Content: View, S: Sendable>: View {
    enum AsyncViewState: Sendable {
        case loading
        case success(S)
        case failed(Error)
    }

    let task: () async throws -> S
    @State var state: AsyncViewState = .loading
    @ViewBuilder let content: (S) -> Content

    var body: some View {
        switch state {
        case .loading:
            Text("Loading")
                .frame(minWidth: 200, minHeight: 200)
                .task {
                    do {
                        state = try await .success(task())
                    } catch {
                        state = .failed(error)
                    }
                }
        case let .success(s):
            content(s)
        case let .failed(error):
            VStack {
                Text("Loading Failed").fontWeight(.bold)
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    AsyncView(
        task: {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return "Loaded Example"
        },
        content: { text in
            Text(text)
        }
    )
}
