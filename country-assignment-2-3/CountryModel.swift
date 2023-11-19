//
//  CountryModel.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-18.
//

import Foundation
struct Country: Codable, Identifiable {


    var id: Int {
        return self.name.hashValue
    }
    
    let name: String
    let capital: String?
    let languages: [String]
    let population: Int
    let flag: String
    let region: String
    let area: Double?
    
}
