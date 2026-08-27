//
//  PlaceDetailView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import OJP
import SwiftUI

struct PlaceDetailView: View {
    // quick and dirty data flow, just for hacking purpose
    let placeResult: OJPv2.PlaceResult

    private let poiAdditionalInfoMess: [(Int, OJPv2.CategoryKeyValue)]
    
    init(placeResult: OJPv2.PlaceResult) {
        self.placeResult = placeResult
        if case let .pointOfInterest(poi) = placeResult.place.place,
           let poiAdditionalInformation = poi.poiAdditionalInformation {
            poiAdditionalInfoMess = poiAdditionalInformation.enumerated().map({ ($0.offset, $0.element) })
        } else { self.poiAdditionalInfoMess = [] }
    }
    
    var body: some View {
        ScrollView {
            Grid(alignment: .topLeading) {
                Text("Place")
                    .font(.headline)
                GridRow {
                    Text("Name:")
                    Text(placeResult.place.name.text)
                        .monospaced()
                }
                let geoPosition = placeResult.place.geoPosition
                GridRow {
                    Text("GeoPosition:")
                    Text("\(geoPosition.latitude), \(geoPosition.longitude)")
                        .monospaced()

                }
                if !poiAdditionalInfoMess.isEmpty {
                    Divider()
                    ForEach(poiAdditionalInfoMess, id: \.0) { _, keyValue in
                        GridRow {
                            Text("\(keyValue.key):")
                            VStack(alignment: .leading) {
                                Text("\(keyValue.value)")
                                if let category = keyValue.category {
                                    Text("Category: \(category)")
                                }
                            }.monospaced()
                         
                        }
                    }
                }
            }
            .cornerRadius(10.0)
        }
        .padding()
    }
}
