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
                                        Text(
                                            (
                                                trip.firstTimedLeg?.legBoard.serviceDeparture.timetabledTime ?? trip.startTime
                                            ).formatted()
                                        )
                                    }
                                    Spacer()
                                    VStack {
                                        HStack(spacing: 4) {
                                            Image(systemName: "clock.arrow.circlepath")
                                                .imageScale(.small)
                                            Text(DurationFormatter.string(for: trip.duration))
                                        }

                                        if trip.tripStatus.hasIssue {
                                            TripStatusLabel(tripStatus: trip.tripStatus)
                                        } else if trip.hasSituation(allPtSituations: ptSituations) {
                                            Image(systemName: "bolt.circle.fill")
                                                .foregroundStyle(.red)
                                        } else { Spacer() }
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(trip.destinationName)
                                        Text(
                                            (
                                                trip.lastTimedLeg?.legAlight.serviceArrival.timetabledTime ?? trip.endTime
                                            ).formatted()
                                        )
                                    }
                                }.foregroundStyle(trip.tripStatus.cancelled == true ? .red : Color.label)
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

            if selectedTrip != nil {
                TripDetailView(trip: $selectedTrip, ptSituations: ptSituations)
                    .padding()
                    .frame(maxWidth: 400)
            }
        }
        .overlay(alignment: .center) { LoadingView(show: isLoading) }
        .frame(minWidth: 300)
    }
}

#Preview("Cancellations and Not Serviced") {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadTrips(xmlFileName: "tr-with-cancellations-and-notservicedstops").tripResults
        },
        content: { t in
            TripRequestResultView(ptSituations: [], isLoading: false, results: t)
        }
    )
}

#Preview("Situations") {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadTrips(xmlFileName: "tr-fribourg-basel")
        },
        content: { t in
            TripRequestResultView(
                ptSituations: t.tripResponseContext?.situations?.ptSituations ?? [],
                isLoading: false,
                results: t.tripResults
            )
        }
    )
}

struct TripStatusLabel: View {
    let tripStatus: OJPv2.TripStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle")
                .imageScale(.small)
            Text(tripStatus.title)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 4)
        .background(.red)
        .clipShape(Capsule())
    }
}

struct AlertLabel: View {
    let alertCause: OJPv2.AlertCause

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle") // TODO: make conditional to cause
                .imageScale(.small)
            Text(alertCause.title)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 4)
        .background(.red)
        .clipShape(Capsule())
    }
}
