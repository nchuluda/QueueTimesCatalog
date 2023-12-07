//
//  Park.swift
//  QueueTimesCatalog
//
//  Created by Nathan on 12/5/23.
//

import Foundation

struct Park: Codable, Hashable {
    var id: Int
    var name, country, latitude, longitude, timezone: String
    var lands: [Land]
    
    init(id: Int, name: String, country: String, latitude: String, longitude: String, timezone: String, lands: [Land]) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.lands = lands
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.country = try container.decode(String.self, forKey: .country)
        self.latitude = try container.decode(String.self, forKey: .latitude)
        self.longitude = try container.decode(String.self, forKey: .longitude)
        self.timezone = try container.decode(String.self, forKey: .timezone)
        self.lands = []
    }
}
