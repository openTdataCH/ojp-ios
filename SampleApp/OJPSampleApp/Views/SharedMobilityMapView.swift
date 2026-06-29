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

    @State var currentRegion: MKCoordinateRegion?

    @State private var tooZoomedOut = false

    @State private var showCars = true
    @State private var showBicycles = true
    @State private var showScooters = true

    private let maxQueryableSpan = 0.25


    private var modes: [OJPv2.PersonalMode] {
        var modes: [OJPv2.PersonalMode] = []
        if showBicycles {
            modes.append(.bicycle)
        }
        if showScooters {
            modes.append(.scooter)
        }
        if showCars {
            modes.append(.car)
        }
        return modes
    }

    private var placeParam: OJPv2.PlaceParam {
        return OJPv2.PlaceParam(type: [], numberOfResults: 300, includePtModes: true, modeFilter: .init(personalModes: modes))
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
                currentRegion = context.region
                load(in: context.region)
            }
            .onAppear {
                position = .camera(.init(centerCoordinate: .bärn, distance: 1000))
            }
            .onChange(of: [showCars, showBicycles, showScooters]) {
                if let currentRegion {
                    load(in: currentRegion)
                }
            }
            .overlay(alignment: .topTrailing) { filterMenu.padding() }
            .overlay(alignment: .bottomLeading) {
                if let selectetedPlace {
                    VStack(alignment: .leading) {
                        Button(action: { self.selectetedPlace = nil }) {
                            Image(systemName: "xmark")
                            Text("Close")
                        }
                        .padding([.top, .horizontal])
                        PlaceDetailView(placeResult: selectetedPlace)
                    }
                    .frame(maxWidth: 300, maxHeight: 360)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    func load(in region: MKCoordinateRegion) {
        guard region.span.latitudeDelta <= maxQueryableSpan, region.span.longitudeDelta <= maxQueryableSpan else {
            tooZoomedOut = true
            results = []
            return
        }
        tooZoomedOut = false
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

    private var filterMenu: some View {
        Menu {
            Toggle("Shared Cars", isOn: $showCars)
            Toggle("Shared Bicycles", isOn: $showBicycles)
            Toggle("Shared Scooters", isOn: $showScooters)
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.title2)
                .padding(8)
                .background(.regularMaterial, in: Circle())
            if modes.isEmpty {
                Text("No Categories selected")
            } else {
                Text(modes.map(\.rawValue).joined(separator: ", "))
            }
        }
        .menuStyle(.button)
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
