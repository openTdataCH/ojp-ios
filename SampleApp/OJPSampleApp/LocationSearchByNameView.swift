//
//  LocationSearchByNameView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import SwiftUI
import OJP
import MapKit


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
                    Text(stop.place.stopPlace?.stopPlaceName.text ?? "No Stop Place") .onTapGesture {
                        self.selectetedPlace = stop
                    }
                }
                Map {
                    ForEach($results) { $stop in
                        Annotation(stop.place.stopPlace?.stopPlaceName.text ?? "No Stop Place",
                                   coordinate: stop.place.geoPosition?.coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
                            Circle().onTapGesture {
                                self.selectetedPlace = stop
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
                self.currentTask?.cancel()

                let ojp = OJP(loadingStrategy: .http(.int))
                let t = Task {
                    do {
                        results = try await ojp.requestLocations(from: inputName)
                        print(results)
                    } catch {
                        print(error)
                    }
                }
                self.currentTask = t
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
