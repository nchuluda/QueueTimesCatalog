//
//  ParksView.swift
//  QueueTimesCatalog
//
//  Created by Nathan on 12/5/23.
//

import SwiftUI

struct ParksView: View {
    @EnvironmentObject var catalog: Catalog

    var parks: [Park]
    var body: some View {
            List(parks, id: \.self) { park in
                NavigationLink("\(park.name)", destination: RidesView(parkId: park.id, parkName: park.name))
            }
            .navigationTitle("Parks")
            .listStyle(.plain)
    }
}

var canadasWonderland = Park(id: 58, name: "Canada's Wonderland", country: "Canada", latitude: "43.843", longitude: "-79.539", timezone: "America/Toronto", lands: [])

//var previewPark =
var previewParks = [canadasWonderland]

#Preview {
    ParksView(parks: previewParks).environmentObject(Catalog())
}
