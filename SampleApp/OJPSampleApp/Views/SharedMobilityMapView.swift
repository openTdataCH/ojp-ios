//
//  SharedMobilityMapView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 17.06.2026.
//

import MapKit
import OJP
import SwiftUI

extension CLLocationCoordinate2D {
    static let bärn: Self = .init(
        latitude: 46.9477398131804,
        longitude: 7.437753702448
    )
}

struct SharedMobilityMapView: View {

    @Environment(\.ojp) var ojp: OJP

    @State private var position: MapCameraPosition = .camera(.init(centerCoordinate: .bärn, distance: 100))

    @State var results: [OJPv2.PlaceResult] = []
    @State var selectetedPlace: OJPv2.PlaceResult?
    @State var currentTask: Task<Void, Never>?

    private var placeParam: OJPv2.PlaceParam {
        let placeType: [PlaceType] = []
        return OJPv2.PlaceParam(type: placeType, numberOfResults: 300, includePtModes: true, modeFilter: .init(personalModes: [.bicycle, .car]))
    }

    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
                ForEach($results) { $result in
                    Annotation(result.place.name.text, coordinate: result.geoPosition.coordinates) {
                        marker(for: result)
                        .onTapGesture {
                            selectetedPlace = result
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                if context.camera.distance < 10000 {
                    load(in: context.region)
                }
            }
            .onAppear {
                position = .camera(.init(centerCoordinate: .bärn, distance: 1000))
            }
            .sheet(item: $selectetedPlace,
                   onDismiss: {
                selectetedPlace = nil
            }
            ) { place in
                VStack(alignment: .leading) {
                    Button(action: { selectetedPlace = nil }) {
                        Image(systemName: "xmark")
                        Text("Close")
                    }
                    .padding([.top, .horizontal])
                    PlaceDetailView(placeResult: place)
                }
                .frame(minHeight: 360)
            }
        }
    }

    func load(in region: MKCoordinateRegion) {
        currentTask?.cancel()
        currentTask = Task {
            do {
                let coord = region.center
                let rectangle = OJPv2.Rectangle(
                    upperLeft: OJPv2.GeoPosition(
                        longitude: coord.longitude - (region.span.longitudeDelta / 2.0),
                        latitude: coord.latitude - (region.span.latitudeDelta / 2.0)
                    ),
                    lowerRight: OJPv2.GeoPosition(
                        longitude: coord.longitude + (region.span.longitudeDelta / 2.0),
                        latitude: coord.latitude + (region.span.latitudeDelta / 2.0)
                    )
                )
                var set = Set(results)
                set.formUnion(try await ojp.requestPlaceResults(in: rectangle, restrictions: placeParam))
                results = set.map(\.self)
            } catch {
                print(error)
            }
        }
    }

    @ViewBuilder
    private func marker(for result: OJPv2.PlaceResult) -> some View {
        let category = MapCategory(result.place)
        category
            .image
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(6)
            .background(category.color, in: Circle())
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
            .shadow(radius: 1)
    }
}

enum MapCategory {
    case sharing(SharingCategory)
    case other

    init(_ place: OJPv2.Place) {
        switch place.place {
        case .pointOfInterest(let pointOfInterest):
            if let category = pointOfInterest.sharingCategories.first {
                self = .sharing(category)
            } else {
                fallthrough
            }
        default:
            self = .other
        }
    }

    @ViewBuilder var image: some View {
        switch self {
        case .sharing(let sharingCategory):
            sharingCategory.image
        case .other:
            Image(systemName: "mappin")
        }
    }

    var color: Color {
        switch self {
        case .sharing(let sharingCategory):
            switch sharingCategory {
            case .escooter:
               .red
            case .bike:
               .blue
            case .car:
               .black
            case .chargingStation:
               .yellow
            }
        case .other:
            .blue
        }
    }
}


#Preview {
    SharedMobilityMapView()
}
