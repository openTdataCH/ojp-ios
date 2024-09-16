//
//  LoadingView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.07.2024.
//

import SwiftUI

struct LoadingView: View {
    let show: Bool

    var body: some View {
        if show {
            ZStack {
                Color.gray.opacity(0.2)
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Loading...")
                }
            }
        }
    }
}

#Preview {
    LoadingView(show: true)
}
