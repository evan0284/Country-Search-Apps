//
//  ContentView.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-12.
//

//import SwiftSVG
import SwiftUI
import SVGKit
import Charts



struct ContentView: View {
    
    @State var countries: [Country] = []
    @State private var searchText: String = ""
    @State private var favoriteCountries: [Country] = []
    
    
    @State private var selectedRegion: String = ""
    @State private var selectedSortOption: SortOption = .alphabetical
    
    

    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case population = "Population"
        case region = "Region" // New case for sorting by region

    }

    var filteredCountries: [Country] {
        var filtered = countries

        
        if !selectedRegion.isEmpty {
            filtered = filtered.filter { $0.region == selectedRegion }
        }
        // Filter based on search text
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        switch selectedSortOption {
        case .alphabetical:
            filtered.sort { $0.name < $1.name }
        case .population:
            filtered.sort { $0.population > $1.population }
        case .region:
            break
        }

        
        return filtered

        
    }
    
    

    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    SearchBar(text: $searchText)
                        .padding([.horizontal])
                    
                    Picker("Sort by", selection: $selectedSortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.horizontal, .bottom])
                    
                    if selectedSortOption == .region {
                        Picker("Select a region", selection: $selectedRegion) {
                            ForEach(Array(Set(countries.map { $0.region }).sorted()), id: \.self) { region in
                                Text(region).tag(region)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    

                    List {
                        
                        Section(header: Text("Country List")) {
                            ForEach(filteredCountries) { country in
                                NavigationLink(destination: PostDetailView(country: country, isFavorite: isFavorite(country: country), toggleFavorite: {toggleFavorite2(country: country)})) {
                                    CountryRow(country: country, isFavorite: isFavorite(country: country), toggleFavorite: {toggleFavorite2(country: country)})
                                }
                            }
                        }
                    }
                    
                    .navigationTitle("Country App")
                    .onAppear {
                        fetchData()
                    }
                }
            }
            .tabItem {
                VStack {
                    Label("All Countries", systemImage: "globe")
                }
            }
            NavigationView {
                if favoriteCountries.isEmpty {
                    VStack {
                        Text("You haven't added any favorite countries yet")
                            .foregroundColor(.gray)
                            
                        Spacer()
                    }
                    .navigationTitle("Favorites")
                } else {
                    List {
                        ForEach(favoriteCountries) { country in
                            NavigationLink(destination: PostDetailView(country: country, isFavorite: isFavorite(country: country), toggleFavorite: { toggleFavorite2(country: country) })) {
                                CountryRow(country: country, isFavorite: isFavorite(country: country), toggleFavorite: { toggleFavorite2(country: country) })
                            }
                        }
                    }
                    .navigationTitle("Favorites")
                }
            }
            .tabItem {
                Label("Favorites", systemImage: "star.fill")

                
            }
            NavigationView {

                    ChartsView(countries: countries)
                
                .navigationTitle("Charts")
            }
            .tabItem {
                Label("Charts", systemImage: "chart.bar.fill")
            }
            
        }
        
    }


    struct ChartsView: View {
        let countries: [Country]

        var body: some View {
            VStack {
                if !countries.isEmpty {
                    
                    let sortedByPopulation = countries.sorted(by: { $0.population > $1.population })
                    let topFive = Array(sortedByPopulation.prefix(5))
                    
                    
                    
                    VStack {
                        Text("5 Most Populated Country")
                        Chart{
                            ForEach(topFive){ country in
                                BarMark(x: .value("Type", country.name), y: .value("Population", country.population))
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                    }
                    .padding(20)
                    
                    
                    let continentTop5Countries = Dictionary(grouping: countries, by: { $0.region })
                        .mapValues { $0.count }
                        .sorted(by: { $0.value > $1.value })
                        .prefix(5)
                    VStack{
                        Text("Top 5 Continents by Number of Countries")
                        Chart {
                            ForEach(continentTop5Countries.sorted(by: { $0.key < $1.key }), id: \.key) { region, count in
                                SectorMark(angle: .value(region, Double(count)),
                                           innerRadius: .ratio(0.3), angularInset: 2)
                                
                                .annotation(position: .overlay){
                                    Text("\(region)")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }.cornerRadius(5)
                                
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                    }
                    .padding(10)
                    
                } else {
                    Text("Loading Data...")
                }
            }
            .navigationTitle("Charts")
        }
    }

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

    struct PostDetailView: View {
        let country: Country
        let isFavorite: Bool
        let toggleFavorite: () -> Void

        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                
                SVGBigImageView(svgURL: URL(string: country.flag)!)
                    .frame(width: 300, height: 200)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                if let capital = country.capital {
                    Text("Capital: \(capital)")
                }
            

                Text("Languages: \(country.languages.joined(separator: ", "))")
                Text("Population: \(country.population)")
                Text("Flag: \(country.flag)")
                Text("Region: \(country.region)")
                
                
                if let area = country.area {
                    Text("Area: \(area)")
                }
            
                Button(action: {
                    toggleFavorite()
                }) {
                    if isFavorite {
                        Text("Remove from Favorites")
                    } else {
                        Text("Add to Favorites")
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("\(country.name)")
        }
    }
    
    
    
    
    //MARK: Model
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
        
    private func fetchData() {
        //Parse URL
        
        guard let url = URL(string: "https://raw.githubusercontent.com/shah0150/data/main/countries_data.json") else { return }
        
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {

                do {
                    //Parse JSON
                    let decodedData = try JSONDecoder().decode([Country].self, from: data)
                    self.countries = decodedData
                } catch {
                            
                    //Print JSON decoding error
                    print("Error decoding JSON: \(error)")
                    
                }
            } else if let error = error {
                //Print API call error
                print("Error fetching data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func toggleFavorite2(country: Country) {
        if isFavorite(country: country) {
            favoriteCountries.removeAll { $0.id == country.id }
        } else {
            favoriteCountries.append(country)
        }
    }
    
    private func isFavorite(country: Country) -> Bool {
        return favoriteCountries.contains { $0.id == country.id }
    }
}

#Preview {
    ContentView()
}
