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
        HStack {
            HStack(spacing: 4) {
                Pictograms.picto(mode: stopEvent.service.mode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if let icon = OEVIcons.serviceIcon(stopEvent.service) {
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text(stopEvent.service.publishedServiceName.text)
                        .font(.title)
                        .bold()
                        .frame(width: 36, alignment: .leading)
                }
            }
            .frame(height: 21)

            Group {
                if let stationTime {
                    StationTimeView(stationTime: stationTime)
                }
            }
            .frame(maxWidth: 100, alignment: .leading)

            Text(title).font(.title)
            Spacer()
            Text(stopEvent.thisCall.callAtStop.plannedQuay?.text ?? "").font(.title)
        }
    }
}

#Preview {
    AsyncView(
        task: {
            try await PreviewMocker.shared.loadStopEvents()
        },
        content: { stopEventDelivery in
            let stopEvents = stopEventDelivery.stopEventResults
            ForEach(stopEvents) { stopEvent in
                StopEventView(
                    stopEvent: stopEvent.stopEvent,
                    mode: .departure
                )
            }
        }
    )
}

extension Pictograms {
    static func picto(mode: OJPv2.Mode) -> Image {
        switch mode.ptMode {
        case .rail:
            Pictograms.train_right_framed
        case .bus:
            Pictograms.bus_right_framed
        case .tram:
            Pictograms.tram_right_framed
        case .water:
            Pictograms.jetty_right_framed
        case .telecabin:
            Pictograms.cableway_right_framed
        case .underground:
            Pictograms.metro_right_de_framed
        case .unknown:
            Pictograms.information_framed
        }
    }
}

extension OEVIcons {
    enum ServiceType: String {
        case regio = "r"
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
            case .regio, .regioExpress, .interCity, .interRegio, .sBahn, .ersatz, .pe, .sn:
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

        return nil
    }
}
