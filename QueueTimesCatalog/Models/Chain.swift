//
//  Chain.swift
//  QueueTimesCatalog
//
//  Created by Nathan on 12/5/23.
//

import Foundation

struct Chain: Codable, Hashable {
    var id: Int
    var name: String
    var parks: [Park]
}

