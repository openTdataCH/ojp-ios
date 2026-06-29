//
//  OJPSampleApp.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import OEVIcons
import OJP
import Pulse
import PulseUI
import SwiftUI

enum AppSection: CaseIterable, Identifiable {
    case locationInformationRequest
    case tripRequest
    case stopEventRequest
    case sharingPOIs

    var id: Self { self }

    var title: String {
        switch self {
        case .locationInformationRequest:
            "LocationInformationRequest"
        case .tripRequest:
            "TripRequest"
        case .stopEventRequest:
            "StopEventRequest"
        case .sharingPOIs:
            "Shared Mobility"
        }
    }

    var image: Image {
        switch self {
        case .locationInformationRequest:
            Pictograms.stands_l_en_small
        case .tripRequest:
            Pictograms.stands_t_en_small
        case .stopEventRequest:
            Pictograms.stands_s_en_small
        case .sharingPOIs:
            Pictograms.bicycle_park_left_framed
        }
    }
}

@main
struct OJPSampleApp: App {
    init() {
        Experimental.URLSessionProxy.shared.isEnabled = true
    }

    @Environment(\.openWindow) private var openWindow
    @State var isShowingConsole: Bool = false
    @AppStorage("DemoEnvironment") var environment: String = DemoEnvironment.int.rawValue

    @State var currentSection: AppSection = .locationInformationRequest

    var body: some Scene {
        WindowGroup {
            NavigationSplitView(sidebar: {
                List(selection: $currentSection) {
                    ForEach(AppSection.allCases) { l in
                        HStack {
                            l.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)

                            Text(l.title)
                        }
                    }
                }
            }, detail: {
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
                    switch currentSection {
                    case .locationInformationRequest:
                        LocationSearchByNameView()
                    case .tripRequest:
                        TripRequestView()
                    case .stopEventRequest:
                        StopEventResultsView()
                    case .sharingPOIs:
                        SharedMobilityMapView()
                    }
                }
            }).toolbar {
                ToolbarItemGroup {
                    Picker("Environment", selection: $environment) {
                        ForEach(DemoEnvironment.allCases) { env in
                            Text(env.title).tag(env.id)
                        }
                    }.pickerStyle(.segmented)

                    Button {
                        if !isShowingConsole {
                            openWindow(id: "Console")
                        }
                        isShowingConsole.toggle()
                    } label: {
                        Image(systemName: "network")
                    }
                }
            }.navigationSplitViewStyle(.balanced)
        }
        .environment(\.ojp, OJP.configured)

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
