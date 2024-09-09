//
//  TripDetailView.swift
//  OJPSampleApp
//
//  Created by Terence Alberti on 01.07.2024.
//

import OJP
import SwiftUI

struct TripDetailView: View {
    let trip: OJPv2.Trip
    let ptSituations: [OJPv2.PTSituation]

    @State var selectedPTSituation: OJPv2.PTSituation?
    @State var selectedTripInfo: OJPv2.TripInfoResult?

    var body: some View {
        VStack {
            if trip.tripStatus.hasIssue {
                TripStatusLabel(tripStatus: trip.tripStatus)
            }

            List(trip.legs) { leg in
                switch leg.legType {
                case let .timed(timedLeg):
                    VStack(alignment: .leading) {
                        Divider()
                        HStack {
                            Text(timedLeg.service.publishedServiceName.text)
                            if let destination = timedLeg.service.destinationText?.text {
                                Text("→ \(destination)")
                            }
                            Button("Load TripInfo") {
                                Task {
                                    do {
                                        selectedTripInfo = try await OJP.configured.requestTripInfo(
                                            journeyRef: timedLeg.service.journeyRef,
                                            operatingDayRef: timedLeg.service.operatingDayRef,
                                            params: .init(useRealTimeData: .explanatory)
                                        ).tripInfoResult
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
                        .bold()
                        Divider()
                        HStack {
                            let legBoard = timedLeg.legBoard
                            let timetabledTime = legBoard.serviceDeparture.timetabledTime
                            let estimatedTime = legBoard.serviceDeparture.estimatedTime
                            let changedTrack = legBoard.estimatedQuay != nil && legBoard.estimatedQuay!.text != legBoard.plannedQuay?.text
                            Text(timetabledTime.formatted())
                            if let estimatedTime {
                                let delay = estimatedTime.timeIntervalSince(timetabledTime).formattedDelay
                                Text(delay).foregroundStyle(.red)
                            }
                            Text(legBoard.stopPointName.text).bold()
                            Text(legBoard.estimatedQuay?.text ?? legBoard.plannedQuay?.text ?? "")
                                .foregroundStyle(changedTrack ? .red : Color.label)
                        }.foregroundColor(timedLeg.legBoard.stopCallStatus.notServicedStop ? .red : .label)
                        VStack(spacing: 4) {
                            ForEach(timedLeg.legsIntermediate) { legIntermediate in
                                VStack(spacing: 0) {
                                    if let arrivalTime = legIntermediate.serviceArrival?.arrivalTime {
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
                                        if let departureTime = legIntermediate.serviceDeparture?.departureTime {
                                            Text(departureTime.timetabled.formatted(date: .omitted, time: .shortened))
                                            Text(departureTime.hasDelay ? departureTime.delay.formattedDelay : "").foregroundStyle(.red)
                                        }
                                        Text(legIntermediate.stopPointName.text)
                                        Spacer()
                                    }
                                }.foregroundStyle(legIntermediate.stopCallStatus.notServicedStop ? .red : Color.label)
                            }
                        }
                        .padding(.vertical, 2)
                        HStack {
                            let legAlight = timedLeg.legAlight
                            let timetabledTime = legAlight.serviceArrival.timetabledTime
                            let estimatedTime = legAlight.serviceArrival.estimatedTime
                            let changedTrack = legAlight.estimatedQuay != nil && legAlight.estimatedQuay!.text != legAlight.plannedQuay?.text
                            Text(timetabledTime.formatted())
                            if let estimatedTime {
                                let delay = estimatedTime.timeIntervalSince(timetabledTime).formattedDelay
                                Text(delay).foregroundStyle(.red)
                            }
                            Text(timedLeg.legAlight.stopPointName.text).bold()
                            Text(legAlight.estimatedQuay?.text ?? legAlight.plannedQuay?.text ?? "")
                                .foregroundStyle(changedTrack ? .red : Color.label)
                        }
                        .foregroundColor(timedLeg.legAlight.stopCallStatus.notServicedStop ? .red : .label)

                        ForEach(timedLeg.relevantPtSituations(allPtSituations: ptSituations)) { ptSituation in
                            Divider()
                            AlertLabel(alertCause: ptSituation.alertCause)
                            ForEach(ptSituation.allInfos.indices) { index in
                                Text(ptSituation.allInfos[index])
                            }.onTapGesture {
                                selectedPTSituation = ptSituation
                            }
                        }

                    }.listRowSeparator(.hidden)
                case .transfer, .continous:
                    HStack {
                        Image(systemName: "figure.walk")
                        if let duration = leg.duration {
                            Text(DurationFormatter.string(for: duration))
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 7))
                        .padding(.horizontal, 5)
                    )
                    .listRowSeparator(.hidden)
                }
            }
        }
        .sheet(item: $selectedPTSituation) { situation in
            VStack {
                HStack {
                    Spacer()
                    Button {
                        selectedPTSituation = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ScrollView(.vertical) {
                    PTSituationDetailView(ptSituation: situation)
                }
            }.padding()
                .frame(maxWidth: 960)
        }
        .sheet(item: $selectedTripInfo) { tripInfo in
            VStack {
                HStack {
                    Spacer()
                    Button {
                        selectedTripInfo = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                TripInfoDetailView(tripInfo: tripInfo)

            }.padding()
                .frame(maxWidth: 960)
        }
    }
}

#Preview {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadTrips(xmlFileName: "tr-fribourg-basel")
        },
        content: { tripDelivery in
            if let trip = tripDelivery.tripResults.first {
                TripDetailView(trip: trip.trip!, ptSituations: tripDelivery.ptSituations)
            } else {
                Text("No Trip")
            }
        }
    )
}
