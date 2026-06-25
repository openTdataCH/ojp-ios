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

    var sortedKeys: [String] {
        if case .pointOfInterest(let poi) = placeResult.place.place,
           let poiAdditionalInformation = poi.poiAdditionalInformation {
            return poiAdditionalInformation.keys.sorted()
        }
        return []
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            List {
                Text("Place").font(.headline)
                Text("Name: \(placeResult.place.name.text)")
                let geoPosition = placeResult.place.geoPosition
                Text("GeoPosition: (\(geoPosition.latitude), \(geoPosition.longitude))")
                if case .pointOfInterest(let poi) = placeResult.place.place {
                    Section {
                        ForEach(sortedKeys, id: \.self) { k in
                            HStack {
                                Text("\(k):")
                                Text("\(poi.poiAdditionalInformation?[k] ?? "")")
                            }
                        }

                    } header: {
                        Text("Sharing POI Details")
                    }
                }
            }
            .cornerRadius(10.0)
        }
        .padding()
    }
}
