//
//  ContentView.swift
//  country-assignment-2-3
//
//  Created by Evans on 2023-11-12.
//

//import SwiftSVG
import SwiftUI
import SVGKit

struct ContentView: View {
    
    @State var countries: [Country] = []
    @State private var searchText: String = ""
    @State private var favoriteCountries: [Country] = []
    
    
    @State private var selectedRegion: String = ""
    @State private var selectedSortOption: SortOption = .alphabetical
    
    @State private var isShowingErrorSheet: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var isFetchingData: Bool = false


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
                    .onAppear {
                        Task {
                            do {
                                try await fetchData()
                            } catch {
                                errorMessage = "Failed to fetch data. Please check your internet connection and try again."
                                isShowingErrorSheet = true
                            }
                        }
                    }
                    .overlay(
                        Group {
                            if isFetchingData {
                                ProgressView("Fetching Data...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .foregroundColor(.blue)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                            }
                        }
                    )
                    .sheet(isPresented: $isShowingErrorSheet) {
                        ErrorSheet(errorMessage: errorMessage, isShowingErrorSheet: $isShowingErrorSheet)
                    }
                
                }
                .searchable(text: $searchText)
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

    
    struct ErrorSheet: View {
        let errorMessage: String
        @Binding var isShowingErrorSheet: Bool

        var body: some View {
            VStack {
                Text(errorMessage)
                    .padding()
                Button("OK") {
                    isShowingErrorSheet = false
                }
                .padding()
            }
            .padding()
        }
    }
        
    private func fetchData() async throws {
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
                throw error
            }
        } catch {
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    print("No internet connection.")
                default:
                    print("Network error: \(urlError.localizedDescription)")
                    throw error
                }
            } else {
                print("Error: \(error.localizedDescription)")
                throw error
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
