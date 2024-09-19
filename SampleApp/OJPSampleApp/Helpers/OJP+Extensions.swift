//
//  OJP+Extensions.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 21.08.2024.
//
// Collection of convenience extensions

import Foundation
import OJP

extension OJP {
    @MainActor
    static var configured: OJP {
        OJPHelper.ojp
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

extension OJPv2.TripStatus {
    var hasIssue: Bool {
        cancelled || infeasible || deviation
    }

    var title: String {
        if cancelled {
            "Cancelled"
        } else if infeasible {
            "Infeasible"
        } else if deviation {
            "Deviation"
        } else {
            ""
        }
    }
}

extension OJPv2.AlertCause {
    var title: String {
        switch self {
        case .undefinedAlertCause:
            "Undefiniert"
        case .constructionWork:
            "Baustelle"
        case .serviceDisruption:
            "Unterbruch"
        case .emergencyServicesCall:
            "Notfall-Einsatz"
        case .vehicleFailure:
            "Fahrzeugstörung"
        case .poorWeather:
            "Unwetter"
        case .routeBlockage:
            "Blockierte Strecke"
        case .technicalProblem:
            "Technisches Problem"
        case .unknown:
            "Unbekannt"
        case .accident:
            "Unfall"
        case .specialEvent:
            "Special Event"
        case .congestion:
            "Stau"
        case .maintenanceWork:
            "Unterhaltsarbeiten"
        }
    }
}

extension OJPv2.Trip {
    var firstTimedLeg: OJPv2.TimedLeg? {
        legs.compactMap({ leg in
            if case let .timed(timedLeg) = leg.legType {
                return timedLeg
            }
            return nil }
        ).first
    }

    var lastTimedLeg: OJPv2.TimedLeg? {
        legs.compactMap({ leg in
            if case let .timed(timedLeg) = leg.legType {
                return timedLeg
            }
            return nil }
        ).last
    }
}

extension OJPv2.TripInfoResult: Identifiable {
    public var id: Int {
        service?.journeyRef.hashValue ?? (previousCalls.hashValue + onwardCalls.hashValue)
    }
}
