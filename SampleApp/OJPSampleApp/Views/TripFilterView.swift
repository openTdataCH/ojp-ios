//
//  TripFilterView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 24.02.2026.
//

import SwiftUI
import OJP


struct RailSubmodeFilterState: Equatable {
    let title: String
    let railSubmode: OJPv2.RailSubmode
    var isOn: Bool = true
}

struct ModeFilterState: Equatable {
    var railMode: Bool = true
    var highspeedRail: Bool = true
    var internationalSubmode: Bool = true
    var localSubmode: Bool = true
    var waterMode: Bool = true
    var busMode: Bool = true
    var tramMode: Bool = true

    var railSubmodes: [RailSubmodeFilterState] = [
        .init(title: "International", railSubmode: .international),
        .init(title: "High Speed Rail", railSubmode: .highSpeedRail),
        .init(title: "Interregional Rail", railSubmode: .interregionalRail),
        .init(title: "Rail Shuttle", railSubmode: .railShuttle),
        .init(title: "Local", railSubmode: .local),
    ]

    var isRailSubmodeExcluded: Bool {
        railMode && railSubmodes.contains(where: {$0.isOn == false})
    }

    var allPTModesEnabled: Bool {
        !isRailSubmodeExcluded && (railMode && waterMode && busMode && tramMode)
    }

    var modeFilters: [OJPv2.ModeAndModeOfOperationFilter]? {
        guard !allPTModesEnabled else {
            return nil
        }

        var modeFilters: [OJPv2.ModeAndModeOfOperationFilter] = []
        var ptModes: [OJPv2.Mode.PtMode] = []

        if isRailSubmodeExcluded {
            let submodeFilters = railSubmodes
                .filter({$0.isOn})
                .map {
                    OJPv2.ModeAndModeOfOperationFilter(mode: .railSubmode($0.railSubmode), exclude: false)
                }
            modeFilters.append(contentsOf: submodeFilters)
        } else if railMode {
            ptModes.append(.rail)
        }

        if waterMode {
            ptModes.append(.water)
        }

        if busMode {
            ptModes.append(.bus)
        }

        if tramMode {
            ptModes.append(.tram)
        }

        if !ptModes.isEmpty {
            let ptModeFilters = OJPv2.ModeAndModeOfOperationFilter(mode: .ptModes(ptModes), exclude: false)
            modeFilters.append(ptModeFilters)
        }
        return modeFilters
    }
}


struct TripFilterView: View {

    enum TransferLimit: String, CaseIterable {
        case none
        case noTransfer
        case oneTransfer

        var ojpValue: Int? {
            switch self {
            case .none:
                nil
            case .noTransfer:
                0
            case .oneTransfer:
                1
            }
        }
        var title: String {
            switch self {
            case .none:
                "No Limit"
            case .noTransfer:
                "0 Transfers"
            case .oneTransfer:
                "1 Transfer"
            }
        }
    }

    enum WalkSpeed: Int, CaseIterable {
        case veryFast = 400
        case fast = 200
        case aBitFaster = 150
        case normal = 100
        case slower = 75
        case slowest = 50

        var title: String {
            "\(rawValue)%"
        }
    }


    @State var modeFilters: ModeFilterState = .init()
    @State var optimisationMethod: OJPv2.OptimisationMethod? = nil
    @State var transferLimit: TransferLimit = .none
    @State var bikeTransport: Bool = false
    @State var walkSpeed: WalkSpeed?
    @Binding var ojpTripParams: OJPv2.TripParams

    var body: some View {
        HStack(alignment: .top) {
            Form {
                Toggle("Rail", isOn: $modeFilters.railMode)
                Section {
                    Divider()
                    Text("Rail Submodes")
                    ForEach($modeFilters.railSubmodes, id: \.railSubmode.rawValue) { $submode in
                        Toggle(isOn: $submode.isOn) {
                            Text(submode.title)
                        }
                    }
                    Divider()

                }.disabled(!modeFilters.railMode)
                Toggle("Water", isOn: $modeFilters.waterMode)
                Toggle("Bus", isOn: $modeFilters.busMode)
                Toggle("Tram", isOn: $modeFilters.tramMode)
            }
            Form {
                Section {
                    Picker(selection: $optimisationMethod) {
                        Text("Default (nil)").tag(nil as OJPv2.OptimisationMethod?, includeOptional: true)
                        Text("Fastest Connection").tag(OJPv2.OptimisationMethod.fastest)
                        Text("Minimal Changes").tag(OJPv2.OptimisationMethod.minChanges)
                    } label: {
                        Text("Optimisation")
                    }

                    Picker(selection: $transferLimit) {
                        ForEach(TransferLimit.allCases, id: \.rawValue) {
                            Text($0.title)
                                .tag($0)
                        }
                    }
                     label: {
                        Text("TransferLimit")
                    }

                    Toggle("Bike Transport", isOn: $bikeTransport)

                    Picker(selection: $walkSpeed) {
                        Text("Default (nil)").tag(nil as WalkSpeed?, includeOptional: true)
                        ForEach(WalkSpeed.allCases, id: \.rawValue) {
                            Text($0.title)
                                .tag($0)
                        }
                    }
                     label: {
                        Text("TransferLimit")
                    }

                }
            }
        }.toggleStyle(.automatic)
            .onChange(of: modeFilters) { _, _ in
                ojpTripParams.modeAndModeOfOperationFilter = modeFilters.modeFilters
            }
            .onChange(of: optimisationMethod) { _, _ in
                ojpTripParams.optimisationMethod = optimisationMethod
            }
            .onChange(of: transferLimit) {_,_ in
                ojpTripParams.transferLimit = transferLimit.ojpValue
            }
            .onChange(of: bikeTransport) { _, _ in
                ojpTripParams.bikeTransport = bikeTransport ? true : nil
            }
            .onChange(of: walkSpeed) { _, _ in
                ojpTripParams.walkSpeed = walkSpeed?.rawValue
            }
    }
}

#Preview {
    TripFilterView(ojpTripParams: .constant(.init()))
}
