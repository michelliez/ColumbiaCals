//
//  CustomFoodSheet.swift
//  ColumbiaCals
//

import SwiftUI

struct CustomFoodSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var cartVM: CartViewModel
    
    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var sodium = ""
    @State private var servingSize = ""
    
    // USDA Search
    @State private var showingUSDASearch = false
    @State private var searchQuery = ""
    @State private var searchResults: [USDAFoodItem] = []
    @State private var isSearching = false
    @State private var searchError: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Information")) {
                    TextField("Food Name", text: $foodName)
                    TextField("Serving Size (e.g., 1 cup)", text: $servingSize)
                    
                    Button(action: {
                        showingUSDASearch = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search USDA Database")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Nutrition (per serving)")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Sodium (mg)")
                        Spacer()
                        TextField("0", text: $sodium)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section {
                    Button(action: addCustomFood) {
                        Text("Add to Cart")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Custom Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingUSDASearch) {
                USDASearchView(
                    searchQuery: $searchQuery,
                    onSelect: { usdaFood in
                        fillFromUSDA(usdaFood)
                        showingUSDASearch = false
                    }
                )
            }
        }
    }
    
    var isFormValid: Bool {
        !foodName.isEmpty &&
        !calories.isEmpty &&
        !protein.isEmpty &&
        !carbs.isEmpty &&
        !fat.isEmpty &&
        !sodium.isEmpty
    }
    
    func addCustomFood() {
        guard let cal = Int(calories),
              let prot = Int(protein),
              let carb = Int(carbs),
              let f = Int(fat),
              let sod = Int(sodium) else {
            return
        }
        
        let customFood = FoodItem(
            name: foodName,
            calories: cal,
            protein: prot,
            carbs: carb,
            fat: f,
            sodium: sod,
            fiber: nil,
            sugar: nil,
            servingSize: servingSize.isEmpty ? "1 serving" : servingSize,
            grams: nil,
            category: "Custom"
        )
        
        cartVM.addToCart(foodItem: customFood)
        dismiss()
    }
    
    func fillFromUSDA(_ usdaFood: USDAFoodItem) {
        foodName = usdaFood.description
        calories = String(usdaFood.calories)
        protein = String(usdaFood.protein)
        carbs = String(usdaFood.carbs)
        fat = String(usdaFood.fat)
        sodium = String(usdaFood.sodium)
        servingSize = usdaFood.servingSize
    }
}

// MARK: - USDA Search View
struct USDASearchView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var searchQuery: String
    var onSelect: (USDAFoodItem) -> Void
    
    @State private var searchResults: [USDAFoodItem] = []
    @State private var isSearching = false
    @State private var searchError: String?
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search foods...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .onSubmit {
                            searchUSDA()
                        }
                    
                    if !searchQuery.isEmpty {
                        Button(action: {
                            searchQuery = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                
                // Results
                if isSearching {
                    ProgressView("Searching USDA database...")
                        .padding()
                    Spacer()
                } else if let error = searchError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        Button("Try Again") {
                            searchUSDA()
                        }
                    }
                    .padding()
                    Spacer()
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No results found")
                            .foregroundColor(.gray)
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Spacer()
                } else if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Search the USDA food database")
                            .foregroundColor(.gray)
                        Text("Enter a food name above")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(searchResults) { food in
                        Button(action: {
                            onSelect(food)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(food.description)
                                    .font(.headline)
                                
                                Text(food.servingSize)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 12) {
                                    NutritionBadge(label: "Cal", value: food.calories, unit: "", color: .orange)
                                    NutritionBadge(label: "P", value: food.protein, unit: "g", color: .blue)
                                    NutritionBadge(label: "C", value: food.carbs, unit: "g", color: .green)
                                    NutritionBadge(label: "F", value: food.fat, unit: "g", color: .red)
                                }
                                .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("USDA Food Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func searchUSDA() {
        guard !searchQuery.isEmpty else { return }
        
        isSearching = true
        searchError = nil
        
        USDAAPIService.shared.searchFoods(query: searchQuery) { result in
            DispatchQueue.main.async {
                isSearching = false
                
                switch result {
                case .success(let foods):
                    searchResults = foods
                    if foods.isEmpty {
                        searchError = "No results found for '\(searchQuery)'"
                    }
                case .failure(let error):
                    searchError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - USDA Models
struct USDAFoodItem: Identifiable {
    let id = UUID()
    let fdcId: Int
    let description: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let sodium: Int
    let servingSize: String
}

// MARK: - USDA API Service
class USDAAPIService {
    static let shared = USDAAPIService()
    private let apiKey = "ewKS5i9HHXzrJfWRzK88q9EcjJfBT2ufivWOx6BK" // Your USDA API key
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    
    func searchFoods(query: String, completion: @escaping (Result<[USDAFoodItem], Error>) -> Void) {
        let endpoint = "\(baseURL)/foods/search"
        
        var components = URLComponents(string: endpoint)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "10"),
            URLQueryItem(name: "dataType", value: "Survey (FNDDS)")
        ]
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(USDASearchResponse.self, from: data)
                
                let foods = response.foods.compactMap { food -> USDAFoodItem? in
                    guard let calories = food.foodNutrients.first(where: { $0.nutrientName == "Energy" })?.value,
                          let protein = food.foodNutrients.first(where: { $0.nutrientName == "Protein" })?.value,
                          let carbs = food.foodNutrients.first(where: { $0.nutrientName == "Carbohydrate, by difference" })?.value,
                          let fat = food.foodNutrients.first(where: { $0.nutrientName == "Total lipid (fat)" })?.value else {
                        return nil
                    }
                    
                    let sodium = food.foodNutrients.first(where: { $0.nutrientName == "Sodium, Na" })?.value ?? 0
                    
                    let servingSize = food.servingSize != nil && food.servingSizeUnit != nil
                        ? "\(Int(food.servingSize!)) \(food.servingSizeUnit!)"
                        : "100g"
                    
                    return USDAFoodItem(
                        fdcId: food.fdcId,
                        description: food.description,
                        calories: Int(calories),
                        protein: Int(protein),
                        carbs: Int(carbs),
                        fat: Int(fat),
                        sodium: Int(sodium),
                        servingSize: servingSize
                    )
                }
                
                completion(.success(foods))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - USDA API Response Models
struct USDASearchResponse: Codable {
    let foods: [USDAFood]
}

struct USDAFood: Codable {
    let fdcId: Int
    let description: String
    let foodNutrients: [USDANutrient]
    let servingSize: Double?
    let servingSizeUnit: String?
}

struct USDANutrient: Codable {
    let nutrientName: String
    let value: Double
}

#Preview {
    CustomFoodSheet(cartVM: CartViewModel())
}