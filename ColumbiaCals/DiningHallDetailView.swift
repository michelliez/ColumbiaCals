//
//  DiningHallDetailView.swift
//  ColumbiaCals - With Portion Adjustment
//

import SwiftUI

struct DiningHallDetailView: View {
    let diningHall: DiningHall
    @ObservedObject var cartVM: CartViewModel
    
    var categorizedItems: [String: [FoodItem]] {
        Dictionary(grouping: diningHall.foodItems, by: { $0.category })
    }
    
    var body: some View {
        List {
            if diningHall.foodItems.isEmpty {
                Text("This dining hall is currently closed.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(categorizedItems.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(categorizedItems[category] ?? []) { item in
                            FoodItemRow(foodItem: item, cartVM: cartVM)
                        }
                    }
                }
            }
        }
        .navigationTitle(diningHall.name)
    }
}

struct FoodItemRow: View {
    let foodItem: FoodItem
    @ObservedObject var cartVM: CartViewModel
    @State private var showingPortionSheet = false
    @State private var showingAddedAlert = false
    
    var itemInCart: Bool {
        cartVM.cartItems.contains { $0.foodItem.id == foodItem.id }
    }
    
    var body: some View {
        Button(action: {
            showingPortionSheet = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Food name
                    Text(foodItem.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    // Nutrition info
                    Text("\(foodItem.calories) cal  •  P: \(foodItem.protein)g  •  C: \(foodItem.carbs)g  •  F: \(foodItem.fat)g")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Serving size
                    Text(foodItem.servingSize)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: itemInCart ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(itemInCart ? .green : .blue)
                    .font(.title2)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPortionSheet) {
            PortionAdjustmentSheet(foodItem: foodItem, cartVM: cartVM, showingAddedAlert: $showingAddedAlert)
        }
        .overlay(
            Group {
                if showingAddedAlert {
                    Text("Added!")
                        .font(.caption)
                        .padding(8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.scale)
                }
            },
            alignment: .trailing
        )
    }
}

struct PortionAdjustmentSheet: View {
    let foodItem: FoodItem
    @ObservedObject var cartVM: CartViewModel
    @Binding var showingAddedAlert: Bool
    @Environment(\.dismiss) var dismiss
    
    // Two input modes
    @State private var adjustmentMode: AdjustmentMode = .servings
    @State private var servings: String = "1.0"
    @State private var targetCalories: String = ""
    
    enum AdjustmentMode {
        case servings
        case calories
    }
    
    var servingsMultiplier: Double {
        if adjustmentMode == .servings {
            return Double(servings) ?? 1.0
        } else {
            // Calculate servings from target calories
            let target = Double(targetCalories) ?? Double(foodItem.calories)
            return target / Double(foodItem.calories)
        }
    }
    
    var adjustedCalories: Int {
        Int(Double(foodItem.calories) * servingsMultiplier)
    }
    
    var adjustedProtein: Int {
        Int(Double(foodItem.protein) * servingsMultiplier)
    }
    
    var adjustedCarbs: Int {
        Int(Double(foodItem.carbs) * servingsMultiplier)
    }
    
    var adjustedFat: Int {
        Int(Double(foodItem.fat) * servingsMultiplier)
    }
    
    var adjustedSodium: Int {
        Int(Double(foodItem.sodium) * servingsMultiplier)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Food name
                Text(foodItem.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("Standard serving: \(foodItem.servingSize)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Mode picker
                Picker("Adjustment Mode", selection: $adjustmentMode) {
                    Text("By Servings").tag(AdjustmentMode.servings)
                    Text("By Calories").tag(AdjustmentMode.calories)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Input section
                VStack(spacing: 15) {
                    if adjustmentMode == .servings {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number of Servings")
                                .font(.headline)
                            
                            TextField("1.0", text: $servings)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .keyboardType(.decimalPad)
                            
                            // Quick buttons
                            HStack(spacing: 10) {
                                QuickServingButton(value: "0.5", servings: $servings)
                                QuickServingButton(value: "1.0", servings: $servings)
                                QuickServingButton(value: "1.5", servings: $servings)
                                QuickServingButton(value: "2.0", servings: $servings)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Calories")
                                .font(.headline)
                            
                            TextField("\(foodItem.calories)", text: $targetCalories)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .keyboardType(.numberPad)
                            
                            Text("= \(String(format: "%.2f", servingsMultiplier)) servings")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Nutrition preview
                VStack(spacing: 12) {
                    Text("You'll be eating:")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        NutritionBadge(label: "Cal", value: adjustedCalories, color: .orange)
                        NutritionBadge(label: "Protein", value: adjustedProtein, unit: "g", color: .blue)
                        NutritionBadge(label: "Carbs", value: adjustedCarbs, unit: "g", color: .green)
                        NutritionBadge(label: "Fat", value: adjustedFat, unit: "g", color: .red)
                    }
                    
                    Text("\(String(format: "%.2f", servingsMultiplier))x \(foodItem.servingSize)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Add to cart button
                Button(action: {
                    addToCart()
                }) {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
        .onAppear {
            targetCalories = String(foodItem.calories)
        }
    }
    
    func addToCart() {
        // Create adjusted food item
        let adjustedItem = FoodItem(
            name: servingsMultiplier == 1.0 ? foodItem.name : "\(foodItem.name) (\(String(format: "%.2f", servingsMultiplier))x)",
            calories: adjustedCalories,
            protein: adjustedProtein,
            carbs: adjustedCarbs,
            fat: adjustedFat,
            sodium: adjustedSodium,
            fiber: foodItem.fiber,
            sugar: foodItem.sugar,
            servingSize: servingsMultiplier == 1.0 ? foodItem.servingSize : "\(String(format: "%.2f", servingsMultiplier))x \(foodItem.servingSize)",
            grams: foodItem.grams,
            category: foodItem.category
        )
        
        cartVM.addToCart(foodItem: adjustedItem)
        
        // Show added alert
        dismiss()
        withAnimation {
            showingAddedAlert = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingAddedAlert = false
            }
        }
    }
}

struct QuickServingButton: View {
    let value: String
    @Binding var servings: String
    
    var body: some View {
        Button(action: {
            servings = value
        }) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

struct NutritionBadge: View {
    let label: String
    let value: Int
    var unit: String = ""
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)\(unit)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NavigationView {
        DiningHallDetailView(
            diningHall: DiningHall.sampleData[0],
            cartVM: CartViewModel()
        )
    }
}