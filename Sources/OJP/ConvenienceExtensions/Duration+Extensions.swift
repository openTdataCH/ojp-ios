//
//  Duration+Extensions.swift
//
//
//  Created by Lehnherr Reto on 28.06.2024.
//

import Duration
import Foundation

extension Duration: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(iso8601)
    }
}
