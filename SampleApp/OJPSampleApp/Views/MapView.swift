//
//  MapView.swift
//  OJPSampleApp
//
//  Created by Claude on 19.06.2026.
//

import MapKit
import OJP
import SwiftUI

/// Shows public transport stations and shared mobility (shared cars, bicycles and scooters)
/// for the currently visible map area, similar to the OJP demo app.
struct MapView: View {
    let ojp: OJP

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.3782, longitude: 8.5402),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )

    @State private var results: [OJPv2.PlaceResult] = []
    @State private var selected: OJPv2.PlaceResult?
    @State private var currentRegion: MKCoordinateRegion?
    @State private var currentTask: Task<Void, Never>?
    @State private var isLoading = false
    @State private var tooZoomedOut = false

    // Filters
    @State private var showStations = true
    @State private var showCars = true
    @State private var showBicycles = true
    @State private var showScooters = true

    /// Maximum results requested per category for a single bounding box request.
    private let maxResultsPerCategory = 100
    /// Above this span (in degrees) we don't query, to avoid huge responses.
    private let maxQueryableSpan = 0.25

    var body: some View {
        Map(position: $position) {
            ForEach(filteredResults) { result in
                Annotation(result.place.name.text, coordinate: result.geoPosition.coordinates) {
                    marker(for: result)
                        .onTapGesture { selected = result }
                }
            }
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            currentRegion = context.region
            scheduleFetch(for: context.region)
        }
        .overlay(alignment: .top) { statusBar }
        .overlay(alignment: .topTrailing) { filterMenu.padding() }
        .overlay(alignment: .bottomLeading) {
            if selected != nil {
                detailPanel
            }
        }
        .onChange(of: [showStations, showCars, showBicycles, showScooters]) {
            if let currentRegion {
                scheduleFetch(for: currentRegion)
            }
        }
    }

    // MARK: - Subviews

    private var statusBar: some View {
        Group {
            if tooZoomedOut {
                Label("Zoom in to load places", systemImage: "minus.magnifyingglass")
            } else if isLoading {
                Label("Loading…", systemImage: "arrow.triangle.2.circlepath")
            } else {
                Text("\(filteredResults.count) places")
            }
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: Capsule())
        .padding(.top, 8)
    }

    private var filterMenu: some View {
        Menu {
            Toggle("Stations", isOn: $showStations)
            Toggle("Shared Cars", isOn: $showCars)
            Toggle("Shared Bicycles", isOn: $showBicycles)
            Toggle("Shared Scooters", isOn: $showScooters)
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.title2)
                .padding(8)
                .background(.regularMaterial, in: Circle())
        }
        .menuStyle(.button)
    }

    private var detailPanel: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Button {
                selected = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding([.top, .trailing], 8)

            PlaceDetailView(place: $selected)
        }
        .frame(maxWidth: 300, maxHeight: 360)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding()
    }

    @ViewBuilder
    private func marker(for result: OJPv2.PlaceResult) -> some View {
        let category = result.mapCategory
        Image(systemName: symbol(for: category))
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(6)
            .background(color(for: category), in: Circle())
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
            .shadow(radius: 1)
    }

    // MARK: - Category styling

    private func symbol(for category: OJPv2.MapPlaceCategory?) -> String {
        switch category {
        case .station: "tram.fill"
        case .sharedCar: "car.fill"
        case .sharedBicycle: "bicycle"
        case .sharedScooter: "scooter"
        case nil: "mappin"
        }
    }

    private func color(for category: OJPv2.MapPlaceCategory?) -> Color {
        switch category {
        case .station: .blue
        case .sharedCar: .green
        case .sharedBicycle: .orange
        case .sharedScooter: .purple
        case nil: .gray
        }
    }

    // MARK: - Filtering

    private var filteredResults: [OJPv2.PlaceResult] {
        results.filter { result in
            switch result.mapCategory {
            case .station: showStations
            case .sharedCar: showCars
            case .sharedBicycle: showBicycles
            case .sharedScooter: showScooters
            case nil: false
            }
        }
    }

    // MARK: - Fetching

    /// Builds the list of `PlaceParam` requests for the currently enabled filters.
    /// Stations use a `stop` type restriction, shared mobility uses a `PersonalMode` restriction.
    /// All enabled shared mobility modes are combined into a single request — the service returns
    /// every personal mode passed in `Modes` at once. Stations can't be combined with `Modes`
    /// (the mode filter overrides `Type=stop`), so at most two requests are issued.
    private func placeParams() -> [OJPv2.PlaceParam] {
        var params: [OJPv2.PlaceParam] = []
        if showStations {
            params.append(.init(type: [.stop], numberOfResults: maxResultsPerCategory, includePtModes: true))
        }
        var personalModes: [OJPv2.PersonalMode] = []
        if showCars { personalModes.append(.car) }
        if showBicycles { personalModes.append(.bicyle) }
        if showScooters { personalModes.append(.scooter) }
        if !personalModes.isEmpty {
            params.append(.init(type: [], numberOfResults: maxResultsPerCategory, includePtModes: false, modes: OJPv2.PersonalModeFilter(personalModes: personalModes)))
        }
        return params
    }

    private func scheduleFetch(for region: MKCoordinateRegion) {
        currentTask?.cancel()

        guard region.span.latitudeDelta <= maxQueryableSpan, region.span.longitudeDelta <= maxQueryableSpan else {
            tooZoomedOut = true
            results = []
            return
        }
        tooZoomedOut = false

        let bbox = region.ojpBbox
        let params = placeParams()
        guard !params.isEmpty else {
            results = []
            return
        }

        let ojp = self.ojp
        currentTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
                isLoading = true
                defer { isLoading = false }

                let merged = try await Self.fetch(ojp: ojp, bbox: bbox, params: params)
                guard !Task.isCancelled else { return }
                results = dedupe(merged)
            } catch is CancellationError {
                // a newer fetch superseded this one
            } catch {
                print("Map fetch failed: \(error)")
            }
        }
    }

    /// Runs all category requests concurrently and returns the merged results.
    private static func fetch(ojp: OJP, bbox: Geo.Bbox, params: [OJPv2.PlaceParam]) async throws -> [OJPv2.PlaceResult] {
        let minX = bbox.minX, minY = bbox.minY, maxX = bbox.maxX, maxY = bbox.maxY
        return try await withThrowingTaskGroup(of: [OJPv2.PlaceResult].self) { group in
            for param in params {
                group.addTask {
                    let box = Geo.Bbox(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
                    return try await ojp.requestPlaceResults(bbox: box, restrictions: param)
                }
            }
            var all: [OJPv2.PlaceResult] = []
            for try await chunk in group {
                all.append(contentsOf: chunk)
            }
            return all
        }
    }

    private func dedupe(_ results: [OJPv2.PlaceResult]) -> [OJPv2.PlaceResult] {
        var seen = Set<String>()
        return results.filter { seen.insert($0.id).inserted }
    }
}

private extension MKCoordinateRegion {
    /// Converts the visible region into an OJP bounding box.
    var ojpBbox: Geo.Bbox {
        let minLatitude = center.latitude - span.latitudeDelta / 2
        let maxLatitude = center.latitude + span.latitudeDelta / 2
        let minLongitude = center.longitude - span.longitudeDelta / 2
        let maxLongitude = center.longitude + span.longitudeDelta / 2
        return Geo.Bbox(minLongitude: minLongitude, minLatitude: minLatitude, maxLongitude: maxLongitude, maxLatitude: maxLatitude)
    }
}

#Preview {
    MapView(ojp: OJP.configured)
}
