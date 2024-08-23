//
//  Sequence+Extensions.swift
//
//
//  Created by Lehnherr Reto on 22.08.2024.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension Sequence {
    func unique<T: Hashable>(by keyPath: KeyPath<Iterator.Element, T>) -> [Iterator.Element] {
        var seen: Set<T> = []
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
