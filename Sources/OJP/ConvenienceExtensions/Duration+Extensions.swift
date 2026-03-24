//
//  Duration+Extensions.swift
//
//
//  Created by Lehnherr Reto on 28.06.2024.
//

import Duration
import Foundation

#if swift(>=6.0)
    extension Duration: @retroactive Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(iso8601)
        }
    }
#else
    extension Duration: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(iso8601)
        }
    }
#endif

extension Duration {

    /// Creates a `TimeInterval` from the duration.
    ///
    /// ⚠️ use with caution: **Will only take hours, minutes and seconds into account**
    internal var timeinterval: TimeInterval {
        var accu: TimeInterval = 0.0
        if let second {
            accu += Double(second)
        }
        if let minute {
            accu += Double(minute * 60)
        }
        if let hour {
            accu += Double(hour * 3600)
        }
        return accu
    }
}
