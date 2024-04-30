//
//  OJPSDKError.swift
//
//
//  Created by Lehnherr Reto on 15.03.2024.
//

import Foundation

/// ``OJPError`` describes errors that can occur when using the SDK. It is not equivalent to [OJPError](https://vdvde.github.io/OJP/develop/index.html#OJPError) that defines a sequence of OJP related problems.
enum OJPSDKError: Error {
    /// Used as a placeholder for features, that are not finished implementing
    case notImplemented
    /// A failure occured, while trying to access the resource
    case loadingFailed(URLError)
    /// When a response status code is not `200` this error is thrown
    case unexpectedHTTPStatus(Int)
    /// A response is missing a required element. Eg. no `serviceDelivery` is present
    case unexpectedEmpty
    /// Issue when trying to generate a request xml
    case encodingFailed
    /// Can't correctly decode a XML response
    case decodingFailed(Error)
}
