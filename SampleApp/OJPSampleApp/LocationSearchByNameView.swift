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

    let availableRange: [Int] = [5, 10, 20, 50, 100]

    var body: some View {
        HStack {
            VStack {
                Text("Search Stations by Name")
                Form {
                    TextField("Search Name", text: $inputName)
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
                        Text(stopPlace.stopPlaceName.text).onTapGesture {
                            selectetedPlace = stop
                        }
                    } else {
                        Text("Currently Unsupported PlaceType") // TODO: implment
                    }
                }
                Map {
                    ForEach($results) { $stop in
                        if case let .stopPlace(stopPlace) = stop.place.placeType {
                            Annotation(stopPlace.stopPlaceName.text,
                                       coordinate: stop.place.geoPosition?.coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                            {
                                Circle().onTapGesture {
                                    selectetedPlace = stop
                                }
                            }
                        } else {
                            Annotation("Currently Unssupported", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)) { Circle().fill(.red) } // TODO: implment
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
                        results = try await ojp.requestLocations(from: inputName, restrictions: [.stop]) // TODO: make restrictinos configruable
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
