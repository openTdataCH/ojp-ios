//
//  TimeInterval+Extensions.swift
//  OJPSampleApp
//
//  Created by Terence Alberti on 01.07.2024.
//

import Foundation

extension TimeInterval {
    @available(*, deprecated, message: "use a localizable time formatter instead")
    var hoursMinutesSeconds: String {
        let hours = Int(self / .hour)
        let minutes = (Int(self) % Int(.hour)) / Int(.minute)
        let seconds = Int(self) % Int(.minute)
        if hours > 0 {
            return "\(hours.description)h \(minutes.description)min \(seconds.description)s"
        } else if minutes > 0 {
            return "\(minutes.description)min \(seconds.description)s"
        } else {
            return "\(seconds.description)s"
        }
    }

    var hoursMinutesSecondsColonSeparated: String {
        let hours = Int(self / .hour)
        let minutes = (Int(self) % Int(.hour)) / Int(.minute)
        let seconds = Int(self) % Int(.minute)
        return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }

    var hoursMinutesColonSeparated: String {
        let hours = Int(self / .hour)
        let minutes = (Int(self) % Int(.hour)) / Int(.minute)
        return "\(String(format: "%01d", hours)):\(String(format: "%02d", minutes))"
    }

    var formattedDelay: String {
        let minutes = Int(self / .minute)
        guard minutes > 0 else { return "" }
        return "+\(minutes)'"
    }

    static var second: Self { 1.0 }
    static var minute: Self { 60 * second }
    static var hour: Self { 60 * minute }
}
