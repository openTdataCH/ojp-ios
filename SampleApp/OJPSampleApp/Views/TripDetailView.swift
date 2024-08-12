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

    var body: some View {
        List(trip.legs) { leg in
            switch leg.legType {
            case .continous:
                Text("Continous leg") // TODO: implement
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
                            Text(delay)
                        }
                        Text(legBoard.stopPointName.text).bold()
                        Text(legBoard.estimatedQuay?.text ?? legBoard.plannedQuay?.text ?? "")
                            .foregroundStyle(changedTrack ? .red : .black)
                    }
                    ForEach(timedLeg.legsIntermediate) { legIntermediate in
                        HStack {
                            Text(legIntermediate.stopPointName.text)
                                .foregroundStyle(.gray)
                        }
                    }
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
                            .foregroundStyle(changedTrack ? .red : .black)
                    }
                    ForEach(timedLeg.relevantPtSituations(allPtSituations: ptSituations)) { ptSituation in
                        Divider()
                        ForEach(ptSituation.allInfos, id: \.self) { infoText in
                            Text(infoText)
                        }
                    }

                }.listRowSeparator(.hidden)
            case let .transfer(transferLeg):
                HStack {
                    Image(systemName: "figure.walk")
                    Text(DurationFormatter.string(for: transferLeg.duration))
                }
                .listRowBackground(Color.gray.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 7))
                    .padding(.horizontal, 5)
                )
                .listRowSeparator(.hidden)
            }
        }
    }
}

#Preview {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadTrips(xmlFileName: "tr-fribourg-berne")
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

extension OJPv2.PTSituation: Identifiable {
    public var id: String {
        situationNumber
    }

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
