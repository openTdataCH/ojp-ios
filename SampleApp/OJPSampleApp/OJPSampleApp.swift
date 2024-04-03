//
//  OJPSampleApp.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import SwiftUI
import OJP
@main
struct OJPSampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView(content: {
                List {
                    NavigationLink {
                        LocationSearchByNameView()
                    } label: { Text("Station Search") }
                }
                VStack {
                    ZStack(alignment: .topLeading) {
                        Image("OpenTransportDataIcons")
                            .padding()
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
                    .background(.tint)
                    Spacer()
                    Text("Hello OJP!").font(.title)
                    Spacer()
                }
            })
        }
    }
}
