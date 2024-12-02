//
//  StopEventResultsView.swift
//  OJP
//
//  Created by Lehnherr Reto on 26.11.2024.
//

import OJP
import SwiftUI

struct StopEventResultsView: View {
    let ojp: OJP

    @State var origin: OJPv2.PlaceResult?

    @State var stopEventResults: [OJPv2.StopEventResult]?

    var body: some View {
        VStack {
            InlineLocationSerachView(
                ojp: ojp,
                textLabel: "Station",
                selectedPlace: $origin
            )
            if let stopEventResults {
                List(stopEventResults) { e in
                    StopEventView(stopEvent: e.stopEvent, mode: .departure)
                }
            }
            Spacer()
            Button {
                Task {
                    guard let origin else { return }
                    let stopEventDelivery = try await ojp.requestStopEvent(location: .init(placeRef: origin.placeRef, depArrTime: nil), params: nil)
                    stopEventResults = stopEventDelivery.stopEventResults
                }
            } label: {
                Text("Search")
            }
        }
    }
}

extension OJPv2.StopEventResult: @retroactive Identifiable {
    public var id: String {
        // 😱 https://github.com/openTdataCH/ojp-sdk/issues/173
        stopEvent.service.journeyRef
    }
}

#Preview {
    StopEventResultsView(ojp: OJP(loadingStrategy: .http(.int)))
}
