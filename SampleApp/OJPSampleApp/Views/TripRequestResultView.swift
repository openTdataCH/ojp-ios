//
//  TripRequestResultView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import OJP
import SwiftUI

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
