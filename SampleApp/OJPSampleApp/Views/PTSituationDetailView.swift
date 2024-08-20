//
//  PTSituationDetailView.swift
//
//
//  Created by Lehnherr Reto on 09.08.2024.
//

import OJP
import SwiftUI

struct PTSituationDetailView: View {
    let ptSituation: OJPv2.PTSituation

    var indexSituations: [(Int, OJPv2.PublishingAction)] {
        ptSituation.publishingActions.publishingActions.enumerated().map { ($0, $1) }
    }

    var body: some View {
        Grid(alignment: .leadingFirstTextBaseline,
             horizontalSpacing: 5,
             verticalSpacing: 5)
        {
            GridRow {
                Text("Situation Number")
                Text(ptSituation.situationNumber)
            }
            GridRow {
                Text("Dauer")
                ForEach(ptSituation.validityPeriod, id: \.startTime) { validityPeriod in
                    Text("Von \(validityPeriod.startTime.formatted()) bis \(validityPeriod.endTime.formatted())")
                }
            }
            Divider()

            GridRow {
                Text("PassengerInformationActions")
                Text("#\(ptSituation.publishingActions.publishingActions.count)")
            }

            ForEach(indexSituations, id: \.0) { _, action in
                ForEach(action.passengerInformationActions, id: \.self) { p in
                    ForEach(p.textualContents, id: \.self) { tc in
                        GridRow {
                            Text("Summary")
                            Text(tc.summaryContent.summaryText)
                        }
                        GridRow {
                            Text("Reason Content")
                            Text(tc.reasonContent?.reasonText ?? "-")
                        }
                        GridRow {
                            Text("Description Content")
                            Text("#\(tc.descriptionContents.count)")
                        }
                        ForEach(tc.descriptionContents, id: \.self) { dc in
                            GridRow {
                                Text("Description Text")
                                Text(dc.descriptionText)
                            }
                        }
                        GridRow {
                            Text("Consequence Content")
                            Text("#\(tc.consequenceContents.count)")
                        }
                        ForEach(tc.consequenceContents, id: \.self) { dc in
                            GridRow {
                                Text("Consequences Text")
                                Text(dc.consequenceText)
                            }
                        }
                        GridRow {
                            Text("Remark Contents")
                            Text("#\(tc.remarkContents.count)")
                        }
                        ForEach(tc.recommendationContents, id: \.self) { dc in
                            GridRow {
                                Text("Recommendation Text")
                                Text(dc.recommendationText)
                            }
                        }
                        GridRow {
                            Text("Duration Text")
                            Text(tc.durationContent?.durationText ?? "-")
                        }

                        GridRow {
                            Text("Remark Contents")
                            Text("#\(tc.remarkContents.count)")
                        }
                        ForEach(tc.remarkContents, id: \.self) { dc in
                            GridRow {
                                Text("Remark Text")
                                Text(dc.remarkText)
                            }
                        }
                    }
                }
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
            if let ptSituation = tripDelivery.ptSituations.first {
                PTSituationDetailView(ptSituation: ptSituation)
            } else {
                Text("No Situation")
            }
        }
    )
}
