//
//  LocationSearchByNameView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import MapKit
import OJP
import SwiftUI

struct LocationResult: Identifiable {
    var id: String
    var title: String
    var coordinates: CLLocationCoordinate2D
}

struct LocationSearchByNameView: View {
    @State var inputName: String = ""
    @State var results: [OJPv2.PlaceResult] = []
    @State var selectetedPlace: OJPv2.PlaceResult?
    @State var limit: Int = 10
    @State var currentTask: Task<Void, Never>?
    @State var addressRestriction = false
    @State var stopRestriction = true
    @State var includePTModes = false

    let availableRange: [Int] = [5, 10, 20, 50, 100]

    private var placeParam: OJPv2.PlaceParam {
        var placeType: [PlaceType] = []
        if addressRestriction {
            placeType.append(.address)
        }
        if stopRestriction {
            placeType.append(.stop)
        }

        return OJPv2.PlaceParam(type: placeType, numberOfResults: limit, includePtModes: includePTModes)
    }

    var body: some View {
        HStack {
            VStack {
                Text("Search Stations by Name")
                Form {
                    TextField("Search Name", text: $inputName)
                    Section {
                        ControlGroup {
                            Toggle("Addresses", isOn: $addressRestriction)
                            Toggle("stops", isOn: $stopRestriction)
                        }
                        Toggle("Include PT Modes", isOn: $includePTModes)
                        Picker("Limit", selection: $limit) {
                            ForEach(availableRange, id: \.self) {
                                Text("\($0)").tag($0)
                            }
                        }
                    } header: {
                        Text("Restrictions")
                    }
                }
                List($results) { $stop in
                    if case let .stopPlace(stopPlace) = stop.place.placeType {
                        HStack {
                            Image(systemName: "tram")
                            Text(stopPlace.stopPlaceName.text)
                        }
                        .onTapGesture {
                            selectetedPlace = stop
                        }
                    } else if case let .address(address) = stop.place.placeType {
                        HStack {
                            Image(systemName: "location")
                            Text(address.name.text)
                        }
                        .onTapGesture {
                            selectetedPlace = stop
                        }
                    } else {
                        Text("Currently Unsupported PlaceType") // TODO: implment
                    }
                }
                Map {
                    ForEach($results) { $result in
                        switch result.place.placeType {
                        case let .stopPlace(stopPlace):
                            Annotation(stopPlace.stopPlaceName.text,
                                       coordinate: result.place.geoPosition?.coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                            {
                                Circle().onTapGesture {
                                    selectetedPlace = result
                                }
                            }
                        case let .address(address):
                            Annotation(address.name.text,
                                       coordinate: result.place.geoPosition?.coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                            {
                                Circle().onTapGesture {
                                    selectetedPlace = result
                                }
                            }
                        }
                    }
                }
                if !inputName.isEmpty {
                    Text("Found \(results.count) Results (Limit: \(limit))")
                }
            }

            .onChange(of: inputName) { oldValue, newValue in
                guard oldValue != newValue else { return }
                currentTask?.cancel()

                let ojp = OJP.configured
                let t = Task {
                    do {
                        results = try await ojp.requestLocations(from: inputName, restrictions: placeParam)
                        print(results)
                    } catch {
                        print(error)
                    }
                }
                currentTask = t
            }

            if selectetedPlace != nil {
                PlaceDetailView(place: $selectetedPlace)
                    .frame(maxWidth: 200)
            }
        }.padding()
    }
}

#Preview {
    LocationSearchByNameView()
}
