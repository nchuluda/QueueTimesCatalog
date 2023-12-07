//
//  Catalog.swift
//  QueueTimesCatalog
//
//  Created by Nathan on 12/5/23.
//

import Foundation

class Catalog: ObservableObject {
    
    var parksUrlString = "https://queue-times.com/parks.json"
    @Published var chains: [Chain] = []
    var top: Top = Top(lands: [], rides: [])
    
    func fetchParksJson() async throws {
        print("fetchJson() parks.json")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        print("We are accessing \(parksUrlString)")
        
        guard let url = URL(string: parksUrlString) else {
            print("ERROR: Could not create a URL from \(parksUrlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let chains = try? decoder.decode([Chain].self, from: data) else {
                print("ERROR: Could not decode JSON data")
                return
            }
            
            self.chains = chains
            print("JSON returned")

        } catch {
            print("ERROR: Could not create a URL from \(parksUrlString)")
        }
        
        // FETCH EVERY PARKS RIDES AND CURRENT WAIT TIMES (>100 API CALLS)
        do {
            for chain in chains {
                for var park in chain.parks {
                    do {
//                        if park.id == 50 {
                            
                            try await fetchRidesByParkId(parkId: park.id)

                            park.lands = self.top.lands
                            
                            for i in 0..<chains.count {
                                for j in 0..<chains[i].parks.count {
                                    if chains[i].parks[j].id == park.id {
                                        self.chains[i].parks[j].lands = self.top.lands
                                    }
                                }
                            }
//                        }
                    } catch {
                        print("error: fetching wait times for \(park.id)")
                    }
                }
            }
        }
        // Write catalog to local storage and print compiled json of all rides at all parks
        do {
            let task = Task {
                let data = try JSONEncoder().encode(self.chains)
                let outfile = try Self.fileURL(123456789)
                print("\n\n\n\(outfile.absoluteString)\n\n\n")
                let prettyjson = data.prettyPrintedJSONString!
                debugPrint(prettyjson)
                try data.write(to: outfile)
            }
            _ = try await task.value
        }
    }
    
    func fetchRidesByParkId(parkId: Int) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        print("We are accessing https://queue-times.com/parks/\(parkId)/queue_times.json")
        
        guard let url = URL(string: "https://queue-times.com/parks/\(parkId)/queue_times.json") else {
            print("ERROR: Could not create a URL from https://queue-times.com/parks/\(parkId)/queue_times.json")
            return
        }
        
        // Fetch JSON Data
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let top = try? decoder.decode(Top.self, from: data) else {
                print("ERROR: Could not decode JSON data")
                return
            }
            
            self.top = top
            
            // move [rides] to land.rides
            if top.lands.isEmpty && !top.rides.isEmpty {
                self.top.lands = [Land(id: 1, name: "All Rides", rides: self.top.rides)]
                self.top.rides.removeAll()
            }
            
            print("JSON returned, ride and land arrays created")
        } catch {
            print("ERROR: Could not create a URL from the URL string")
        }
        
        // Save data locally
        do {
            try await self.save(top, parkId)
        } catch {
            print("ERROR: Could not save data locally")
        }
    }
    
    private static func fileURL(_ parkId: Int) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("park-\(parkId).data")
    }
    
    func save(_ top: Top, _ parkId: Int) async throws {
        print("saving \(parkId)")
        let task = Task {
            let data = try JSONEncoder().encode(top)
            let outfile = try Self.fileURL(parkId)
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    func loadLocalData(_ parkId: Int) async throws {
        print("loading \(parkId)")
        let task = Task<Top, Error> {
            
            let fileURL = try Self.fileURL(parkId)
            print(fileURL.absoluteString)
            guard let data = try? Data(contentsOf: fileURL) else {
                return Top(lands: [], rides: [])
            }
            let top = try JSONDecoder().decode(Top.self, from: data)
            return top
        }
        let top = try await task.value
        self.top = top
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
