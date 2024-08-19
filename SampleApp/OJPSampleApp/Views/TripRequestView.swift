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
    @State var ptSituations: [OJPv2.PTSituation] = []
    @State var origin: OJPv2.PlaceResult?
    @State var via: OJPv2.PlaceResult?
    @State var destination: OJPv2.PlaceResult?
    @State private var departureDateTime = Date.now
    @State var isLoading: Bool = false
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
                                let tripDelivery = try await paginatedActor!.loadTrips(for:
                                    TripRequest(from: origin.placeRef,
                                                to: destination.placeRef,
                                                via: via != nil ? [via!.placeRef] : nil,
                                                at: .departure(departureDateTime),
                                                params: .init(
                                                    includeTrackSections: true,
                                                    includeIntermediateStops: true,
                                                    useRealtimeData: .explanatory
                                                )),
                                    numberOfResults: .minimum(6))
                                tripResults = tripDelivery.tripResults
                                ptSituations = tripDelivery.ptSituations
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    Text("Search")
                }
            }
            DatePicker("Departure", selection: $departureDateTime)
            TripRequestResultView(
                ptSituations: ptSituations, isLoading: isLoading,
                results: tripResults,
                loadPrevious: {
                    guard !isLoading else { return }
                    isLoading = true
                    Task { @MainActor in
                        guard let paginatedActor else { return }
                        let prev = try await paginatedActor.loadPrevious()
                        tripResults = prev.tripResults + tripResults
                        ptSituations = prev.ptSituations + ptSituations
                        isLoading = false
                    }
                },
                loadNext: {
                    guard !isLoading else { return }
                    isLoading = true
                    Task { @MainActor in
                        guard let paginatedActor else { return }
                        let next = try await paginatedActor.loadNext()
                        tripResults = tripResults + next.tripResults
                        ptSituations = ptSituations + next.ptSituations
                        isLoading = false
                    }
                }
            )
        }
    }
}

#Preview {
    TripRequestView(ojp: OJP(loadingStrategy: .http(.int)))
}
