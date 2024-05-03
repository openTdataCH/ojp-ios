//
//  OJPSDKError.swift
//
//
//  Created by Lehnherr Reto on 15.03.2024.
//

import Foundation

/// ``OJPError`` describes errors that can occur when using the SDK. It is not equivalent to [OJPError](https://vdvde.github.io/OJP/develop/index.html#OJPError) that defines a sequence of OJP related problems.
enum OJPSDKError: LocalizedError {
    /// Used as a placeholder for features, that are not finished implementing
    case notImplemented(_ file: StaticString = #file, _ line: UInt = #line)
    /// A failure occured, while trying to access the resource
    case loadingFailed(URLError)
    /// When a response status code is != `200` this error is thrown
    case unexpectedHTTPStatus(Int)
    /// A response is missing a required element. Eg. no `serviceDelivery` is present
    case unexpectedEmpty
    /// Issue when trying to generate a request xml
    case encodingFailed
    /// Can't correctly decode a XML response
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notImplemented(let file, let line):
            "Method not Implemented in File \(file):\(line)"
        case .unexpectedHTTPStatus(let int):
            "Unexpected HTTP status code: \(int)"
        case .unexpectedEmpty:
            "Unexpeced Empty"
        case .encodingFailed:
            "Encoding Failed"
        case .loadingFailed(let error):
            "Loading Failed due to URLError: \(error.localizedDescription)"
        case .decodingFailed(let error):
            "Decoding Failed due to: \(error.localizedDescription)"
        }
    }
}
