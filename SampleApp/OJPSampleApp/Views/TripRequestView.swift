//
//  TripRequestView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 28.06.2024.
//

import OJP
import SwiftUI

struct TripRequestView: View {
    let ojp: OJP

    @State var tripResults: [OJPv2.TripResult] = []
    @State var origin: OJPv2.PlaceResult?
    @State var destination: OJPv2.PlaceResult?

    var body: some View {
        VStack {
            HStack {
                if let origin {
                    HStack {
                        Text("Form")
                        Text(origin.title).fontWeight(.bold)
                        Button {
                            self.origin = nil
                        } label: {
                            Image(systemName: "x.circle.fill")
                        }
                    }
                } else {
                    InlineLocationSerachView(ojp: ojp, selectedPlace: $origin)
                }

                if let destination {
                    HStack {
                        Text("To")
                        Text(destination.title).fontWeight(.bold)
                        Button {
                            self.destination = nil
                        } label: {
                            Image(systemName: "x.circle.fill")
                        }
                    }
                } else {
                    InlineLocationSerachView(ojp: ojp, selectedPlace: $destination)
                }
            }
            Button {
                if let origin, let destination {
                    Task {
                        do {
                            tripResults = try await ojp.requestTrips(from: origin.placeRef, to: destination.placeRef, params: .init())
                        } catch {
                            print(error)
                        }
                    }
                }
            } label: {
                Text("Search")
            }

            TripRequestResultView(results: tripResults)
        }
    }
}

#Preview {
    TripRequestView(ojp: OJP(loadingStrategy: .http(.int)))
}
