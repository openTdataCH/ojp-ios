//
//  OJPSampleApp.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import OJP
import Pulse
import PulseUI
import SwiftUI

@main
struct OJPSampleApp: App {
    init() {
        Experimental.URLSessionProxy.shared.isEnabled = true
    }

    @Environment(\.openWindow) private var openWindow
    @State var isShowingConsole: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VStack {
                    ZStack(alignment: .topLeading) {
                        Image("OpenTransportDataIcons")
                            .padding()
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
                    .background(.tint)
                    LocationSearchByNameView()
                }
            }.toolbar {
                ToolbarItemGroup {
                    Button {
                        if !isShowingConsole {
                            openWindow(id: "Console")
                        }
                        isShowingConsole.toggle()
                    } label: {
                        Image(systemName: "network")
                    }
                }
            }
        }

        WindowGroup(id: "Console") {
            DebuggerView(isShown: isShowingConsole)
        }
    }
}

struct DebuggerView: View {
    let isShown: Bool
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ConsoleView()
            .onChange(of: isShown) {
                if !isShown {
                    dismiss()
                }
            }
    }
}
