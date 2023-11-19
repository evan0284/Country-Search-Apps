//
//  PostDetailView.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-18.
//

import Foundation
import SwiftUI


struct PostDetailView: View {
    let country: Country
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            SVGBigImageView(svgURL: URL(string: country.flag)!)
                .frame(width: 350, height: 200)
                .shadow(radius: 1)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Capital:")
                        .font(.headline)
                    Spacer()
                    if let capital = country.capital {
                        Text(capital)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                HStack {
                    Text("Languages:")
                        .font(.headline)
                    Spacer()
                    Text(country.languages.joined(separator: ", "))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                HStack {
                    Text("Population:")
                        .font(.headline)
                    Spacer()
                    Text("\(country.population)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                HStack {
                    Text("Region:")
                        .font(.headline)
                    Spacer()
                    Text(country.region)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                if let area = country.area {
                    HStack {
                        Text("Area:")
                            .font(.headline)
                        Spacer()
                        Text("\(area)")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            
            Button(action: {
                toggleFavorite()
            }) {
                Text(isFavorite ? "Remove from Favorites" : "Add to Favorites")
                    .padding()
                    .foregroundColor(.white)
                    .background(isFavorite ? Color.red : Color.blue)
                    .cornerRadius(8)
            }

        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .navigationTitle("\(country.name)")
    }
}

    

