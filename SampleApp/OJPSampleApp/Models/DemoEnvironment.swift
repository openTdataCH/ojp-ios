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

    var id: String { rawValue }

    var title: String {
        switch self {
        case .int:
            "Integration"
        case .test:
            "Test"
        }
    }

    fileprivate var configuration: APIConfiguration {
        switch self {
        case .int:
            .int
        case .test:
            .test
        }
    }
}

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

extension OJP {
    static var configured: OJP {
        OJPHelper.ojp
    }
}
