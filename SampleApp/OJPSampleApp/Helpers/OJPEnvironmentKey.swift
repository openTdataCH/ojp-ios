//
//  OJPEnvironmentKey.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 17.06.2026.
//
import OJP
import SwiftUI


struct OJPEnvironmentKey: @MainActor EnvironmentKey {
    @MainActor static let defaultValue = OJP(loadingStrategy: .http(.int))
}

@MainActor extension EnvironmentValues {
    var ojp: OJP {
        get { self[OJPEnvironmentKey.self] }
        set { self[OJPEnvironmentKey.self] = newValue }
    }
}
