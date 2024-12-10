# Using Mock Data

``OJP`` has a simple ``LoadingStrategy`` to mock response data in unit tests and to help when integrating Open Journey Planner in an app.

## Basic Concept

``LoadingStrategy/mock(_:)`` can be used to return a mocked response instead of triggering a http request to the OJP API.

## Sample Usage

``` swift
actor OJPMocker {
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
```
