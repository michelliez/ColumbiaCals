//
//  CartView.swift
//  ColumbiaCals - With Custom Food in Cart
//

import SwiftUI

struct CartView: View {
    @ObservedObject var cartVM: CartViewModel
    @State private var showingGoalsSheet = false
    @State private var showingCustomFoodSheet = false
    @State private var showingCheckoutAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Calories & Protein Summary
            MacroSummaryView(cartVM: cartVM, showingSheet: $showingGoalsSheet)
                .padding()
                .background(Color(.systemGray6))
            
            if cartVM.cartItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("Your cart is empty")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Add items from dining halls or custom foods")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showingCustomFoodSheet = true
                    }) {
                        Label("Add Custom Food", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(cartVM.cartItems) { cartItem in
                        CartItemRowView(cartItem: cartItem, cartVM: cartVM)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            cartVM.removeFromCart(cartItem: cartVM.cartItems[index])
                        }
                    }
                    
                    // Add Custom Food button at bottom of list
                    Section {
                        Button(action: {
                            showingCustomFoodSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Add Custom Food")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                    }
                }
                
                Button(action: {
                    showingCheckoutAlert = true
                }) {
                    Text("Checkout - \(cartVM.totalCalories) cal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cartVM.isOverLimit ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle("My Cart")
        .toolbar {
            if !cartVM.cartItems.isEmpty {
                ToolbarItem(placement: .automatic) {
                    Button("Clear All") {
                        cartVM.clearCart()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingGoalsSheet) {
            GoalsSheet(cartVM: cartVM)
        }
        .sheet(isPresented: $showingCustomFoodSheet) {
            CustomFoodSheet(cartVM: cartVM)
        }
        .alert("Order Complete! 🎉", isPresented: $showingCheckoutAlert) {
            Button("Clear Cart", role: .destructive) {
                cartVM.clearCart()
            }
            Button("Keep Shopping", role: .cancel) { }
        } message: {
            Text("""
            Calories: \(cartVM.totalCalories) / \(cartVM.calorieLimit)
            Protein: \(cartVM.totalProtein)g / \(cartVM.proteinGoal)g
            Carbs: \(cartVM.totalCarbs)g
            Fat: \(cartVM.totalFat)g
            Sodium: \(cartVM.totalSodium)mg
            """)
        }
    }
}


struct MacroSummaryView: View {
    @ObservedObject var cartVM: CartViewModel
    @Binding var showingSheet: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // MAIN FOCUS: Calories Progress
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calories")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(cartVM.totalCalories)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(cartVM.isOverLimit ? .red : .primary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showingSheet = true }) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Goal")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            HStack(spacing: 4) {
                                Text("\(cartVM.calorieLimit)")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                ProgressBar(
                    current: cartVM.totalCalories,
                    goal: cartVM.calorieLimit,
                    color: cartVM.isOverLimit ? .red : .green
                )
            }
            
            Divider()
            
            // SECONDARY: Protein Progress (slightly smaller)
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Protein")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(cartVM.totalProtein)g")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(cartVM.proteinGoal)g")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                ProgressBar(
                    current: cartVM.totalProtein,
                    goal: cartVM.proteinGoal,
                    color: .blue
                )
            }
            
            // SUBTLE: Other macros in small text
            HStack(spacing: 15) {
                Text("Carbs: \(cartVM.totalCarbs)g")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("•")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("Fat: \(cartVM.totalFat)g")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("•")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("Sodium: \(cartVM.totalSodium)mg")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ProgressBar: View {
    let current: Int
    let goal: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(color)
                    .frame(
                        width: min(CGFloat(current) / CGFloat(goal) * geometry.size.width, geometry.size.width),
                        height: 8
                    )
                    .cornerRadius(4)
            }
        }
        .frame(height: 8)
    }
}

struct CartItemRowView: View {
    @ObservedObject var cartItem: CartItem
    @ObservedObject var cartVM: CartViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // MAIN: Food name
                Text(cartItem.foodItem.name)
                    .font(.body)
                
                // MAIN: Calories (prominent)
                Text("\(cartItem.totalCalories) cal")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .bold()
                
                // SUBTLE: Other nutrition (small gray text)
                Text("P: \(cartItem.totalProtein)g  •  C: \(cartItem.totalCarbs)g  •  F: \(cartItem.totalFat)g")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    cartVM.decrementQuantity(for: cartItem)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                Text("\(cartItem.quantity)")
                    .font(.headline)
                    .frame(minWidth: 30)
                
                Button(action: {
                    cartVM.incrementQuantity(for: cartItem)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

struct GoalsSheet: View {
    @ObservedObject var cartVM: CartViewModel
    @Environment(\.dismiss) var dismiss
    @State private var newCalorieLimit: String = ""
    @State private var newProteinGoal: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("Set Your Daily Goals")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Calorie Goal
                VStack(spacing: 10) {
                    Text("Calorie Limit")
                        .font(.headline)
                    
                    TextField("Calories", text: $newCalorieLimit)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)
                    
                    HStack(spacing: 15) {
                        QuickButton(title: "1500", value: 1500, binding: $newCalorieLimit)
                        QuickButton(title: "2000", value: 2000, binding: $newCalorieLimit)
                        QuickButton(title: "2500", value: 2500, binding: $newCalorieLimit)
                        QuickButton(title: "3000", value: 3000, binding: $newCalorieLimit)
                    }
                }
                .padding()
                
                Divider()
                
                // Protein Goal
                VStack(spacing: 10) {
                    Text("Protein Goal (grams)")
                        .font(.headline)
                    
                    TextField("Protein (g)", text: $newProteinGoal)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)
                    
                    HStack(spacing: 15) {
                        QuickButton(title: "50g", value: 50, binding: $newProteinGoal)
                        QuickButton(title: "100g", value: 100, binding: $newProteinGoal)
                        QuickButton(title: "150g", value: 150, binding: $newProteinGoal)
                        QuickButton(title: "200g", value: 200, binding: $newProteinGoal)
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    if let calorieLimit = Int(newCalorieLimit), calorieLimit > 0 {
                        cartVM.updateCalorieLimit(calorieLimit)
                    }
                    if let proteinGoal = Int(newProteinGoal), proteinGoal > 0 {
                        cartVM.updateProteinGoal(proteinGoal)
                    }
                    dismiss()
                }) {
                    Text("Save Goals")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
        .onAppear {
            newCalorieLimit = String(cartVM.calorieLimit)
            newProteinGoal = String(cartVM.proteinGoal)
        }
    }
}

struct QuickButton: View {
    let title: String
    let value: Int
    @Binding var binding: String
    
    var body: some View {
        Button(action: {
            binding = String(value)
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationView {
        CartView(cartVM: CartViewModel())
    }
}