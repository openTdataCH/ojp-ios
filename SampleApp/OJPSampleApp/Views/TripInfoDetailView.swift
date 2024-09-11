//
//  TripInfoDetailView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 09.09.2024.
//

import OJP
import SwiftUI

struct TripInfoDetailView: View {
    var tripInfo: OJPv2.TripInfoResult

    var body: some View {
        ScrollView {
            HStack {
                if let service = tripInfo.service {
                    Text(service.publishedServiceName.text)
                    if let destination = service.destinationText?.text {
                        Text("→ \(destination)")
                    }
                } else {
                    Text("No Service Information on TripInfo")
                }
            }
            .bold()
            Divider()
            let previousCalls = tripInfo.previousCalls
            ForEach(previousCalls, id: \.hashValue) {
                call in
                StopView(arrivalTime: call.serviceArrival?.arrivalTime, departureTime: call.serviceDeparture?.departureTime, stopCallStatus: call.stopCallStatus, stopPointName: call.stopPointName, isPrevious: true)
            }.foregroundColor(.gray)
            
            Divider()
            let onwardCalls = tripInfo.onwardCalls 
            ForEach(onwardCalls, id: \.hashValue) {
                call in
                StopView(arrivalTime: call.serviceArrival?.arrivalTime, departureTime: call.serviceDeparture?.departureTime, stopCallStatus: call.stopCallStatus, stopPointName: call.stopPointName)
            }
            
        }
    }
}

struct StopView: View {
    var arrivalTime: StationTime?
    var departureTime: StationTime?
    var stopCallStatus: OJPv2.StopCallStatus
    let stopPointName: OJPv2.InternationalText
    var isPrevious: Bool = false

    private var labelColor: Color { isPrevious ? .gray : .label }

    var body: some View {
        VStack(spacing: 0) {
            if let arrivalTime {
                HStack {
                    Text(arrivalTime.timetabled.formatted(date: .omitted, time: .shortened))
                    Text(arrivalTime.hasDelay ? arrivalTime.delay.formattedDelay : "").foregroundStyle(.red)
                    Spacer()
                }
                .offset(x: 10)
            }
            HStack(spacing: 4) {
                Circle()
                    .frame(width: 6, height: 6)
                if let departureTime {
                    Text(departureTime.timetabled.formatted(date: .omitted, time: .shortened)).bold()
                    Text(departureTime.hasDelay ? departureTime.delay.formattedDelay : "").foregroundStyle(.red)
                }
                VStack {
                    Text(stopPointName.text).bold()
                    if stopCallStatus.unplannedStop {
                        Text("Unplanned Stop")
                    }
                }
                Spacer()
            }
        }.foregroundStyle(stopCallStatus.notServicedStop ? .red : labelColor)
    }
}

#Preview {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadLoadTripInfo(xmlFileName: "tir")
        },
        content: { tripInfoDelivery in
            if let trip = tripInfoDelivery.tripInfoResult {
                TripInfoDetailView(tripInfo: trip)
            } else {
                Text("No Trip")
            }
        }
    )
}
