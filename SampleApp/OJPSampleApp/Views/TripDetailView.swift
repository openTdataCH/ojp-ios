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
                    ForEach(timedLeg.legsIntermediate, id: \.self) { legIntermediate in
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
                    ForEach(timedLeg.relevantPtSituations(allPtSituations: ptSituations), id: \.self) { ptSituation in
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
            await PreviewMocker.shared.loadTrips()
        },
        state: nil,
        content: { tripDelivery in
            if let tripDelivery,
               let trip = tripDelivery.tripResults.first {
                TripDetailView(trip: trip.trip!, ptSituations: tripDelivery.ptSituations)
            } else {
                Text("No Trip").frame(minWidth: 200, minHeight: 200)
            }
        }
    )
}

extension OJPv2.LegIntermediate: Hashable {
    public static func == (lhs: OJPv2.LegIntermediate, rhs: OJPv2.LegIntermediate) -> Bool {
        lhs.stopPointRef == rhs.stopPointRef
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(stopPointRef)
    }
}

extension OJPv2.PTSituation: Hashable {
    public static func == (lhs: OJPv2.PTSituation, rhs: OJPv2.PTSituation) -> Bool {
        lhs.situationNumber == rhs.situationNumber
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(situationNumber)
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

extension OJPv2.TripDelivery {
    
    var ptSituations: [OJPv2.PTSituation] {
        return tripResponseContext?.situations.compactMap({ situation in
            switch situation {
            case .ptSituation(let pTSituation):
                return pTSituation
            case .roadSituation:
                return nil
            }
        }) ?? []
    }
    
}

extension OJPv2.TimedLeg {
    
    func relevantPtSituations(allPtSituations: [OJPv2.PTSituation]) -> [OJPv2.PTSituation] {
        return allPtSituations.filter { ptSituation in
            if let situationFullRefs = service.situationFullRefs {
                return situationFullRefs.situationFullRefs.contains(where: { situationFullRef in
                    situationFullRef.situationNumber == ptSituation.situationNumber
                })
            } else {
                return false
            }
        }
    }
    
}
