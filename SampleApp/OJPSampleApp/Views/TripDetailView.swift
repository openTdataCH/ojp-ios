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
                        }
                        .bold()
                        Divider()
                        HStack {
                            let legBoard = timedLeg.legBoard
                            let timetabledTime = legBoard.serviceDeparture.timetabledTime
                            let estimatedTime = legBoard.serviceDeparture.estimatedTime
                            let changedTrack = legBoard.estimatedQuay != nil && legBoard.estimatedQuay!.text != legBoard.plannedQuay?.text
                            Text(estimatedTime?.formatted() ?? timetabledTime.formatted())
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
                            Text(estimatedTime?.formatted() ?? timetabledTime.formatted())
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
                PTSituationDetailView(ptSituation: situation)
            }.padding()
        }
    }
}

struct StationTime {
    let estimated: Date?
    let timetabled: Date

    var hasDelay: Bool {
        delay >= 60
    }

    var delay: TimeInterval {
        if let estimated {
            estimated.timeIntervalSince(timetabled)
        } else { 0 }
    }
}

extension OJPv2.ServiceArrival {
    var arrivalTime: StationTime {
        StationTime(estimated: estimatedTime, timetabled: timetabledTime)
    }
}

extension OJPv2.ServiceDeparture {
    var departureTime: StationTime {
        StationTime(estimated: estimatedTime, timetabled: timetabledTime)
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

extension OJPv2.LegIntermediate: Identifiable {
    public var id: String {
        stopPointRef
    }
}

extension OJPv2.PTSituation {
    var allInfos: [String] {
        var infos: [String] = []
        for publishingAction in publishingActions.publishingActions {
            for passengerInformationAction in publishingAction.passengerInformationActions {
                for textualContent in passengerInformationAction.textualContents {
                    infos.append(textualContent.summaryContent.summaryText)

                    for descriptionContent in textualContent.descriptionContents {
                        infos.append(descriptionContent.descriptionText)
                    }

                    for consequenceContent in textualContent.consequenceContents {
                        infos.append(consequenceContent.consequenceText)
                    }

                    for recommendationContent in textualContent.recommendationContents {
                        infos.append(recommendationContent.recommendationText)
                    }

                    for remarkContent in textualContent.remarkContents {
                        infos.append(remarkContent.remarkText)
                    }

                    if let reasonContent = textualContent.reasonContent {
                        infos.append(reasonContent.reasonText)
                    }

                    if let durationContent = textualContent.durationContent {
                        infos.append(durationContent.durationText)
                    }
                }
            }
        }
        return infos
    }
}
