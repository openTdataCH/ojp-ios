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
        state: [],
        content: { t in
            if let trip = t.first?.trip {
                TripDetailView(trip: trip)
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
