//
//  OJPSampleApp.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import SwiftUI
import OJP
import Pulse
import PulseUI

@main
struct OJPSampleApp: App {

    init() {
        Experimental.URLSessionProxy.shared.isEnabled = true
    }

    var body: some Scene {
        WindowGroup {
            NavigationView(content: {
                List {
                    NavigationLink {
                        LocationSearchByNameView()
                    } label: { Text("Station Search") }
                    NavigationLink {
                        ConsoleView()
                    } label: { Text("Network Console") }
                }
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
                    Spacer()
                    Text("Hello OJP!").font(.title)
                    Spacer()
                }
            })
        }
//        .onChange(of: scenePhase) { oldValue, newValue in
//            switch newValue {
//            case .active:
//                URLSessionProxyDelegate.enableAutomaticRegistration()
//            default:
//                break
//            }
//        }
    }
}
