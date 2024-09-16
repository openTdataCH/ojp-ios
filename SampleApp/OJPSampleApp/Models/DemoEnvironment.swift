//
//  DemoEnvironment.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.05.2024.
//

import Foundation
import OJP

import SwiftUI

enum DemoEnvironment: String, CaseIterable, Identifiable {
    case int
    case test
    case prod

    var id: String { rawValue }

    var title: String {
        switch self {
        case .int:
            "Integration"
        case .test:
            "Test"
        case .prod:
            "Production"
        }
    }

    @MainActor
    fileprivate var configuration: APIConfiguration {
        switch self {
        case .int:
            .int
        case .test:
            .test
        case .prod:
            APIConfiguration(apiEndPoint: URL(string: "https://api.opentransportdata.swiss/ojp20")!, requesterReference: "BLS_DemoApp", additionalHeaders: ["Authorization": "Bearer eyJvcmciOiI2NDA2NTFhNTIyZmEwNTAwMDEyOWJiZTEiLCJpZCI6Ijk0YTFhNjExYjM5ZjQ4MWNiMGI5MjFiNTgyNmM1ZGFjIiwiaCI6Im11cm11cjEyOCJ9"])
        }
    }
}

@MainActor
struct OJPHelper {
    @AppStorage("DemoEnvironment") var environment: DemoEnvironment = .int
    static var ojp: OJP {
        .init(loadingStrategy: .http(environment.configuration))
    }

    private static var environment: DemoEnvironment {
        guard let envString = UserDefaults.standard.string(forKey: "DemoEnvironment"), let environment = DemoEnvironment(rawValue: envString) else {
            return .int
        }
        return environment
    }
}
