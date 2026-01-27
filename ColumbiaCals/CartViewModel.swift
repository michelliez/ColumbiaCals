//
//  CartViewModel.swift
//  ColumbiaCals
//

import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var calorieLimit: Int = 2000
    @Published var proteinGoal: Int = 100  // NEW: Protein goal in grams
    
    var totalCalories: Int {
        cartItems.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProtein: Int {
        cartItems.reduce(0) { $0 + $1.totalProtein }
    }
    
    var totalCarbs: Int {
        cartItems.reduce(0) { $0 + $1.totalCarbs }
    }
    
    var totalFat: Int {
        cartItems.reduce(0) { $0 + $1.totalFat }
    }
    
    var totalSodium: Int {
        cartItems.reduce(0) { $0 + $1.totalSodium }
    }
    
    var remainingCalories: Int {
        calorieLimit - totalCalories
    }
    
    var remainingProtein: Int {
        proteinGoal - totalProtein
    }
    
    var isOverLimit: Bool {
        totalCalories > calorieLimit
    }
    
    var proteinProgress: Double {
        Double(totalProtein) / Double(proteinGoal)
    }
    
    // Macros percentages (for pie chart or breakdown)
    var carbsPercentage: Int {
        let totalCals = (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9)
        guard totalCals > 0 else { return 0 }
        return Int(Double(totalCarbs * 4) / Double(totalCals) * 100)
    }
    
    var proteinPercentage: Int {
        let totalCals = (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9)
        guard totalCals > 0 else { return 0 }
        return Int(Double(totalProtein * 4) / Double(totalCals) * 100)
    }
    
    var fatPercentage: Int {
        let totalCals = (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9)
        guard totalCals > 0 else { return 0 }
        return Int(Double(totalFat * 9) / Double(totalCals) * 100)
    }
    
    func addToCart(foodItem: FoodItem) {
        if let existingItem = cartItems.first(where: { $0.foodItem.id == foodItem.id }) {
            existingItem.quantity += 1
            objectWillChange.send()
        } else {
            let newItem = CartItem(foodItem: foodItem)
            cartItems.append(newItem)
        }
    }
    
    func removeFromCart(cartItem: CartItem) {
        cartItems.removeAll { $0.id == cartItem.id }
    }
    
    func incrementQuantity(for item: CartItem) {
        item.quantity += 1
        objectWillChange.send()
    }
    
    func decrementQuantity(for item: CartItem) {
        if item.quantity > 1 {
            item.quantity -= 1
            objectWillChange.send()
        } else {
            removeFromCart(cartItem: item)
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func updateCalorieLimit(_ newLimit: Int) {
        calorieLimit = newLimit
    }
    
    func updateProteinGoal(_ newGoal: Int) {
        proteinGoal = newGoal
    }
}