//
//  HTTPLoader.swift
//
//
//  Created by Lehnherr Reto on 14.03.2024.
//

import Foundation

public class HTTPLoader {
    let configuration: APIConfiguration

    init(configuration: APIConfiguration) {
        self.configuration = configuration
    }

    func load(request: Data) async throws -> (Data, URLResponse) {
        let session = URLSession.shared
        var urlRequest = baseRequest
        urlRequest.httpBody = request
        return try await session.data(for: urlRequest)
    }

    private var baseRequest: URLRequest {
        let url = URL(string: configuration.apiEndPoint)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        if let authBearerKey = configuration.accessToken {
            urlRequest.addValue("Bearer \(authBearerKey)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")

        if let headers = configuration.additionalHeaders {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        return urlRequest
    }
}
