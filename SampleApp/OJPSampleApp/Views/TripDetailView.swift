//
//  TripDetailView.swift
//  OJPSampleApp
//
//  Created by Terence Alberti on 01.07.2024.
//

import SwiftUI
import OJP

struct TripDetailView: View {
    
    let trip: OJPv2.Trip
    
    var body: some View {
        List(trip.legs) { leg in
            switch leg.legType {
            case .continous:
                Text("Continous leg")   // todo: implement
            case .timed(let timedLeg):
                VStack(alignment: .leading) {
                    HStack {
                        Text(timedLeg.service.publishedServiceName.text)
                            .bold()
                        Text(timedLeg.service.destinationText?.text ?? "")
                            .bold()
                    }
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
                        Text(legBoard.stopPointName.text)
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
                            Text(delay)
                        }
                        Text(timedLeg.legAlight.stopPointName.text)
                        Text(legAlight.estimatedQuay?.text ?? legAlight.plannedQuay?.text ?? "")
                            .foregroundStyle(changedTrack ? .red : .black)
                    }
                }
            case .transfer(let transferLeg):
                HStack {
                    Image(systemName: "figure.walk")
                    Text((DurationFormatter.string(for: transferLeg.duration)))
                }
                
            }
        }
    }
}

#Preview {
    AsyncView(
        task: {
            await PreviewMocker.shared.loadTrips()
        },
        state: [],
        content: { t in
            if let trip = t.first?.trip {
                TripDetailView(trip: trip)
            } else {
                Text("No Trip")
            }
        }
    )
}

extension OJPv2.LegIntermediate: Hashable {
    
    public static func == (lhs: OJPv2.LegIntermediate, rhs: OJPv2.LegIntermediate) -> Bool {
        return lhs.stopPointRef == rhs.stopPointRef
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stopPointRef)
    }
    
    
}
