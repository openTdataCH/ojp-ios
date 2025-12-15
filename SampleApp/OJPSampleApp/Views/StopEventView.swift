//
//  StopEventView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 29.11.2024.
//

import OEVIcons
import OJP
import SwiftUI

struct StationTimeView: View {
    let stationTime: StationTime
    var body: some View {
        HStack(spacing: 4) {
            Text(stationTime.timetabled.formatted(date: .omitted, time: .shortened)).bold()
            Text(stationTime.hasDelay ? stationTime.delay.formattedDelay : "").foregroundStyle(.red).bold()
        }.font(.title)
    }
}

enum StopEventMode: String {
    case arrival = "Arrival"
    case departure = "Departure"

    var ojpType: OJPv2.StopEventType {
        switch self {
        case .arrival:
            .arrival
        case .departure:
            .departure
        }
    }
}

struct StopEventView: View {
    let stopEvent: OJPv2.StopEvent
    let ptSituations: [OJPv2.PTSituation]
    @State var selectedPtSituation: OJPv2.PTSituation?
    let mode: StopEventMode

    var stationTime: StationTime? {
        switch mode {
        case .arrival:
            stopEvent.thisCall.callAtStop.serviceArrival?.arrivalTime
        case .departure:
            stopEvent.thisCall.callAtStop.serviceDeparture?.departureTime
        }
    }

    var title: String {
        let station = mode == .departure ? stopEvent.service.destinationText?.text : stopEvent.service.originText.text
        return station ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 4) {
                    Pictograms.picto(mode: stopEvent.service.mode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Group {
                        if let icon = OEVIcons.serviceIcon(stopEvent.service) {
                            icon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Text(stopEvent.service.publishedServiceName.text)
                                .font(.title)
                                .bold()
                        }
                    }.frame(width: 60, alignment: .leading)
                }
                .frame(height: 21)

                Group {
                    if let stationTime {
                        StationTimeView(stationTime: stationTime)
                    }
                }
                .frame(maxWidth: 100, alignment: .leading)

                Text(title).font(.title)
                ForEach(ptSituations) { ptSituation in
                    OEVIcons.disruption
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 21)
                        .onTapGesture {
                            selectedPtSituation = ptSituation
                        }
                }
                Spacer()
                Text(stopEvent.thisCall.callAtStop.plannedQuay?.text ?? "").font(.title)
            }

            if let selectedPtSituation, let publishingAction = selectedPtSituation.publishingActions?.publishingActions.first {
                ZStack {
                    Color.disturbation
                    HStack {
                        Text(publishingAction.passengerInformationActions.first?.textualContents.first?.summaryContent.summaryText ?? "")
                            .font(.title2)
                            .foregroundStyle(.white)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onTapGesture {
            selectedPtSituation = nil
        }
    }
}

#Preview {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadStopEvents()
        },
        content: { stopEventDelivery in
            let results = stopEventDelivery.stopEventResults
            ForEach(results) { stopEventResult in
                let event = stopEventResult.stopEvent
                let situations = event.relevantPtSituations(allPtSituations: stopEventDelivery.ptSituations)
                StopEventView(
                    stopEvent: event,
                    ptSituations: situations,
                    mode: .departure
                )
            }
        }
    )
}

extension Pictograms {
    static func picto(mode: OJPv2.Mode) -> Image {
        switch mode.ptMode {
        case .air:
            Pictograms.aeroplane_right_framed
        case .bus:
            Pictograms.bus_right_framed
        case .coach:
            Pictograms.remote_bus_right_framed
        case .ferry:
            Pictograms.car_ferry_right_framed
        case .metro:
            Pictograms.metro_left_de_framed
        case .rail:
            Pictograms.train_right_framed
        case .taxi:
            Pictograms.taxi_right_framed
        case .telecabin:
            Pictograms.gondola_lift_right_framed
        case .trolleyBus:
            Pictograms.bus_right_framed
        case .tram:
            Pictograms.tram_right_framed
        case .water:
            Pictograms.jetty_right_framed
        case .cableway:
            Pictograms.cableway_right_framed
        case .underground:
            Pictograms.metro_right_de_framed
        case .funicular:
            Pictograms.funicular_railway_right_framed
        case .lift:
            Pictograms.lift
        case .snowAndIce:
            Pictograms.ski_lift_right_framed
        case .unknown:
            Pictograms.information_framed
        }
    }
}

extension OEVIcons {
    enum ServiceType: String {
        // case regio = "r" // -> no icon available
        case regioExpress = "re"
        case interCity = "ic"
        case interRegio = "ir"
        case sBahn = "s"
        case sn
        case ersatz = "ev"

        case pe // only "pe" and "pe 30"

        case bex
        case cnl
        case euroCity = "ec"
        case euroNight = "en"
        case extraZug = "ext"
        case glacierExpress = "gex"
        case ice
        case icn
        case nightJet = "nj"
        case ogv
        case railJet = "rj"
        case railJetXpress = "rjx"
        case tgv
        case vae

        var supportsNumbers: Bool {
            switch self {
            case .regioExpress, .interCity, .interRegio, .sBahn, .ersatz, .pe, .sn:
                true
            default:
                false
            }
        }
    }

    static func serviceIcon(_ service: OJPv2.DatedJourney) -> Image? {
        guard let shortName = service.mode.shortName?.text,
              let serviceType = ServiceType(rawValue: shortName.lowercased())
        else {
            return nil
        }
        let lineNumber = service.publishedServiceName.text.replacingOccurrences(of: shortName, with: "")

        if serviceType.supportsNumbers,
           let number = Int(lineNumber),
           number > 0, number < 100
        {
            return Image("\(serviceType.rawValue)-\(lineNumber)", bundle: OEVIcons.bundle)
        }
        return Image("\(serviceType.rawValue)", bundle: OEVIcons.bundle)
    }
}
