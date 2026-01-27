//
//  SettingsView.swift
//  ColumbiaCals
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var cartVM: CartViewModel
    
    var body: some View {
        Form {
            Section(header: Text("About CalRoarie")) {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.1")
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Created by")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Michelle Zhou")
                        .font(.body)
                    
                    Text("Carolyn Lee")
                        .font(.body)
                    
                    Text("Columbia University Class of 2029")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Daily Goals")) {
                HStack {
                    Text("Calorie Limit")
                    Spacer()
                    Text("\(cartVM.calorieLimit) cal")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Protein Goal")
                    Spacer()
                    Text("\(cartVM.proteinGoal)g")
                        .foregroundColor(.gray)
                }
                
                Text("Tap the settings icon in your cart to adjust your goals")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("Actions")) {
                Button(action: {
                    cartVM.clearCart()
                }) {
                    HStack {
                        Text("Clear Cart")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Features")) {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "fork.knife", text: "Real-time menus from all Columbia dining halls")
                    FeatureRow(icon: "chart.bar.fill", text: "Complete nutrition tracking (calories, protein, carbs, fat)")
                    FeatureRow(icon: "slider.horizontal.3", text: "Adjustable portion sizes")
                    FeatureRow(icon: "target", text: "Daily calorie and protein goals")
                    FeatureRow(icon: "plus.circle.fill", text: "Add custom foods from off-campus")
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Data Sources")) {
                Text("Dining hall menus from Columbia Dining Services (LionDine)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Nutrition data from USDA FoodData Central")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("Disclaimer")) {
                Text("Nutrition information is estimated and may vary from actual servings. This app is not affiliated with Columbia University Dining Services.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("Feedback")) {
                Link(destination: URL(string: "mailto:myz2110@columbia.edu?subject=ColumbiaCals%20Feedback")!) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                        Text("Send Feedback")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Made with ❤️ at Columbia")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("© 2026 Michelle Zhou & Carolyn Lee")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Settings")
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView(cartVM: CartViewModel())
    }
}
