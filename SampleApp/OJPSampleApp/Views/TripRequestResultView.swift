//
//  TripRequestResultView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import Duration
import OJP
import SwiftUI

enum DurationFormatter {
    static var formatter: DateComponentsFormatter {
        let f = DateComponentsFormatter()
        f.unitsStyle = .brief
        f.allowedUnits = [.day, .hour, .minute]
        return f
    }

    static func string(for duration: Duration) -> String {
        formatter.string(from: duration.dateComponents) ?? ""
    }
}

struct TripRequestResultView: View {
    @State var selectedTrip: OJPv2.Trip?
    let ptSituations: [OJPv2.PTSituation]
    let isLoading: Bool
    var results: [OJPv2.TripResult] = []
    var loadPrevious: (() -> Void)?
    var loadNext: (() -> Void)?

    var body: some View {
        HStack {
            ScrollView {
                if results.count > 0 {
                    Button(action: {
                        loadPrevious?()
                    }, label: {
                        Text("Load Previous")
                    })
                    .padding()
                }
                LazyVStack(spacing: 0) {
                    ForEach(results) { tripResult in
                        ZStack(alignment: .leading) {
                            if let trip = tripResult.trip {
                                if trip.tripHash == selectedTrip?.tripHash {
                                    Color.accentColor.frame(maxWidth: 2)
                                }
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(trip.originName)
                                        Text(trip.startTime.formatted())
                                    }
                                    Spacer()
                                    HStack(spacing: 2) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .imageScale(.small)
                                            .foregroundStyle(.secondary)
                                        Text(DurationFormatter.string(for: trip.duration))
                                    }
                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(trip.destinationName)
                                        Text(trip.endTime.formatted())
                                    }
                                }
                                .padding()
                            } else { Text("No Trips found") }
                        }
                        .background(Color.listBackground)
                        .onTapGesture {
                            selectedTrip = tripResult.trip
                        }
                        Divider()
                    }
                    .background(Color.listBackground)
                }
                if results.count > 0 {
                    Button(action: {
                        loadNext?()
                    }, label: {
                        Text("Load Next")
                    })
                    .padding()
                }
            }

            if let selectedTrip {
                TripDetailView(trip: selectedTrip, ptSituations: ptSituations)
                    .padding()
                    .frame(maxWidth: 400)
            }
        }
        .overlay(alignment: .center) { LoadingView(show: isLoading) }
        .frame(minWidth: 300)
    }
}

#Preview {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadTrips().tripResults
        },
        content: { t in
            TripRequestResultView(ptSituations: [], isLoading: false, results: t)
        }
    )
}
