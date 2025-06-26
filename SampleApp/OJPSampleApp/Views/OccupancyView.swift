//
//  OccupancyView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 26.06.2025.
//
import OJP
import SwiftUI

struct OccupancyView: View {
    let expectedOccupancy: ExpectedOccupancy

    var body: some View {
        HStack {
            if let level = expectedOccupancy.expectedFirstClassOccupancy {
                Text("1")
                level.icon
            }
            if let level = expectedOccupancy.expectedSecondClassOccupancy {
                Text("2")
                level.icon
            }
        }
    }
}
