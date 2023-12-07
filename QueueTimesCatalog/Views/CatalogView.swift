//
//  CatalogView.swift
//  QueueTimesCatalog
//
//  Created by Nathan on 12/5/23.
//

import SwiftUI

struct CatalogView: View {
    @StateObject var catalog = Catalog()
    
    var body: some View {
        VStack {
            NavigationView {

                List(catalog.chains, id: \.self) { chain in
                    NavigationLink(chain.name, destination: ParksView(parks: chain.parks))
                }
                .listStyle(.plain)
                .navigationTitle("Queue-Times")
                .refreshable {
                    try? await catalog.fetchParksJson()
                }
            }
            .task {
                try? await catalog.fetchParksJson()
            }
            .environmentObject(catalog)
            }
    }
}

#Preview {
    CatalogView()
}
