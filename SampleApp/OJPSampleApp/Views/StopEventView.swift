//
//  StopEventView.swift
//  OJP
//
//  Created by Lehnherr Reto on 26.11.2024.
//

import SwiftUI
import OJP

struct StopEventView: View {
    let ojp: OJP

    @State var origin: OJPv2.PlaceResult?

    var body: some View {
        VStack {
            InlineLocationSerachView(
                ojp: ojp,
                textLabel: "Station",
                selectedPlace: $origin
            )
            Spacer()
            Button {
                Task {
                    guard let origin else { return }
                    let stopEventDelivery = try await ojp.requestStopEvent(location: .init(placeRef: origin.placeRef, depArrTime: nil), params: nil)
                    dump(stopEventDelivery)
                }
            } label: {
                Text("Search")

            }
        }
    }
}

