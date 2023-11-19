//
//  ChartsView.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-18.
//

import Foundation
import SwiftUI
import Charts


struct ChartsView: View {
    let countries: [Country]

    var body: some View {
        VStack(spacing: 20) {
            if !countries.isEmpty {
                let sortedByPopulation = countries.sorted(by: { $0.population > $1.population })
                let topFive = Array(sortedByPopulation.prefix(5))

                VStack {
                    Text("5 Most Populated Countries")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Chart {
                        ForEach(topFive) { country in
                            BarMark(x: .value("Type", country.name), y: .value("Population", country.population))

                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 200)

                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: .infinity)


                let continentTop5Countries = Dictionary(grouping: countries, by: { $0.region })
                    .mapValues { $0.count }
                    .sorted(by: { $0.value > $1.value })
                    .prefix(5)

                VStack {
                    Text("Top 5 Continents by Number of Countries")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Chart {
                        ForEach(continentTop5Countries.sorted(by: { $0.key < $1.key }), id: \.key) { region, count in
                            SectorMark(angle: .value(region, Double(count)),
                                       innerRadius: .ratio(0.3), angularInset: 2)
                                .annotation(position: .overlay) {
                                    VStack{
                                        Text("\(region)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("\(count)")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                }
                                .cornerRadius(5)
                                
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 200)

                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: .infinity)

            } else {
                Text("Loading Data...")
                    .font(.title)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .navigationTitle("Charts")
    }
}
