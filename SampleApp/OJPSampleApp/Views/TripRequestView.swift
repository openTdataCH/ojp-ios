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

    @State var paginatedActor: PaginatedTripLoader?

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
                                paginatedActor = PaginatedTripLoader(ojp: ojp)
                                tripResults = try await paginatedActor!.loadTrips(for:
                                    TripRequest(from: origin.placeRef,
                                                to: destination.placeRef,
                                                via: via != nil ? [via!.placeRef] : nil,
                                                at: .departure(Date()),
                                                params: .init(
                                                    includeTrackSections: true,
                                                    includeIntermediateStops: true
                                                )),
                                    numberOfResults: .minimum(6))
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    Text("Search")
                }
            }
            TripRequestResultView(
                results: tripResults,
                loadPrevious: {
                    Task { @MainActor in
                        guard let paginatedActor else { return }
                        let prev = try await paginatedActor.loadPrevious()
                        tripResults = prev + tripResults
                    }
                },
                loadNext: {
                    Task { @MainActor in
                        guard let paginatedActor else { return }
                        let next = try await paginatedActor.loadNext()
                        tripResults = tripResults + next
                    }
                }
            )
        }
    }
}

#Preview {
    TripRequestView(ojp: OJP(loadingStrategy: .http(.int)))
}
