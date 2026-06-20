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
    var body: some View {
        ZStack(alignment: .topLeading) {
            List {
                Text("Place").font(.headline)
                Text("Name: \(placeResult.place.name.text)")
                let geoPosition = placeResult.place.geoPosition
                Text("GeoPosition: (\(geoPosition.latitude), \(geoPosition.longitude))")

                if case .pointOfInterest(let poi) = placeResult.place.place, let poiAdditionalInformation = poi.poiAdditionalInformation {
                    Text("\(poiAdditionalInformation.map({ "\($0): \($1)" }).joined(separator: "\n"))")
                }
            }
            .cornerRadius(10.0)
        }
        .padding()
    }
}
