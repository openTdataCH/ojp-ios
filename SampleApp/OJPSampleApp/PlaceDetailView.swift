//
//  PlaceDetailView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import SwiftUI
import OJP

struct PlaceDetailView: View {
    // quick and dirty data flow, just for hacking purpose
    @Binding var place: OJPv2.PlaceResult?
    var body: some View {
        ZStack {
            if let place {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.place = nil
                        }, label: {
                            Image(systemName: "xmark")
                        })
                    }

                    VStack {
                        Text("Place").font(.headline)
                        Text("Name: \(place.place.name.text)")
                        Text("GeoPosition: (\(place.place.geoPosition.latitude), \(place.place.geoPosition.longitude))")
                    }
                }
                .padding()
                .background(.white.opacity(0.8))
                .cornerRadius(10.0)
            }
        }
        .padding()
    }
}

#Preview {
    PlaceDetailView(place: .constant(nil))
}
