# Open Journey Planner SDK for iOS

## Overview

This SDK is targeting iOS applications seeking to integrate [Open Journey Planner(OJP) APIs](https://opentdatach.github.io/ojp-ios/documentation/ojp/) to support distributed journey planning according to the European (CEN) Technical Specification entitled “Intelligent transport systems – Public transport – Open API for distributed journey planning”.

Currently the SDK is under construction, so there is not yet a stable version and the APIs may change.

### Features

#### Available APIs

- [Location Information Request](https://opentransportdata.swiss/en/cookbook/location-information-service/)

### Soon to be available

- [Stop Event Request](https://opentransportdata.swiss/en/cookbook/ojp-stopeventservice/)
- [Trip Request](https://opentransportdata.swiss/en/cookbook/ojptriprequest/)
- [TripInfo Request](https://opentransportdata.swiss/en/cookbook/ojptripinforequest/)

## Requirements

- Compatible with: iOS 15+ and macOS 14+

## Installation

- The SDK can be integrated into your Xcode project using the Swift Package Manager. To do so, just add the package by using the following: `https://github.com/openTdataCH/ojp-ios.git`

## Usage

### Initializing

TBA
- endpoints configuration
- requesterReference
- authBearerToken - where to get it from

``` swift
import OJP

let apiConfiguration = APIConfiguration(
    apiEndPoint: URL(string: "your api endpoint")!, 
    requesterReference: "your request reference", 
    additionalHeaders: [
        "Authorization": "Bearer yourBearerToken"
        ]
    )

let ojpSdk = OJP(loadingStrategy: .http(apiConfiguration))
```

### Basic Usage

Get a list of PlaceResults from a keyword.

``` swift
import OJP
        
// get only stops
let stops = try await ojpSdk.requestPlaceResults(from: "Bern", restrictions: .init(type: [.stop]))


        
// get stops and addresses
let addresses = try await ojpSdk.requestPlaceResults(from: "Bern", restrictions: .init(type: [.stop, .address]))
```

Get a list of PlaceResults around a place with longitude and latitude

``` swift
import OJP

let nearbyStops = try await ojpSdk.requestPlaceResults(from: Point(long: 5.6, lat: 2.3), restrictions: .init(type: [.stop])
```

## Sample App

WIP: on branch [demo-app](https://github.com/openTdataCH/ojp-ios/tree/demo-app)

## Documentation

- [Documentation of the iOS Library](https://opentdatach.github.io/ojp-ios/documentation/ojp/)
- run `format-code.sh` to execute swiftformat on the library

## Contributing

Contributions are welcomed. Feel free to create an issue or a feature request, or fork the project and submit a pull request.

## License

MIT License, see [LICENSE](./LICENSE)

## Contact

Create an issue or contact [opentransportdata.swiss](https://opentransportdata.swiss/en/contact-2/)
