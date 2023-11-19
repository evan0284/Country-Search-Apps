//
//  CountryRow.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-18.
//

import Foundation
import SwiftUI

struct CountryRow: View {
    let country: Country
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    var body: some View {
        HStack {
            SVGImageView(svgURL: URL(string: country.flag)!)
                .frame(width: 40, height: 30)
                .cornerRadius(5)
            VStack(alignment: .leading) {
                Text(country.name).bold().lineLimit(1).font(.title3)
                Text(country.region).lineLimit(1).font(.footnote)
            }
            
            Spacer()
            Button(action: {
                toggleFavorite()
            }) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(isFavorite ? .yellow : .gray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                toggleFavorite()
            }
            
        }

    }
}
