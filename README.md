# Open Journey Planner SDK for iOS

## Overview

This SDK is targeting iOS applications seeking to integrate [Open Journey Planner(OJP) APIs](https://opentdatach.github.io/ojp-ios/documentation/ojp/) to support distributed journey planning according to the European (CEN) Technical Specification entitled “Intelligent transport systems – Public transport – Open API for distributed journey planning”

### Features

Available APIs
- [Location Information Request](https://opentransportdata.swiss/en/cookbook/location-information-service/)

Soon to be available
- [Stop 
Event Request](https://opentransportdata.swiss/en/cookbook/ojp-stopeventservice/)
- [Trip Request](https://opentransportdata.swiss/en/cookbook/ojptriprequest/)
- [TripInfo Request](https://opentransportdata.swiss/en/cookbook/ojptripinforequest/)

## Requirements

- Compatible with: iOS 15+ or macOS 14+

## Installation

- The SDK can be integrated into your Xcode project using the Swift Package Manager. To do so, just add the package by using the following url
```
https://github.com/openTdataCH/ojp-ios.git
```

## Usage

### Initializing
- endpoints configuration
- requestor Ref
- authBearerKey - where to get it from

```
import OJP

let ojpSdk = OJP(loadingStrategy: .http(.init(apiEndPoint: "your end_point", requestReference: "your request reference", authBearerKey:"your token")))
        

```

### Basic Usage

Get a list of Locations from a keyword.

```
import OJP


let searchedLocations = try await ojpSdk.requestLocations(from: "Bern")
                   

```


Get a list of Locations around a place with longitude and latitude

```
import OJP

let nearbyLocations = try await ojpSdk.requestLocations(from: Point(long: 5.6, lat: 2.3))
                           

```


- link to a sample app repo (later)

## Documentation

- [Documentation of the iOS Library](https://opentdatach.github.io/ojp-ios/documentation/ojp/)
- run `format-code.sh` to execute swiftformat on the library
- TBA - public OJP methods doc?

## Contributing

Contributions are welcomed. Feel free to create an issue or a feature request, or fork the project and submit a pull request.

## License

MIT License, see [LICENSE](./LICENSE)

## Contact

Create an issue or contact [opentransportdata.swiss](https://opentransportdata.swiss/en/contact-2/)
