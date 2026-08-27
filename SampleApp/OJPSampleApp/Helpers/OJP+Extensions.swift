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

extension OJPv2.LegIntermediate: @retroactive Identifiable {
    public var id: String {
        stopPointRef
    }
}


extension OJPv2.StopEventResult: @retroactive Identifiable {
    public var id: String {
        stopEvent.service.journeyRef + stopEvent.thisCall.stopPoint.stopPointRef + stopEvent.service.operatingDayRef
    }
}

extension OJPv2.PTSituation {
    var allInfos: [String] {
        var infos: [String] = []
        guard let publishingActions else { return [] }
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
        case .unknown:
            "Unbekannt"
        case .securityAlert:
            "Sicherheitsalarm"
        case .emergencyServicesCall:
            "Notfall-Einsatz"
        case .policeActivity:
            "Polizeieinsatz"
        case .policeOrder:
            "Polizeiliche Anordnung"
        case .fire:
            "Brand"
        case .cableFire:
            "Kabelbrand"
        case .smokeDetectedOnVehicle:
            "Rauchentwicklung im Fahrzeug"
        case .fireAtTheStation:
            "Brand am Bahnhof"
        case .fireRun:
            "Feuerwehreinsatz"
        case .fireBrigadeOrder:
            "Anordnung der Feuerwehr"
        case .explosion:
            "Explosion"
        case .explosionHazard:
            "Explosionsgefahr"
        case .bombDisposal:
            "Bombenentschärfung"
        case .emergencyMedicalServices:
            "Rettungseinsatz"
        case .emergencyBrake:
            "Notbremsung"
        case .vandalism:
            "Vandalismus"
        case .cableTheft:
            "Kabeldiebstahl"
        case .signalPassedAtDanger:
            "Signal überfahren"
        case .stationOverrun:
            "Bahnhof überfahren"
        case .passengersBlockingDoors:
            "Türen durch Fahrgäste blockiert"
        case .defectiveSecuritySystem:
            "Defektes Sicherheitssystem"
        case .overcrowded:
            "Überfüllung"
        case .borderControl:
            "Grenzkontrolle"
        case .unattendedBag:
            "Unbeaufsichtigtes Gepäck"
        case .telephonedThreat:
            "Telefonische Drohung"
        case .suspectVehicle:
            "Verdächtiges Fahrzeug"
        case .evacuation:
            "Evakuierung"
        case .terroristIncident:
            "Terroristischer Vorfall"
        case .publicDisturbance:
            "Öffentliche Unruhen"
        case .technicalProblem:
            "Technisches Problem"
        case .vehicleFailure:
            "Fahrzeugstörung"
        case .serviceDisruption:
            "Unterbruch"
        case .doorFailure:
            "Türstörung"
        case .lightingFailure:
            "Beleuchtungsstörung"
        case .pointsProblem:
            "Weichenproblem"
        case .pointsFailure:
            "Weichenstörung"
        case .signalProblem:
            "Signalproblem"
        case .signalFailure:
            "Signalstörung"
        case .overheadWireFailure:
            "Fahrleitungsstörung"
        case .levelCrossingFailure:
            "Bahnübergangsstörung"
        case .trafficManagementSystemFailure:
            "Störung des Verkehrsmanagementsystems"
        case .engineFailure:
            "Motorstörung"
        case .breakdown:
            "Panne"
        case .repairWork:
            "Reparaturarbeiten"
        case .constructionWork:
            "Baustelle"
        case .maintenanceWork:
            "Unterhaltsarbeiten"
        case .powerProblem:
            "Stromproblem"
        case .trackCircuitProblem:
            "Gleisstromkreisproblem"
        case .swingBridgeFailure:
            "Störung der Klappbrücke"
        case .escalatorFailure:
            "Rolltreppenstörung"
        case .liftFailure:
            "Liftstörung"
        case .gangwayProblem:
            "Problem mit dem Übergang"
        case .defectiveVehicle:
            "Defektes Fahrzeug"
        case .brokenRail:
            "Schienenbruch"
        case .poorRailConditions:
            "Schlechter Gleiszustand"
        case .deicingWork:
            "Enteisungsarbeiten"
        case .wheelProblem:
            "Radproblem"
        case .routeBlockage:
            "Blockierte Strecke"
        case .congestion:
            "Stau"
        case .heavyTraffic:
            "Starker Verkehr"
        case .routeDiversion:
            "Umleitung"
        case .roadworks:
            "Strassenarbeiten"
        case .unscheduledConstructionWork:
            "Ungeplante Bauarbeiten"
        case .levelCrossingIncident:
            "Vorfall am Bahnübergang"
        case .sewerageMaintenance:
            "Unterhaltsarbeiten an der Kanalisation"
        case .roadClosed:
            "Strasse gesperrt"
        case .roadwayDamage:
            "Fahrbahnschaden"
        case .bridgeDamage:
            "Brückenschaden"
        case .personOnTheLine:
            "Person auf der Strecke"
        case .objectOnTheLine:
            "Gegenstand auf der Strecke"
        case .vehicleOnTheLine:
            "Fahrzeug auf der Strecke"
        case .animalOnTheLine:
            "Tier auf der Strecke"
        case .fallenTreeOnTheLine:
            "Umgestürzter Baum auf der Strecke"
        case .vegetation:
            "Vegetation"
        case .speedRestrictions:
            "Geschwindigkeitsbeschränkung"
        case .precedingVehicle:
            "Vorausfahrendes Fahrzeug"
        case .accident:
            "Unfall"
        case .nearMiss:
            "Beinaheunfall"
        case .personHitByVehicle:
            "Person von Fahrzeug erfasst"
        case .vehicleStruckObject:
            "Fahrzeug kollidiert mit Gegenstand"
        case .vehicleStruckAnimal:
            "Fahrzeug kollidiert mit Tier"
        case .derailment:
            "Entgleisung"
        case .collision:
            "Kollision"
        case .levelCrossingAccident:
            "Unfall am Bahnübergang"
        case .poorWeather:
            "Unwetter"
        case .fog:
            "Nebel"
        case .heavySnowFall:
            "Starker Schneefall"
        case .heavyRain:
            "Starker Regen"
        case .strongWinds:
            "Starker Wind"
        case .ice:
            "Glatteis"
        case .hail:
            "Hagel"
        case .highTemperatures:
            "Hohe Temperaturen"
        case .flooding:
            "Überschwemmung"
        case .lowWaterLevel:
            "Niedriger Wasserstand"
        case .riskOfFlooding:
            "Hochwassergefahr"
        case .highWaterLevel:
            "Hoher Wasserstand"
        case .fallenLeaves:
            "Laub"
        case .fallenTree:
            "Umgestürzter Baum"
        case .landslide:
            "Erdrutsch"
        case .riskOfLandslide:
            "Erdrutschgefahr"
        case .driftingSnow:
            "Schneeverwehungen"
        case .blizzardConditions:
            "Schneesturm"
        case .stormDamage:
            "Sturmschäden"
        case .lightningStrike:
            "Blitzeinschlag"
        case .roughSea:
            "Starker Seegang"
        case .highTide:
            "Flut"
        case .lowTide:
            "Ebbe"
        case .iceDrift:
            "Eisgang"
        case .avalanches:
            "Lawinen"
        case .riskOfAvalanches:
            "Lawinengefahr"
        case .flashFloods:
            "Sturzfluten"
        case .mudslide:
            "Murgang"
        case .rockfalls:
            "Steinschlag"
        case .subsidence:
            "Bodensenkung"
        case .earthquakeDamage:
            "Erdbebenschäden"
        case .grassFire:
            "Grasbrand"
        case .wildlandFire:
            "Wald- und Flächenbrand"
        case .iceOnRailway:
            "Eis auf der Bahnstrecke"
        case .iceOnCarriages:
            "Eis auf den Fahrzeugen"
        case .specialEvent:
            "Special Event"
        case .procession:
            "Prozession"
        case .demonstration:
            "Demonstration"
        case .industrialAction:
            "Arbeitskampf"
        case .staffSickness:
            "Personal krank"
        case .staffAbsence:
            "Personalausfall"
        case .operatorCeasedTrading:
            "Betrieb eingestellt"
        case .previousDisturbances:
            "Vorherige Störungen"
        case .vehicleBlockingTrack:
            "Fahrzeug blockiert Strecke"
        case .foreignDisturbances:
            "Störungen im Ausland"
        case .awaitingShuttle:
            "Warten auf Shuttle"
        case .changeInCarriages:
            "Änderung der Wagenreihung"
        case .trainCoupling:
            "Zugzusammenführung"
        case .boardingDelay:
            "Verzögerung beim Einsteigen"
        case .awaitingApproach:
            "Warten auf Annäherung"
        case .overtaking:
            "Überholung"
        case .provisionDelay:
            "Bereitstellungsverzögerung"
        case .miscellaneous:
            "Sonstiges"
        case .levelCrossingBlocked:
            "Bahnübergang blockiert"
        case .waitingForTransferPassengers:
            "Warten auf Umsteigefahrgäste"
        case .awaitingOncomingVehicle:
            "Warten auf entgegenkommendes Fahrzeug"
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

extension OJPv2.TripInfoResult: @retroactive Identifiable {
    public var id: Int {
        service?.journeyRef.hashValue ?? (previousCalls.hashValue + onwardCalls.hashValue)
    }
}

extension OJPv2.TripRefineDelivery: @retroactive Identifiable {
    public var id: Int {
        tripResults.map(\.id).hashValue
    }
}
