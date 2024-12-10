# Using Mock Data

``OJP`` has a special ``LoadingStrategy`` to mock response data in unit tests and to help when integrating Open Journey Planner in an app.

## Basic Concept

``LoadingStrategy/mock(_:)`` can be used to return a mocked response instead of triggering a http request to the OJP API. It needs a function of type  `(Data) async throws -> (Data, URLResponse)` that will return the mocked response. Input of the function is the request body created by the SDK. Normal mock cases will ignore that and just return the same response.

## Sample Usage

This sample shows a custom implementation, that loads xml files from the main Bundle.

``` swift
enum OJPMocker {
    static func loadXML(xmlFilename: String) throws -> Data {
        guard let path = Bundle.main.path(forResource: xmlFilename, ofType: "xml") else {
            throw NSError(domain: "Not Found", code: 1)
        }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }

    static func mockLoader(xmlFilename: String) -> LoadingStrategy {
        .mock { _ in
            do {
                let data = try loadXML(xmlFilename: xmlFilename)
                print("success!")
                return (data, mockedResponse(statusCode: 200))
            } catch {
                return (Data(), mockedResponse(statusCode: 500))
            }
        }
    }

    private static func mockedResponse(statusCode: Int) -> URLResponse {
        HTTPURLResponse(url: URL(string: "https://localhost")!, 
            statusCode: statusCode, 
            httpVersion: "1.0", 
            headerFields: [:]
        )!
    }
}

// usage of mock

let mockedOJP = OJP(
    loadingStrategy: Self.mockLoader(xmlFilename: xmlFileName)
)

let mockedResponse = try await mockedOJP
    .requestTripInfo(
        journeyRef: "", 
        operatingDayRef: ""
)
```
