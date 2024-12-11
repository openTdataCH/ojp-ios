# Getting Started

A basic introduction in how to use the APIs exposed by the SDK.

## Sample App

There is an experimental [Sample App](./SamplApp) to showcase and test the SDK. Currently intended to be run as a macOS app.

## Initializing

``` swift
import OJP

let apiConfiguration = APIConfiguration(
    apiEndPoint: URL(string: "your api endpoint")!, 
    requesterReference: "your request reference", 
    additionalHeaders: [
        "Authorization": "Bearer yourBearerToken"
        ]
)

let ojpSdk = OJP(
    loadingStrategy: .http(apiConfiguration),
    language: "de" // optional ISO language code. Defaults to the preferred localization. 
)
```

## LocationInformationRequest

#### Get Stops matching to a keyword

``` swift     
let stops = try await ojpSdk.requestPlaceResults(
    from: "Bern",
    restrictions: .init(type: [.stop])
)
```

#### Get Stops and Addresses matching to a keyword

``` swift        
let addresses = try await ojpSdk.requestPlaceResults(
    from: "Bern", 
    restrictions: .init(type: [.stop, .address])
)
```

### Get a List of Stops nearby a Coordinate

``` swift
let nearbyStops = try await ojpSdk.requestPlaceResults(
    from: Point(long: 5.6, lat: 2.3), 
    restrictions: .init(type: [.stop])
)
```

## TripInformationRequest 

#### Get a List of Trips between two Places

``` swift
let origin = try await ojpSdk.requestPlaceResults(
    from: "Bern", 
    restrictions: .init(type: [.stop])
).first!

let via = try await ojpSdk.requestPlaceResults(
    from: "Luzern", 
    restrictions: .init(type: [.stop])
).first!

let destination = try await ojpSdk.requestPlaceResults(
    from: "Zurich HB", 
    restrictions: .init(type: [.stop])
).first!

let tripDelivery = try await ojp.requestTrips(
    from: origin.placeRef, 
    to: destination.placeRef, 
    via: via.placeRef,
    params: .init(
        includeTrackSections: true, 
        includeIntermediateStops: true
    )
)
```

#### Use PaginatedTripLoader to load previous and upcoming TripResults

``PaginatedTripLoader`` is a convenience actor to allow paginated trip Results.

``` swift
// create a new PaginatedTripLoader
let paginatedActor = PaginatedTripLoader(ojp: ojp)

// load the initial trips
let tripRequest = TripRequest(
    from: origin.placeRef,
    to: destination.placeRef,
    via: via != nil ? [via!.placeRef] : nil,
    at: .departure(Date()),
    params: .init(
        includeTrackSections: true,
        includeIntermediateStops: true
    )
)
let tripDelivery = try await paginatedActor.loadTrips(
    for: tripRequest,
    numberOfResults: .minimum(6)
)
let tripResults = tripDelivery.tripResults

// load previous TripResults
let previousTripResults = try await paginatedActor
    .loadPrevious()
    .tripResults

// load future TripResults
let nextTripResults = try await paginatedActor
    .loadPrevious()
    .tripResults
```

#### Load informations to a trip using `TripInformationRequest`

``` swift
let journeyRef = timedLeg.service.journeyRef
let operatingDayRef = timedLeg.service.operatingDayRef

let tripInfo = try await OJP.configured.requestTripInfo(
    journeyRef: journeyRef,
    operatingDayRef: operatingDayRef,
    params: .init(useRealTimeData: .explanatory)
)
```

#### Load current departures using `StopEventRequest`

``` swift
let stopEventDelivery = try await ojp.requestStopEvent(
    location: .init(
        placeRef: origin.placeRef,
        depArrTime: nil
    ),
    params: .init(
        stopEventType: .departure,
        numberOfResults: 15
    )
)

// if the requests `OJPv2.PlaceContext` is not of type `.stopPlace` or `.stopPoint`, it can return departures of multiple nearby Stops
let groupedStopEvents: [String: [OJPv2.StopEventResult]] = stopEventDelivery.stopEventsGroupedByStation
let ptSituations = stopEventDelivery.ptSituations

// otherwise you can directly reference the stopEventResults
let stops = stopEventDelivery.stopEventResult
```
