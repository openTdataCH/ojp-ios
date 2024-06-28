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
    @Binding var place: OJPv2.PlaceResult?
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let place {
                List {
                    Text("Place").font(.headline)
                    Text("Name: \(place.place.name.text)")
                    let geoPosition = place.place.geoPosition
                    Text("GeoPosition: (\(geoPosition.latitude), \(geoPosition.longitude))")
                }
                .cornerRadius(10.0)
            }
        }
        .padding()
    }
}

#Preview {
    PlaceDetailView(place: .constant(nil))
}
