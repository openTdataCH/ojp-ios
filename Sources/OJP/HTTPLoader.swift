//
//  HTTPLoader.swift
//
//
//  Created by Lehnherr Reto on 14.03.2024.
//

import Foundation

public struct HTTPLoader: Sendable {
    let configuration: APIConfiguration

    init(configuration: APIConfiguration) {
        self.configuration = configuration
    }

    @Sendable
    func load(request: Data) async throws -> (Data, URLResponse) {
        let session = URLSession.shared
        var urlRequest = baseRequest
        urlRequest.httpBody = request
        return try await session.data(for: urlRequest)
    }

    private var baseRequest: URLRequest {
        var urlRequest = URLRequest(url: configuration.apiEndPoint)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")

        if let headers = configuration.additionalHeaders {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        return urlRequest
    }
}
