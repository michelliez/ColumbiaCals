//
//  ColumbiaDiningHallsListView.swift
//  ColumbiaCals
//
//  Dining halls list view for Columbia University
//

import SwiftUI

struct ColumbiaDiningHallsListView: View {
    @Binding var showUniversitySidebar: Bool
    
    @StateObject private var cartVM = CartViewModel()
    @StateObject private var networkManager = ColumbiaNetworkManager()
    @ObservedObject private var ratingService = RatingService.shared
    @Environment(\.colorScheme) var colorScheme

    @State private var diningHalls: [DiningHall] = []
    
    private func loadDiningHalls() {
        networkManager.fetchDiningHalls { halls in
            DispatchQueue.main.async {
                if let halls = halls, !halls.isEmpty {
                    self.diningHalls = halls
                } else if self.diningHalls.isEmpty {
                    self.diningHalls = DiningHall.sampleData
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if diningHalls.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading dining halls...")
                            .foregroundColor(.textSecondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Hero Header with Gradient
                            ZStack {
                                // Background with gradient
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.columbiaBlueSecondary,
                                                Color.columbiaBlueSecondary.opacity(0.9)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                // Decorative circles
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                    .offset(x: 80, y: -30)
                                
                                Circle()
                                    .fill(Color.accentGreen.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                    .offset(x: -60, y: 50)
                                
                                VStack(spacing: 16) {
                                    HStack(spacing: 12) {
                                        Text("🦁")
                                            .font(.system(size: 48))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("CalRoarie")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(.white)

                                            Text("Columbia Dining")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white.opacity(0.8))
                                        }

                                        Spacer()
                                    }

                                    // Quick Stats Row
                                    HStack(spacing: 12) {
                                        StatCard(
                                            icon: "checkmark.circle.fill",
                                            value: "\(diningHalls.filter { $0.isOpen }.count)",
                                            label: "Open Now",
                                            color: .accentGreen
                                        )

                                        StatCard(
                                            icon: "fork.knife",
                                            value: "\(diningHalls.reduce(0) { $0 + $1.allMenuItems.count })",
                                            label: "Items",
                                            color: .accentOrange
                                        )

                                        StatCard(
                                            icon: "building.2.fill",
                                            value: "\(diningHalls.count)",
                                            label: "Locations",
                                            color: .accentBlue
                                        )
                                    }
                                }
                                .padding(20)
                            }
                            .frame(height: 200)
                            .shadow(color: Color.columbiaBluePrimary.opacity(0.3), radius: 16, x: 0, y: 8)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .transition(.scale(scale: 0.95).combined(with: .opacity))

                            Spacer()
                                .frame(height: 12)

                            // Section: Open Now
                            if !diningHalls.filter({ $0.isOpen }).isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("Open Now")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)

                                        Circle()
                                            .fill(Color.cardBackground.opacity(0.8))
                                            .frame(width: 8, height: 8)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.accentGreen.opacity(0.8),
                                                Color.accentGreen.opacity(0.6)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                    VStack(spacing: 12) {
                                        ForEach(diningHalls.filter { $0.isOpen }, id: \.self.name) { hall in
                                            NavigationLink(destination: ColumbiaDiningHallDetailView(diningHall: hall, cartVM: cartVM)) {
                                                DiningHallCard(diningHall: hall, university: "columbia")
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .transition(.slideAndFade)
                                        }
                                    }
                                    .padding(.top, 6)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                    .background(Color.cardBackground)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.accentGreen.opacity(0.3), lineWidth: 2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: Color.accentGreen.opacity(0.22), radius: 16, x: 0, y: 8)
                                .padding(.horizontal, 16)
                            }

                            // Section: Closed
                            if !diningHalls.filter({ !$0.isOpen }).isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("Closed")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.accentRed.opacity(0.7),
                                                Color.accentRed.opacity(0.5)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                    VStack(spacing: 12) {
                                        ForEach(diningHalls.filter { !$0.isOpen }, id: \.self.name) { hall in
                                            NavigationLink(destination: ColumbiaDiningHallDetailView(diningHall: hall, cartVM: cartVM)) {
                                                DiningHallCard(diningHall: hall, university: "columbia")
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .transition(.slideAndFade)
                                        }
                                    }
                                    .padding(.top, 6)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                    .background(Color.cardBackground)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.cardBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.accentRed.opacity(0.3), lineWidth: 2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: Color.accentRed.opacity(0.22), radius: 16, x: 0, y: 8)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        loadDiningHalls()
                    }
                }
            }
            .navigationTitle("Columbia University")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            showUniversitySidebar = true
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.columbiaBluePrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        NavigationLink(destination: LeaderboardView()) {
                            Image(systemName: "trophy.fill")
                                .font(.title3)
                                .foregroundColor(.accentOrange)
                        }
                        
                        NavigationLink(destination: SettingsView(cartVM: cartVM)) {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(.columbiaBluePrimary)
                        }
                        
                        NavigationLink(destination: CartView(cartVM: cartVM)) {
                            Image(systemName: "cart.fill")
                                .font(.title3)
                                .foregroundColor(.columbiaBluePrimary)
                                .overlay(
                                    cartVM.cartItems.isEmpty ? nil :
                                    Text("\(cartVM.cartItems.count)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Circle().fill(Color.accentRed))
                                        .alignmentGuide(.top) { d in d[.bottom] }
                                        .alignmentGuide(.trailing) { d in d[.leading] }
                                    , alignment: .topTrailing
                                )
                        }
                    }
                }
            }
            .onAppear {
                if diningHalls.isEmpty,
                   let cachedHalls = networkManager.loadCachedDiningHalls(),
                   !cachedHalls.isEmpty {
                    diningHalls = cachedHalls
                }

                // Fetch real data from network (fallback to sample if needed)
                loadDiningHalls()

                // Fetch current meal period ratings
                ratingService.fetchRatingAverages(university: "columbia")
            }
        }
    }
}

// MARK: - Stat Card
private struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.25), lineWidth: 2)
        )
        .shadow(color: Color.shadowColor.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    ColumbiaDiningHallsListView(showUniversitySidebar: .constant(false))
}
