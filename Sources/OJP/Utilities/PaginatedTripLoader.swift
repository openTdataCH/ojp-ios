//
//  PaginatedTripLoader.swift
//
//
//  Created by Lehnherr Reto on 01.07.2024.
//

import Foundation

/// A  convenience type to define a new TripRequest to be used in the ``PaginatedTripLoader``
public struct TripRequest: Codable, Sendable {
    public let from: OJPv2.PlaceRefChoice
    public let to: OJPv2.PlaceRefChoice
    public let via: [OJPv2.PlaceRefChoice]?
    public internal(set) var at: DepArrTime
    public internal(set) var params: OJPv2.TripParams

    public init(from: OJPv2.PlaceRefChoice, to: OJPv2.PlaceRefChoice, via: [OJPv2.PlaceRefChoice]? = nil, at: DepArrTime, params: OJPv2.TripParams) {
        self.from = from
        self.to = to
        self.via = via
        self.at = at
        self.params = params
    }
}

/// When executing a TripRequest a common use case is to load previous or next trips.
/// While OJP is stateless, this convience actor keeps track of the already loaded TripResults by remembering the highest and lowest ``OJPv2/Trip/startTime`` and a `et` of  ``OJPv2/Trip/tripHash``.
///
/// Execute an initital ``TripRequest`` using ``loadTrips(for:numberOfResults:)``.
/// To retrieve previous trips use ``loadPrevious()`` and ``loadNext()`` to get future trips. The `Set` of trip hashes is used to avoid duplicates. Each call only returns new results.
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

    /// Performs the initial  [TripRequest](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__OJPTripRequest) resetting the internal state.
    /// - Parameters:
    ///   - request: ``TripRequest`` is a conve
    ///   - numberOfResults: amount of results to be returned. Usually ``OJPv2/NumberOfResults/minimum(_:)`` should be used. The associated value is reused as a page size in ``loadNext()`` and ``loadPrevious()``
    /// - Returns: ``OJPv2/TripDelivery`` containing the ``OJPv2/TripResult``
    public func loadTrips(for request: TripRequest, numberOfResults: OJPv2.NumberOfResults = .standard(6)) async throws -> OJPv2.TripDelivery {
        reset()

        switch numberOfResults {
        case let .numbers(before: before, after: after):
            pageSize = before + after
        case let .standard(amount):
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
        return try await load(request: request, numberOfResults: .numbers(before: pageSize, after: 0))
    }

    /// Based on the currently already loaded trip results, load the future trips. Potential duplicates are filtered using  ``OJPv2/Trip/tripHash``.
    /// - Returns: new ``OJPv2/TripDelivery`` with ``OJPv2/NumberOfResults/after(_:)`` and the current highest date as departure time.
    public func loadNext() async throws -> OJPv2.TripDelivery {
        guard var request, let maxDate else {
            throw OJPSDKError.notImplemented()
        }
        request.at = .departure(maxDate)
        return try await load(request: request, numberOfResults: .numbers(before: 0, after: pageSize))
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
            useRealtimeData: request.params.useRealtimeData,
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
