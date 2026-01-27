//
//  DiningHallsListView.swift
//  ColumbiaCals
//

import SwiftUI

struct DiningHallsListView: View {
    @StateObject private var cartVM = CartViewModel()
    @StateObject private var networkManager = NetworkManager()
    
    @State private var diningHalls: [DiningHall] = []
    @State private var showingRefreshAlert = false
    @State private var useRealData = false
    @State private var loadingStartTime: Date?
    @State private var showColdStartMessage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if diningHalls.isEmpty && !networkManager.isLoading {
                    // Show empty state while loading
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading dining halls...")
                            .foregroundColor(.gray)
                    }
                } else {
                    List(diningHalls) { hall in
                        NavigationLink(destination: DiningHallDetailView(diningHall: hall, cartVM: cartVM)) {
                            DiningHallRowView(diningHall: hall)
                        }
                        .disabled(!hall.isCurrentlyOpen && hall.foodItems.isEmpty)
                    }
                }
                
                // Loading overlay with cold start message
                if networkManager.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            
                            Text("Fetching latest menus...")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if showColdStartMessage {
                                VStack(spacing: 10) {
                                    Divider()
                                        .background(Color.white.opacity(0.3))
                                        .padding(.horizontal, 20)
                                    
                                    Text("Hang tight! Our server is starting up.")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.95))
                                        .multilineTextAlignment(.center)
                                    
                                    Text("This happens when no one's used the app recently.")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Text("Takes about 30 seconds...")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.85))
                                        .padding(.top, 2)
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.2), radius: 10)
                        )
                        .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle("CalRoarie")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: CartView(cartVM: cartVM)) {
                        HStack {
                            Image(systemName: "cart.fill")
                            if !cartVM.cartItems.isEmpty {
                                Text("\(cartVM.cartItems.count)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: SettingsView(cartVM: cartVM)) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        diningHalls = DiningHall.sampleData
                        useRealData = false
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .refreshable {
                refreshFromAPI()
            }
            .alert("Menu Updated", isPresented: $showingRefreshAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if useRealData {
                    Text("Loaded \(diningHalls.count) dining halls from server")
                } else {
                    Text("Failed to load from server. Check your connection or try again in a moment.")
                }
            }
            .onAppear {
                // Auto-fetch on app launch
                if diningHalls.isEmpty {
                    print("🚀 App launched - fetching menus...")
                    refreshFromAPI()
                }
            }
            .onChange(of: networkManager.isLoading) { isLoading in
                if isLoading {
                    // Start timer when loading begins
                    loadingStartTime = Date()
                    showColdStartMessage = false
                    
                    // Show cold start message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        if networkManager.isLoading {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showColdStartMessage = true
                            }
                        }
                    }
                } else {
                    // Reset when loading completes
                    loadingStartTime = nil
                    showColdStartMessage = false
                }
            }
        }
    }
    
    func refreshFromAPI() {
        print("🔄 Refreshing menu data...")
        
        networkManager.fetchDiningHalls { fetchedHalls in
            if let halls = fetchedHalls, !halls.isEmpty {
                diningHalls = halls
                useRealData = true
                showingRefreshAlert = true
                print("✅ Updated with \(halls.count) dining halls")
            } else {
                // Fallback to sample data only if fetch fails
                diningHalls = DiningHall.sampleData
                useRealData = false
                showingRefreshAlert = true
                print("⚠️ Failed to fetch, using sample data")
            }
        }
    }
}

struct DiningHallRowView: View {
    let diningHall: DiningHall
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(diningHall.name)
                .font(.headline)
                .foregroundColor(diningHall.isCurrentlyOpen ? .primary : .gray)
            
            HStack(spacing: 8) {
                Text(diningHall.hours)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if !diningHall.isCurrentlyOpen {
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(diningHall.statusText)
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            if diningHall.foodItems.isEmpty {
                Text("No menu available")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if !diningHall.isCurrentlyOpen {
                Text("\(diningHall.foodItems.count) items (currently closed)")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("\(diningHall.foodItems.count) items available")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(diningHall.isCurrentlyOpen ? 1.0 : 0.6)
    }
}

#Preview {
    DiningHallsListView()
}