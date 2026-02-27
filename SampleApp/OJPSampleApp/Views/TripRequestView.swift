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
    @State var ptSituations: Set<OJPv2.PTSituation> = []
    @State var origin: OJPv2.PlaceResult?
    @State var via: OJPv2.PlaceResult?
    @State var destination: OJPv2.PlaceResult?
    @State private var departureDateTime = Date.now
    @State var isLoading: Bool = false
    @State var paginatedActor: PaginatedTripLoader?
    @State var pageSize: Int = 6

    @State var showFilters: Bool = false
    @State var editOriginIndividualOptions: Bool = false
    @State var originIndividualOptions: OJPv2.IndividualTransportOption = .init(itModeAndModeOfOperation: .init(personalMode: .foot))

    @State var editDestinationIndividualOptions: Bool = false
    @State var destinationIndividualOptions: OJPv2.IndividualTransportOption = .init(itModeAndModeOfOperation: .init(personalMode: .foot))

    @State var tripParams: OJPv2.TripParams

    init(ojp: OJP, tripParams: OJPv2.TripParams = .init(
        includeTrackSections: false,
        includeLegProjection: false,
        includeIntermediateStops: true,
        useRealtimeData: .explanatory,
        modeAndModeOfOperationFilter: nil)) {
            self.ojp = ojp
            self.tripParams = tripParams
        }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
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
                        Toggle(isOn: $editOriginIndividualOptions) {
                            Text("Edit Origin Options")
                        }
                        IndividualTransportOptionView(individualTransportOption: $originIndividualOptions)

                    } else {
                        InlineLocationSerachView(ojp: ojp, textLabel: "From", selectedPlace: $origin)
                    }
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
                VStack(alignment: .leading) {
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
                        Toggle(isOn: $editDestinationIndividualOptions) {
                            Text("Edit Destination Options")
                        }
                        IndividualTransportOptionView(individualTransportOption: $destinationIndividualOptions)

                    } else {
                        InlineLocationSerachView(ojp: ojp, textLabel: "Destination", selectedPlace: $destination)
                    }
                }
                Button {
                    if let origin, let destination {
                        Task {
                            do {
                                let originTransportOptions = editOriginIndividualOptions ? [originIndividualOptions].compactMap(\.self) : nil
                                let destinationTransportOptions = editDestinationIndividualOptions ? [destinationIndividualOptions].compactMap(\.self) : nil

                                paginatedActor = PaginatedTripLoader(ojp: ojp)
                                let tripDelivery = try await paginatedActor!.loadTrips(
                                    for:
                                        TripRequest(
                                            from: origin.placeRef,
                                            to: destination.placeRef,
                                            via: via != nil ? [via!.placeRef] : nil,
                                            at: .departure(departureDateTime),
                                            params: tripParams,
                                            originTransportOptions: originTransportOptions,
                                            destinationTransportOptions: destinationTransportOptions
                                        ),
                                    numberOfResults: .standard(pageSize))
                                tripResults = tripDelivery.tripResults
                                ptSituations = Set(tripDelivery.ptSituations)
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    Text("Search")
                }
            }
            HStack(spacing: 20) {
                DatePicker("", selection: $departureDateTime)
                HStack {
                    Text("Page Size")
                    TextField("Page Size", value: $pageSize, formatter: NumberFormatter())
                        .frame(maxWidth: 30)
                }
            }
            Button("Filter") {
                showFilters.toggle()
            }
            if showFilters {
                VStack {
                    HStack {
                        Text("Filter").font(.title)
                        Spacer()
                    }
                    TripFilterView(ojpTripParams: $tripParams)
                    Divider()
                }
            }

            TripRequestResultView(
                ptSituations: Array(ptSituations),
                isLoading: isLoading,
                results: tripResults,
                loadPrevious: {
                    guard !isLoading else { return }
                    isLoading = true
                    Task { @MainActor in
                        guard let paginatedActor else { return }
                        let prev = try await paginatedActor.loadPrevious(pageSize)
                        tripResults = prev.tripResults + tripResults
                        ptSituations = ptSituations.union(prev.ptSituations)
                        isLoading = false
                    }
                },
                loadNext: {
                    guard !isLoading else { return }
                    isLoading = true
                    Task { @MainActor in
                        guard let paginatedActor else { return }
                        let next = try await paginatedActor.loadNext(pageSize)
                        tripResults = tripResults + next.tripResults
                        ptSituations = ptSituations.union(next.ptSituations)
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
