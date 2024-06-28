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
    var results: [OJPv2.TripResult] = []

    var body: some View {
        VStack {
            List(results) { tripResult in
                HStack {
                    if let trip = tripResult.trip {
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
                    } else { Text("No Trips found") }
                }
            }
        }
    }
}

#Preview {
    AsyncView(
        task: {
            await PreviewMocker.shared.loadTrips()
        },
        state: [],
        content: { t in
            TripRequestResultView(results: t)
        }
    )
}
