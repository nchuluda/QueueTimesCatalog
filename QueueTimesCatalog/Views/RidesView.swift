//
//  RidesView.swift
//  QueueTimesCatalog
//
//  Created by Nathan on 12/5/23.
//

import SwiftUI

struct RidesView: View {
    var parkId: Int
    var parkName: String
    
    @EnvironmentObject var catalog: Catalog
    
//    @StateObject var rideStore: RideStore
    init(parkId: Int, parkName: String) {
        self.parkId = parkId
        self.parkName = parkName
//        _rideStore = StateObject(wrappedValue: RideStore(parkId: parkId))
    }
    
    var body: some View {
        List {
            ForEach(catalog.top.lands) { land in
                Section(header: Text(land.name)) {
                    ForEach(land.rides) { ride in
                        formattedWaitTime(ride: ride)
                    }
                }
            }
        }
        .navigationTitle(parkName)
        .refreshable {
            do {
//                try await rideStore.refresh(parkId)
                try await catalog.fetchRidesByParkId(parkId: parkId)
            } catch {
                print("Error: Couldn't refresh data")
            }
        }
        .task {
            do {
//                try await rideStore.refresh(parkId)
                try await catalog.fetchRidesByParkId(parkId: parkId)
            } catch {
                print("Error: Couldn't refresh data")
            }
            
        }
    }
}

func closed() -> some View {
    Text("Closed")
        .foregroundColor(.red)
        .bold()
}

func open() -> some View {
    Text("Open")
        .foregroundColor(.green)
        .bold()
}

func waitTime(ride: Ride, color: Color) -> some View {
    Text("\(ride.waitTime) mins")
        .foregroundColor(color)
        .bold()
}

@ViewBuilder
func formattedWaitTime(ride: Ride) -> some View {
    VStack {
        HStack {
            //        Text("\(ride.id) \(ride.name)")
            Text("\(ride.name)")
            Spacer()
            if !ride.isOpen {
                closed()
            } else if ride.waitTime == 0 {
                open()
            } else if ride.waitTime <= 20 {
                waitTime(ride: ride, color: .green)
            } else if ride.waitTime <= 45 {
                waitTime(ride: ride, color: .yellow)
            } else if ride.waitTime > 45 {
                waitTime(ride: ride, color: .red)
            }
        }
        HStack {
            Text(ride.lastUpdatedAgo).font(.caption2)
            Spacer()
        }
    }
}

#Preview {
    RidesView(parkId: 60, parkName: "Kings Island")
}
