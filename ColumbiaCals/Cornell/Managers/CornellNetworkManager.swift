//
//  CornellNetworkManager.swift
//  ColumbiaCals
//
//  Network manager specific to Cornell University dining halls
//

import Foundation
import Combine

class CornellNetworkManager: ObservableObject {
    static let baseURL = "https://columbiacals-backend.onrender.com/api"
    static let universityName = "Cornell University"
    private static let cacheKey = "cornell_dining_halls_cache"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var diningHalls: [DiningHall] = []

    func loadCachedDiningHalls() -> [DiningHall]? {
        guard let data = UserDefaults.standard.data(forKey: Self.cacheKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode([DiningHall].self, from: data)
        } catch {
            print("⚠️ [Cornell] Failed to decode cached halls: \(error.localizedDescription)")
            return nil
        }
    }

    private func saveCachedDiningHalls(_ halls: [DiningHall]) {
        do {
            let data = try JSONEncoder().encode(halls)
            UserDefaults.standard.set(data, forKey: Self.cacheKey)
        } catch {
            print("⚠️ [Cornell] Failed to cache halls: \(error.localizedDescription)")
        }
    }
    
    func fetchDiningHalls(completion: @escaping ([DiningHall]?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(CornellNetworkManager.baseURL)/dining-halls") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(nil)
            return
        }
        
        print("📡 [Cornell] Fetching from: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ [Cornell] Network Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    print("❌ [Cornell] Invalid HTTP response")
                    completion(nil)
                    return
                }
                
                print("📊 [Cornell] HTTP Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                    print("❌ [Cornell] Server returned status \(httpResponse.statusCode)")
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    print("❌ [Cornell] No data received")
                    completion(nil)
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 [Cornell] Raw JSON (first 500 chars):")
                    print(String(jsonString.prefix(500)))
                }
                
                do {
                    let decoder = JSONDecoder()
                    let allHalls = try decoder.decode([DiningHall].self, from: data)
                    
                    // Filter to only Cornell halls
                    let diningHalls = allHalls.filter { hall in
                        hall.university == "cornell" || hall.source == "cornell"
                    }
                    
                    print("✅ [Cornell] Successfully decoded \(diningHalls.count) dining halls (filtered from \(allHalls.count) total)")
                    
                    let openCount = diningHalls.filter { $0.isOpen }.count
                    let closedCount = diningHalls.filter { $0.isClosed }.count
                    let noMenuCount = diningHalls.filter { $0.hasNoMenu }.count
                    let downCount = diningHalls.filter { $0.isServiceDown }.count
                    
                    print("   🟢 Open: \(openCount)")
                    print("   🔴 Closed: \(closedCount)")
                    print("   🟡 No Menu: \(noMenuCount)")
                    print("   🔴 Service Down: \(downCount)")
                    
                    let totalItems = diningHalls.reduce(0) { $0 + $1.totalItemCount }
                    print("   📝 Total Items: \(totalItems)")
                    
                    DispatchQueue.main.async {
                        self?.diningHalls = diningHalls
                    }

                    self?.saveCachedDiningHalls(diningHalls)
                    
                    completion(diningHalls)
                    
                } catch let DecodingError.keyNotFound(key, context) {
                    self?.errorMessage = "Missing key: \(key.stringValue)"
                    print("❌ [Cornell] Decoding Error - Missing key: \(key.stringValue)")
                    completion(nil)
                    
                } catch let DecodingError.typeMismatch(type, context) {
                    self?.errorMessage = "Type mismatch for type \(type)"
                    print("❌ [Cornell] Decoding Error - Type mismatch: \(type)")
                    completion(nil)
                    
                } catch let DecodingError.valueNotFound(type, context) {
                    self?.errorMessage = "Value not found for type \(type)"
                    print("❌ [Cornell] Decoding Error - Value not found: \(type)")
                    completion(nil)
                    
                } catch let DecodingError.dataCorrupted(context) {
                    self?.errorMessage = "Data corrupted"
                    print("❌ [Cornell] Decoding Error - Data corrupted")
                    completion(nil)
                    
                } catch {
                    self?.errorMessage = "Failed to parse data: \(error.localizedDescription)"
                    print("❌ [Cornell] Parse Error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }.resume()
    }
}
