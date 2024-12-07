//
//  InlineLocationSerachView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 28.06.2024.
//

import OJP
import SwiftUI

struct InlineLocationSerachView: View {
    let ojp: OJP

    @State private var searchText: String = ""
    @State private var results: [OJPv2.PlaceResult] = []
    @State private var currentTask: Task<Void, Never>? = nil

    @State private var ignoreUpdate: Bool = false

    var textLabel: String
    @Binding var selectedPlace: OJPv2.PlaceResult?

    var body: some View {
        VStack {
            TextField(textLabel, text: $searchText)
            if results.count > 0 {
                ZStack {
                    List($results) { $stop in
                        switch stop.place.place {
                        case let .stopPlace(stopPlace):
                            HStack {
                                Image(systemName: "tram")
                                Text(stopPlace.stopPlaceName.text)
                                Spacer()
                            }
                            .background(Color.listBackground)
                            .frame(maxHeight: .infinity)
                            .onTapGesture {
                                handleTap(selectedPlace: stop)
                            }
                        case let .address(address):
                            HStack {
                                Image(systemName: "location")
                                Text(address.name.text)
                                Spacer()
                            }
                            .background(Color.listBackground)
                            .onTapGesture {
                                handleTap(selectedPlace: stop)
                            }
                        case let .stopPoint(stopPoint):
                            HStack {
                                Image(systemName: "tram")
                                Text(stopPoint.stopPointName.text)
                                Spacer()
                            }
                            .background(Color.listBackground)
                            .frame(maxHeight: .infinity)
                            .onTapGesture {
                                handleTap(selectedPlace: stop)
                            }
                        case let .topographicPlace(topographicPlace):
                            HStack {
                                Image(systemName: "mountain.2")
                                Text(topographicPlace.topographicPlaceName.text)
                                Spacer()
                            }
                            .background(Color.listBackground)
                            .onTapGesture {
                                handleTap(selectedPlace: stop)
                            }
                        }
                    }
                }
            }
        }.onChange(of: searchText) { old, new in
            guard old != new, !ignoreUpdate else {
                ignoreUpdate = false
                return
            }
            currentTask?.cancel()
            currentTask = Task { @MainActor in
                do {
                    results = try await ojp.requestPlaceResults(from: searchText, restrictions: .init(type: [.stop, .address])) // make adjustable
                } catch {
                    print(error)
                }
            }
        }
    }

    func handleTap(selectedPlace: OJPv2.PlaceResult?) {
        results = []
        self.selectedPlace = selectedPlace
        ignoreUpdate = true
        if let title = selectedPlace?.title {
            searchText = title
        }
    }
}

#Preview {
    InlineLocationSerachView(ojp: OJP(loadingStrategy: .http(.int)), textLabel: "From", selectedPlace: .constant(nil))
}
