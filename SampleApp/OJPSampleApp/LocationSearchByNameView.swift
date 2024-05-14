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

    let availableRange: [Int] = [5, 10, 20, 50, 100]
    
    private var placeParam: OJPv2.PlaceParam {
        if addressRestriction && stopRestriction {
            return OJPv2.PlaceParam(type: [.stop, .address])
        } else if addressRestriction {
            return OJPv2.PlaceParam(type: [.address])
        } else if stopRestriction {
            return OJPv2.PlaceParam(type: [.stop])
        } else {
            return OJPv2.PlaceParam(type: [])   // not really supported
        }
    }

    var body: some View {
        HStack {
            VStack {
                Text("Search Stations by Name")
                Form {
                    TextField("Search Name", text: $inputName)
                    Toggle(isOn: $addressRestriction) {
                                Text("Addresses")
                            }
                            .toggleStyle(.checkbox)
                    Toggle(isOn: $stopRestriction) {
                                Text("Stops")
                            }
                            .toggleStyle(.checkbox)
                    // can't define number of results any more
//                    Picker(selection: $limit) {
//                        ForEach(availableRange, id: \.self) {
//                            Text("\($0)").tag($0)
//                        }
//                    } label: {
//                        Text("Limit")
//                    }
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
                        case .stopPlace(let stopPlace):
                            Annotation(stopPlace.stopPlaceName.text,
                                       coordinate: result.place.geoPosition?.coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                            {
                                Circle().onTapGesture {
                                    selectetedPlace = result
                                }
                            }
                        case .address(let address):
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
