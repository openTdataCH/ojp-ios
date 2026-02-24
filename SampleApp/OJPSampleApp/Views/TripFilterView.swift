//
//  TripFilterView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 24.02.2026.
//

import SwiftUI
import OJP


struct ModeFilterState: Equatable {
    var railMode: Bool = true
    var highspeedRail: Bool = true
    var internationalSubmode: Bool = true
    var localSubmode: Bool = true
    var waterMode: Bool = true
    var busMode: Bool = true
    var tramMode: Bool = true

    var isRailSubmodeExcluded: Bool {
        railMode && !(internationalSubmode && localSubmode)
    }

    var allPTModesEnabled: Bool {
        !isRailSubmodeExcluded && (railMode && waterMode && busMode && tramMode)
    }

    var railSubmodes: [OJPv2.ModeAndModeOfOperationFilter]? {
        guard isRailSubmodeExcluded && railMode else { return nil }
        var submodes = [OJPv2.ModeAndModeOfOperationFilter]()

        if highspeedRail {
            submodes.append(.init(mode: .railSubmode(.highSpeedRail), exclude: false))
        }

        if internationalSubmode {
            submodes.append(.init(mode: .railSubmode(.international), exclude: false))
        }

        if localSubmode {
            submodes.append(.init(mode: .railSubmode(.local), exclude: false))
        }

        return submodes
    }


    var modeFilters: [OJPv2.ModeAndModeOfOperationFilter]? {
        guard !allPTModesEnabled else {
            return nil
        }

        var modeFilters: [OJPv2.ModeAndModeOfOperationFilter] = []
        var ptModes: [OJPv2.Mode.PtMode] = []

        if isRailSubmodeExcluded {
            if let railsubmodes = railSubmodes {
                modeFilters.append(contentsOf: railsubmodes)
            }
        } else if railMode {
            ptModes.append(.rail)
        }

        if waterMode {
            ptModes.append(.water)
        }

        if busMode {
            ptModes.append(.bus)
        }

        if !ptModes.isEmpty {
            let ptModeFilters = OJPv2.ModeAndModeOfOperationFilter(mode: .ptModes(ptModes), exclude: false)
            modeFilters.append(ptModeFilters)
        }
        return modeFilters
    }

}

struct TripFilterView: View {

    @State var modeFilters: ModeFilterState = .init()

    @Binding var ojpTripParams: OJPv2.TripParams

    var body: some View {
        Form {
            Toggle("Rail", isOn: $modeFilters.railMode)
            Section {
                Text("Rail Submodes")
                Toggle("International", isOn: $modeFilters.internationalSubmode)

            }.disabled(!modeFilters.railMode)
            Toggle("Water", isOn: $modeFilters.waterMode)
            Toggle("Bus", isOn: $modeFilters.busMode)
            Toggle("Tram", isOn: $modeFilters.tramMode)
//            Toggle("Rail", isOn: $modeFilters.railMode)
//            Toggle("Rail", isOn: $modeFilters.railMode)
//            Toggle("Rail", isOn: $modeFilters.railMode)
        }.toggleStyle(.switch)
            .onChange(of: modeFilters) { _, _ in
                print("internal state")
                print(modeFilters)
                print("isRailSubmodeExcluded")
                print(modeFilters.isRailSubmodeExcluded)
                print("ojp filters")
                print(modeFilters.modeFilters)
                ojpTripParams.modeAndModeOfOperationFilter = modeFilters.modeFilters
            }
    }

}

#Preview {
    TripFilterView(ojpTripParams: .constant(.init()))
}
