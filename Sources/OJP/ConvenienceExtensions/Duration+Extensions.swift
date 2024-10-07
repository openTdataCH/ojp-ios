//
//  Duration+Extensions.swift
//
//
//  Created by Lehnherr Reto on 28.06.2024.
//

import Duration
import Foundation

#if swift(>=5.10)
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
