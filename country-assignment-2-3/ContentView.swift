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
        case region = "Region"
    }

    var filteredCountries: [Country] {
        var filtered = countries

        if selectedRegion != "Worldwide" && !selectedRegion.isEmpty {
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
                        let allRegions = Array(Set(countries.map { $0.region }).sorted())
                        let regionsWithWorldwide = ["Worldwide"] + allRegions
                        
                        Picker("Select a region", selection: $selectedRegion) {
                            ForEach(regionsWithWorldwide, id: \.self) { region in
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
                    .task {
                        await fetchData()
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
                                        Text("\(region)")
                                            .font(.headline)
                                            .foregroundColor(.white)
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
//            .background(Color.gray.opacity(0.1))
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
            VStack(alignment: .center, spacing: 16) {
                
                SVGBigImageView(svgURL: URL(string: country.flag)!)
                    .frame(width: 350, height: 200)
//                    .cornerRadius(12)
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
        
    private func fetchData() async {
        guard let url = URL(string: "https://raw.githubusercontent.com/shah0150/data/main/countries_data.json") else {
            print("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            do {
                let decodedData = try JSONDecoder().decode([Country].self, from: data)
                self.countries = decodedData
            } catch {
                print("Error decoding JSON: \(error)")
 
            }
        } catch {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    print("No internet connection.")

                default:
                    print("Network error: \(urlError.localizedDescription)")
        
                }
            } else {
                print("Error: \(error.localizedDescription)")
            }
        }
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
