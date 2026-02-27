//
//  IndividualTransportOptionView.swift
//  OJP
//
//  Created by Lehnherr Reto on 26.02.2026.
//

import SwiftUI
import OJP
import Duration

struct IndividualTransportOptionView: View {

    enum DurationSelection: CaseIterable {
        case tenMinutes
        case twentyMinutes
        case thirtyMinutes
        case oneHour
        case twoHours

        var duration: Duration {
            switch self {
            case .tenMinutes:
                Duration(minute: 10)
            case .twentyMinutes:
                Duration(minute: 20)
            case .thirtyMinutes:
                Duration(minute: 30)
            case .oneHour:
                Duration(hour: 1)
            case .twoHours:
                Duration(hour: 2)
            }
        }

        var title: String {
            switch self {
            case .tenMinutes:
                "10 Minutes"
            case .twentyMinutes:
                "20 Minutes"
            case .thirtyMinutes:
                "30 Minutes"
            case .oneHour:
                "One Hour"
            case .twoHours:
                "Two Hours"
            }
        }
    }

    @State var minDuration: DurationSelection?
    @State var maxDuration: DurationSelection?
    @State var minDistance: Int?
    @State var maxDistance: Int?

    @Binding var individualTransportOption: OJPv2.IndividualTransportOption
    @State var isExpanded: Bool = false

    init(individualTransportOption: Binding<OJPv2.IndividualTransportOption>) {
        // Note: personal mode currently not configurable

        _individualTransportOption = individualTransportOption
        self.minDistance = individualTransportOption.wrappedValue.minDistance
        self.maxDistance = individualTransportOption.wrappedValue.maxDistance
        self.maxDuration = nil // ignore...
        self.minDuration = nil
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(
                    "Show Individual Transport Options",
                    systemImage: isExpanded ? "chevron.down.circle" : "chevron.right.circle") {
                        isExpanded.toggle()
                    }
                    .buttonStyle(.plain)
                Spacer()
            }
            if isExpanded {
                Form {
                    Picker(selection: $minDuration) {
                        Text("-- empty --").tag(nil as DurationSelection?, includeOptional: true)
                        ForEach(DurationSelection.allCases, id: \.self) {
                            Text($0.title).tag($0)
                        }
                    } label: {
                        Text("Min Duration")
                    }
                    TextField("Min Distance [m]", value: $minDistance, formatter: NumberFormatter())
                    Divider()
                    Picker(selection: $maxDuration) {
                        Text("-- empty --").tag(nil as DurationSelection?, includeOptional: true)
                        ForEach(DurationSelection.allCases, id: \.self) {
                            Text($0.title).tag($0)
                        }
                    } label: {
                        Text("Max Duration")
                    }
                    TextField("Max Distance [m]", value: $maxDistance, formatter: NumberFormatter())
                }
            }
            Spacer()
        }
        .onChange(of: minDistance) { _, _ in
            individualTransportOption.minDistance = minDistance
        }
        .onChange(of: maxDistance) { _, _ in
            individualTransportOption.maxDistance = maxDistance
        }
        .onChange(of: minDuration) { _, _ in
            individualTransportOption.minDuration = minDuration?.duration
        }
        .onChange(of: maxDuration) { _, _ in
            individualTransportOption.maxDuration = maxDuration?.duration
        }
    }
}

#Preview {
    IndividualTransportOptionView(individualTransportOption: .constant(.init(itModeAndModeOfOperation: .init(personalMode: .foot)))).frame(width: 250, height: 300)
}
