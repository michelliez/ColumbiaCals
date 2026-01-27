//
//  CartItem.swift
//  ColumbiaCals
//

import Foundation
import Combine

class CartItem: ObservableObject, Identifiable {
    let id = UUID()
    let foodItem: FoodItem
    @Published var quantity: Int = 1
    @Published var servingsMultiplier: Double = 1.0
    
    var totalCalories: Int {
        Int(Double(foodItem.calories) * servingsMultiplier * Double(quantity))
    }
    
    var totalProtein: Int {
        Int(Double(foodItem.protein) * servingsMultiplier * Double(quantity))
    }
    
    var totalCarbs: Int {
        Int(Double(foodItem.carbs) * servingsMultiplier * Double(quantity))
    }
    
    var totalFat: Int {
        Int(Double(foodItem.fat) * servingsMultiplier * Double(quantity))
    }
    
    var totalSodium: Int {
        Int(Double(foodItem.sodium) * servingsMultiplier * Double(quantity))
    }
    
    var displayServingSize: String {
        if servingsMultiplier == 1.0 {
            return foodItem.servingSize
        } else {
            return "\(String(format: "%.1f", servingsMultiplier))x \(foodItem.servingSize)"
        }
    }
    
    init(foodItem: FoodItem, servingsMultiplier: Double = 1.0) {
        self.foodItem = foodItem
        self.servingsMultiplier = servingsMultiplier
    }
}