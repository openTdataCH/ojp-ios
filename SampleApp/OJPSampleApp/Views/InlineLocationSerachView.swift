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
                            .background(Color.white)
                            .frame(maxHeight: .infinity)
                            .onTapGesture {
                                selectedPlace = stop
                                results = []
                            }
                        case let .address(address):
                            HStack {
                                Image(systemName: "location")
                                Text(address.name.text)
                                Spacer()
                            }
                            .background(Color.white)
                            .onTapGesture {
                                selectedPlace = stop
                                results = []
                            }
                        }
                    }
                }
            }
        }.onChange(of: searchText) { _, _ in
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
}

#Preview {
    InlineLocationSerachView(ojp: OJP(loadingStrategy: .http(.int)), textLabel: "From", selectedPlace: .constant(nil))
}
