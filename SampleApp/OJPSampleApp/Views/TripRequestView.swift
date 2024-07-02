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
    @State var via: OJPv2.PlaceResult?
    @State var destination: OJPv2.PlaceResult?

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                if let origin {
                    HStack {
                        Text("From")
                        Text(origin.title).fontWeight(.bold)
                        Button {
                            self.origin = nil
                        } label: {
                            Image(systemName: "x.circle.fill")
                        }
                    }
                } else {
                    InlineLocationSerachView(ojp: ojp, textLabel: "From", selectedPlace: $origin)
                }

                if let via {
                    HStack {
                        Text("Via")
                        Text(via.title).fontWeight(.bold)
                        Button {
                            self.via = nil
                        } label: {
                            Image(systemName: "x.circle.fill")
                        }
                    }
                } else {
                    InlineLocationSerachView(ojp: ojp, textLabel: "Via", selectedPlace: $via)
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
                    InlineLocationSerachView(ojp: ojp, textLabel: "Destination", selectedPlace: $destination)
                }

                Button {
                    if let origin, let destination {
                        Task {
                            do {
                                tripResults = try await ojp.requestTrips(
                                    from: origin.placeRef,
                                    to: destination.placeRef,
                                    via: via != nil ? [via!.placeRef] : nil,
                                    params: .init(
                                        includeTrackSections: true,
                                        includeIntermediateStops: true
                                    )
                                )
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    Text("Search")
                }
            }
            TripRequestResultView(results: tripResults)
        }
    }
}

#Preview {
    TripRequestView(ojp: OJP(loadingStrategy: .http(.int)))
}
