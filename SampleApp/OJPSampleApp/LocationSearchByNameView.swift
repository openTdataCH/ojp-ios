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

extension OJPv2.PlaceResult: Identifiable {
    public var id: String {
        self.place.stopPlace.privateCode.value
    }
}

struct LocationSearchByNameView: View {
    @State var inputName: String = ""
    @State var results: [OJPv2.PlaceResult] = []
    @State var selectetedPlace: OJPv2.PlaceResult?
    @State var limit: Int = 10
    @State var currentTask: Task<Void, Never>?


    let availableRange: [Int] = [5, 10, 20, 50, 100]

    var body: some View {
        NavigationSplitView {
            Text("Search Stations by Name")
            Form {
                TextField("Search Name", text: $inputName)
                Picker(selection: $limit) {
                    ForEach(availableRange, id: \.self) {
                        Text("\($0)").tag($0)
                    }
                } label: {
                    Text("Limit")
                }
            }
        } content: {
            VStack {
                List($results) { $stop in
                    Text(stop.place.stopPlace.stopPlaceName.text) .onTapGesture {
                        self.selectetedPlace = stop
                    }
                }
                Map {
                    ForEach($results) { $stop in
                        Annotation(stop.place.stopPlace.stopPlaceName.text,
                                   coordinate: stop.place.geoPosition.coordinates) {
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
            .padding()
            .onChange(of: inputName) { oldValue, newValue in
                guard oldValue != newValue else { return }
                self.currentTask?.cancel()

                let ojp = OJP(loadingStrategy: .http(.int))
                let t = Task {
                    do {
                        results = try await ojp.stations(by: newValue, limit: limit)
                        print(results)
                    } catch {
                        print(error)
                    }
                }
                self.currentTask = t
            }
        } detail: {
            if selectetedPlace != nil {
                PlaceDetailView(place: $selectetedPlace)
            }
        }
    }
}

#Preview {
    LocationSearchByNameView()
}
