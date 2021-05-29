//
//  CaseIterableExtension.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 27/05/21.
//

import Foundation

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
