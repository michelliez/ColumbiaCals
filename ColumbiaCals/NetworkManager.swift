//
//  NetworkManager.swift
//  ColumbiaCals
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    static let baseURL = "https://columbiacals-backend.onrender.com/api"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchDiningHalls(completion: @escaping ([DiningHall]?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(NetworkManager.baseURL)/dining-halls") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(nil)
            return
        }
        
        print("📡 Fetching from: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Error: \(error)")
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    completion(nil)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode([APIDiningHall].self, from: data)
                    
                    let diningHalls = apiResponse.map { apiHall in
                        let foodItems = (apiHall.food_items_with_nutrition ?? []).compactMap { apiFood -> FoodItem? in
                            guard let name = apiFood.name,
                                  let calories = apiFood.calories,
                                  let protein = apiFood.protein,
                                  let carbs = apiFood.carbs,
                                  let fat = apiFood.fat,
                                  let sodium = apiFood.sodium else {
                                return nil
                            }
                            
                            return FoodItem(
                                name: name,
                                calories: calories,
                                protein: protein,
                                carbs: carbs,
                                fat: fat,
                                sodium: sodium,
                                fiber: apiFood.fiber,
                                sugar: apiFood.sugar,
                                servingSize: apiFood.serving_size ?? "1 serving",
                                grams: apiFood.grams,
                                category: apiFood.category ?? "Main"
                            )
                        }
                        
                        return DiningHall(
                            name: apiHall.name,
                            hours: apiHall.hours,
                            foodItems: foodItems
                        )
                    }
                    
                    print("✅ Loaded \(diningHalls.count) halls with full nutrition")
                    completion(diningHalls)
                    
                } catch {
                    self?.errorMessage = "Failed to parse data"
                    print("❌ Parse error: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }
}

// MARK: - API Response Models
struct APIDiningHall: Codable {
    let name: String
    let hours: String
    let food_items_with_nutrition: [APIFoodItem]?
}

struct APIFoodItem: Codable {
    let name: String?
    let calories: Int?
    let protein: Int?
    let carbs: Int?
    let fat: Int?
    let sodium: Int?
    let fiber: Int?
    let sugar: Int?
    let serving_size: String?
    let grams: Int?
    let category: String?
}