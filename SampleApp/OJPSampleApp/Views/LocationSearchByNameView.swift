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
                            Toggle("Stops", isOn: $stopRestriction)
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
                    switch stop.place.place {
                    case let .stopPlace(stopPlace):
                        HStack {
                            Image(systemName: "tram")
                            Text(stopPlace.stopPlaceName.text)
                        }
                        .onTapGesture {
                            selectetedPlace = stop
                        }
                    case let .stopPoint(stopPoint):
                        HStack {
                            Image(systemName: "tram")
                            Text(stopPoint.stopPointName.text)
                        }
                        .onTapGesture {
                            selectetedPlace = stop
                        }
                    case let .topographicPlace(topographicPlace):
                        HStack {
                            Image(systemName: "mountain.2")
                            Text(topographicPlace.topographicPlaceName.text)
                        }
                        .onTapGesture {
                            selectetedPlace = stop
                        }
                    case let .address(address):
                        HStack {
                            Image(systemName: "location")
                            Text(address.name.text)
                        }
                        .onTapGesture {
                            selectetedPlace = stop
                        }
                    }
                }
                Map {
                    ForEach($results) { $result in
                        annotation(for: result)
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
                        results = try await ojp.requestPlaceResults(from: inputName, restrictions: placeParam)
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

    func annotation(for result: OJPv2.PlaceResult) -> Annotation<some View, some View> {
        Annotation(result.place.name.text, coordinate: result.geoPosition.coordinates) {
            Circle().onTapGesture {
                selectetedPlace = result
            }
        }
    }
}

#Preview {
    LocationSearchByNameView()
}
