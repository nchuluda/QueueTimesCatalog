//
//  Land.swift
//  QueueTimesCatalog
//
//  Created by Nathan on 12/5/23.
//

import Foundation

struct Land: Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var rides: [Ride]
}
