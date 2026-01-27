//
//  DiningHall.swift
//  ColumbiaCals
//

import Foundation

// MARK: - Main Models
struct DiningHall: Identifiable, Codable {
    let id = UUID()
    let name: String
    let hours: String
    let foodItems: [FoodItem]
    
    enum CodingKeys: String, CodingKey {
        case name
        case hours
        case foodItems = "food_items_with_nutrition"
    }
}

struct FoodItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let sodium: Int
    let fiber: Int?
    let sugar: Int?
    let servingSize: String
    let grams: Int?
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fat, sodium, fiber, sugar, category, grams
        case servingSize = "serving_size"
    }
}

// MARK: - Open/Closed Logic
extension DiningHall {
    var isCurrentlyOpen: Bool {
        // Handle special cases
        if hours.lowercased().contains("closed") {
            return false
        }
        
        // Parse hours like "5:00 PM to 9:00 PM"
        let components = hours.lowercased().split(separator: "to")
        guard components.count == 2 else { return false }
        
        let openTimeStr = String(components[0]).trimmingCharacters(in: .whitespaces)
        let closeTimeStr = String(components[1]).trimmingCharacters(in: .whitespaces)
        
        let now = Date()
        let calendar = Calendar.current
        
        // Try to parse the times
        guard let openTime = parseTime(openTimeStr),
              let closeTime = parseTime(closeTimeStr) else {
            return false
        }
        
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        // Handle cases where closing time is past midnight
        if closeTime < openTime {
            // e.g., "10:00 PM to 2:00 AM"
            return currentMinutes >= openTime || currentMinutes <= closeTime
        } else {
            return currentMinutes >= openTime && currentMinutes <= closeTime
        }
    }
    
    private func parseTime(_ timeStr: String) -> Int? {
        // Parse "5:00 PM" or "9:00 AM" into minutes since midnight
        let components = timeStr.components(separatedBy: ":")
        guard components.count == 2,
              let hour = Int(components[0].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        
        let minutePart = components[1].trimmingCharacters(in: .whitespaces)
        let minuteString = minutePart.components(separatedBy: " ")[0]
        let minutes = Int(minuteString) ?? 0
        
        let isPM = timeStr.lowercased().contains("pm")
        var actualHour = hour
        
        if isPM && hour != 12 {
            actualHour += 12
        } else if !isPM && hour == 12 {
            actualHour = 0
        }
        
        return actualHour * 60 + minutes
    }
    
    var statusText: String {
        if isCurrentlyOpen {
            return "Open now"
        } else if hours.lowercased().contains("closed") {
            return "Closed"
        } else {
            return "Closed now"
        }
    }
}

// MARK: - Sample Data
extension DiningHall {
    static let sampleData: [DiningHall] = [
        DiningHall(
            name: "John Jay",
            hours: "7:30 AM to 10:00 PM",
            foodItems: [
                FoodItem(
                    name: "Scrambled Eggs",
                    calories: 155,
                    protein: 13,
                    carbs: 1,
                    fat: 10,
                    sodium: 124,
                    fiber: nil,
                    sugar: nil,
                    servingSize: "2 eggs",
                    grams: 100,
                    category: "Main"
                ),
                FoodItem(
                    name: "Bacon",
                    calories: 360,
                    protein: 19,
                    carbs: 0,
                    fat: 27,
                    sodium: 1080,
                    fiber: nil,
                    sugar: nil,
                    servingSize: "2-3 pieces",
                    grams: 60,
                    category: "Main"
                )
            ]
        ),
        DiningHall(
            name: "Ferris",
            hours: "11:00 AM to 8:00 PM",
            foodItems: [
                FoodItem(
                    name: "Grilled Chicken",
                    calories: 165,
                    protein: 31,
                    carbs: 0,
                    fat: 4,
                    sodium: 74,
                    fiber: nil,
                    sugar: nil,
                    servingSize: "4 oz",
                    grams: 115,
                    category: "Main"
                )
            ]
        ),
        DiningHall(
            name: "JJ's Place",
            hours: "Closed for breakfast",
            foodItems: []
        )
    ]
}