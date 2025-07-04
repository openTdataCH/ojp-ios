# Open Journey Planner SDK for iOS and macOS

[![swift version shield](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FopenTdataCH%2Fojp-ios%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/openTdataCH/ojp-ios) [![platforms shield](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FopenTdataCH%2Fojp-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/openTdataCH/ojp-ios)

## Overview

This SDK is enabling Swift applications to integrate [Open Journey Planner (OJP) V2 APIs](https://opentdatach.github.io/ojp-ios/documentation/ojp/) to support distributed journey planning according to the European (CEN) Technical Specification entitled “Intelligent transport systems – Public transport – Open API for distributed journey planning”.

For a general introduction to `OJP`, consult the [Cookbook](https://opentransportdata.swiss/de/cookbook/open-journey-planner-ojp/) on [opentransportdata.swiss](https://opentransportdata.swiss). Visit [vdvde.github.io/OJP](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html) for the documentation of the XML Schema of OJP.

🚧 Currently this SDK is **under construction.** Note that APIs may still change. 🚧

### Features

#### Available APIs

- [Location Information Request](https://opentransportdata.swiss/en/cookbook/location-information-service/)
- [Trip Request](https://opentransportdata.swiss/en/cookbook/ojptriprequest/)
- [TripInfo Request](https://opentransportdata.swiss/en/cookbook/ojptripinforequest/)
- [Stop Event Request](https://opentransportdata.swiss/en/cookbook/ojp-stopeventservice/)

## Requirements

- Compatible with: iOS 15+ and macOS 14+
- A valid API token for [OJP 2.0 on opentransportdata.swiss](https://opentransportdata.swiss/de/dataset/ojp2-0)

## Installation

The SDK can be integrated into your Xcode project using the Swift Package Manager. Add following dependency to your `Package.swift` or as a `Package Dependency` in Xcode: 

```swift
    .package(url: "`https://github.com/openTdataCH/ojp-ios.git", from: "1.0.0"),
```

## Usage

### Initializing

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

### Basic Usage

#### Get a list of `PlaceResult` from a keyword

``` swift
// get only stops
let stops = try await ojpSdk.requestPlaceResults(
    from: "Bern",
    restrictions: .init(type: [.stop])
)
        
// get stops and addresses
let addresses = try await ojpSdk.requestPlaceResults(from: "Bern", restrictions: .init(type: [.stop, .address]))
```

#### Get a List of PlaceResults around a Place using Longitude and Latitude

``` swift
let nearbyStops = try await ojpSdk.requestPlaceResults(
    from: Point(long: 5.6, lat: 2.3), 
    restrictions: .init(type: [.stop])
)
```

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

#### Update an existing Trip

``` swift
// in order to update a trip, you need to keep around the "original" `OJPv2.TripResult` or a `OJPv2.Trip`.

// example using `OJPv2.Trip`
let tripResult = OJPv2.TripResult(trip: trip)
let tripRefineDelivery = try await OJP.configured.requestTripRefinement(tripResult: tripResult)
```

For a more detailed introduction head over to the [Getting Started](https://opentdatach.github.io/ojp-ios/documentation/ojp/gettingstarted) article in the documentation.

## Sample App

There is an experimental [Sample App](./SamplApp) to showcase and test the SDK. Currently intended to be run as a macOS app.

## Documentation

- [Documentation of the Swift Library](https://opentdatach.github.io/ojp-ios/documentation/ojp/)
- run `format-code.sh` to execute swiftformat on the library

## Releases

See [Releases](https://github.com/openTdataCH/ojp-ios/releases) for the history of all current releases.

### How To Release A New Version

A new release can be prepared by creating and pushing a `release/X.X.X` branch. Where `X.X.X` is the semantic version of the release. As soon as this is pushed the [prepare_release.yml](https://github.com/openTdataCH/ojp-ios/actions/workflows/prepare_release.yml) workflow will:

1. update the `Version.swift` file
1. tag the release
1. open a new PR for this release

After this PR is approved and merged the [draft_release.yml](https://github.com/openTdataCH/ojp-ios/blob/main/.github/workflows/draft_release.yml) workflow will draft a Github release. 

### Used Standards

- [OJP - Open API for distributed Journey Planning (vdvde.github.io/OJP/develop)](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html)
- [SIRI-SX/VDV736](https://www.oev-info.ch/de/branchenstandard/technische-standards/ereignisdaten) -> [realization_guide_siri-sx_oev_schweiz_v1.0.pdf](https://www.oev-info.ch/sites/default/files/2024-07/realization_guide_siri-sx_oev_schweiz_v1.0.pdf)

## Contributing

Contributions are welcomed. Feel free to create an issue or a feature request, or fork the project and submit a pull request.

## License

MIT License, see [LICENSE](./LICENSE)

## Contact

Create an issue or contact [opentransportdata.swiss](https://opentransportdata.swiss/en/contact-2/)
