//
//  PaginatedTripLoader.swift
//
//
//  Created by Lehnherr Reto on 01.07.2024.
//

import Foundation

/// A  convenience type to define a new TripRequest to be used in the ``PaginatedTripLoader``
public struct TripRequest {
    let from: OJPv2.PlaceRefChoice
    let to: OJPv2.PlaceRefChoice
    let via: [OJPv2.PlaceRefChoice]?
    var at: DepArrTime
    var params: OJPv2.TripParams

    public init(from: OJPv2.PlaceRefChoice, to: OJPv2.PlaceRefChoice, via: [OJPv2.PlaceRefChoice]? = nil, at: DepArrTime, params: OJPv2.TripParams) {
        self.from = from
        self.to = to
        self.via = via
        self.at = at
        self.params = params
    }
}

/// When executing a TripRequest a common use case is to load previous or next trips.
/// While OJP is stateless, this convience actor allows exactly that.
///
/// Execute an initital ``TripRequest`` using ``loadTrips(for:numberOfResults:)``.
/// To get previous trips to the currenlty loaded call ``loadPrevious()`` and ``loadNext()`` to get future trips.
public actor PaginatedTripLoader {
    private(set) var minDate: Date?
    private(set) var maxDate: Date?

    private var existingTripHashes: Set<Int> = Set()
    private var request: TripRequest?
    private let ojp: OJP

    public init(ojp: OJP) {
        self.ojp = ojp
    }

    private var pageSize: Int = 6

    /// Performs an initial  [TripRequest](https://vdvde.github.io/OJP/develop/index.html#OJPTripRequest)
    /// - Parameters:
    ///   - request: ``TripRequest`` is a conve
    ///   - numberOfResults: amount of results to be returned. Usually ``OJPv2/NumberOfResults/minimum(_:)`` should be used.
    /// - Returns: Results of the resuest in a ``OJPv2/TripDelivery``
    public func loadTrips(for request: TripRequest, numberOfResults: OJPv2.NumberOfResults = .minimum(6)) async throws -> OJPv2.TripDelivery {
        reset()

        switch numberOfResults {
        case let .before(amount), let .after(amount), let .minimum(amount):
            pageSize = amount
        }

        return try await load(request: request, numberOfResults: numberOfResults)
    }

    /// Based on the currently already loaded trip results, load the previous trips. Potential duplicates are filtered using  ``OJPv2/Trip/tripHash``.
    /// - Returns: new ``OJPv2/TripDelivery`` with ``OJPv2/NumberOfResults/before(_:)`` and the current lowest date as departure time.
    public func loadPrevious() async throws -> OJPv2.TripDelivery {
        guard var request, let minDate else {
            throw OJPSDKError.notImplemented()
        }
        request.at = .departure(minDate)
        return try await load(request: request, numberOfResults: .before(pageSize))
    }

    /// Based on the currently already loaded trip results, load the future trips. Potential duplicates are filtered using  ``OJPv2/Trip/tripHash``.
    /// - Returns: new ``OJPv2/TripDelivery`` with ``OJPv2/NumberOfResults/after(_:)`` and the current highest date as departure time.
    public func loadNext() async throws -> OJPv2.TripDelivery {
        guard var request, let maxDate else {
            throw OJPSDKError.notImplemented()
        }
        request.at = .departure(maxDate)
        return try await load(request: request, numberOfResults: .after(pageSize))
    }

    private func reset() {
        minDate = nil
        maxDate = nil
        existingTripHashes = []
    }

    private func load(request: TripRequest, numberOfResults: OJPv2.NumberOfResults) async throws -> OJPv2.TripDelivery {
        let updatedParams = OJPv2.TripParams(
            numberOfResults: numberOfResults,
            includeLegProjection: request.params.includeLegProjection,
            includeTurnDescription: request.params.includeTurnDescription,
            includeIntermediateStops: request.params.includeIntermediateStops,
            includeAllRestrictedLines: request.params.includeAllRestrictedLines,
            modeAndModeOfOperationFilter: request.params.modeAndModeOfOperationFilter
        )

        var tripDelivery = try await ojp.requestTrips(
            from: request.from,
            to: request.to,
            via: request.via,
            at: request.at,
            params: updatedParams
        )

        try Task.checkCancellation()
        self.request = request

        let filteredTripResults: [OJPv2.TripResult] = tripDelivery.tripResults
            .filter { $0.trip != nil } // TripSummary currently not supported
            .compactMap { tripResult in
                guard let trip = tripResult.trip else { return nil }
                let hash = trip.tripHash // de-duplicate trips based on tripHash
                guard !existingTripHashes.contains(hash) else {
                    return nil
                }
                existingTripHashes.insert(hash)

                if maxDate == nil || trip.startTime > maxDate! { maxDate = trip.startTime }
                if minDate == nil || trip.startTime < minDate! { minDate = trip.startTime }

                return tripResult
            }
        tripDelivery.tripResults = filteredTripResults
        return tripDelivery
    }
}
