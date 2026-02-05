//
//  ColumbiaNetworkManager.swift
//  ColumbiaCals
//
//  Network manager specific to Columbia University dining halls
//

import Foundation
import Combine

class ColumbiaNetworkManager: ObservableObject {
    static let baseURL = "https://columbiacals-backend.onrender.com/api"
    static let universityName = "Columbia University"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var diningHalls: [DiningHall] = []
    
    func fetchDiningHalls(completion: @escaping ([DiningHall]?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(ColumbiaNetworkManager.baseURL)/dining-halls") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(nil)
            return
        }
        
        print("📡 [Columbia] Fetching from: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ [Columbia] Network Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    print("❌ [Columbia] Invalid HTTP response")
                    completion(nil)
                    return
                }
                
                print("📊 [Columbia] HTTP Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                    print("❌ [Columbia] Server returned status \(httpResponse.statusCode)")
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    print("❌ [Columbia] No data received")
                    completion(nil)
                    return
                }
                
                // Debug: Print raw JSON
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 [Columbia] Raw JSON (first 500 chars):")
                    print(String(jsonString.prefix(500)))
                }
                
                do {
                    let decoder = JSONDecoder()
                    let allHalls = try decoder.decode([DiningHall].self, from: data)
                    
                    // Include Columbia + Barnard halls (filter out disabled locations)
                    let diningHalls = allHalls.filter { hall in
                        (hall.university == "columbia" || hall.source == "columbia" || hall.source == "barnard")
                        && hall.name != "Liz's Place"
                        && hall.name != "Faculty House Skyline"
                    }
                    
                    print("✅ [Columbia] Successfully decoded \(diningHalls.count) dining halls (filtered from \(allHalls.count) total)")
                    
                    // Print status breakdown
                    let openCount = diningHalls.filter { $0.isOpen }.count
                    let closedCount = diningHalls.filter { $0.isClosed }.count
                    let noMenuCount = diningHalls.filter { $0.hasNoMenu }.count
                    let downCount = diningHalls.filter { $0.isServiceDown }.count
                    
                    print("   🟢 Open: \(openCount)")
                    print("   🔴 Closed: \(closedCount)")
                    print("   🟡 No Menu: \(noMenuCount)")
                    print("   🔴 Service Down: \(downCount)")
                    
                    // Print total items
                    let totalItems = diningHalls.reduce(0) { $0 + $1.totalItemCount }
                    print("   📝 Total Items: \(totalItems)")
                    
                    DispatchQueue.main.async {
                        self?.diningHalls = diningHalls
                    }
                    
                    completion(diningHalls)
                    
                } catch let DecodingError.keyNotFound(key, context) {
                    self?.errorMessage = "Missing key: \(key.stringValue)"
                    print("❌ [Columbia] Decoding Error - Missing key: \(key.stringValue)")
                    print("   Context: \(context.debugDescription)")
                    completion(nil)
                    
                } catch let DecodingError.typeMismatch(type, context) {
                    self?.errorMessage = "Type mismatch for type \(type)"
                    print("❌ [Columbia] Decoding Error - Type mismatch: \(type)")
                    print("   Context: \(context.debugDescription)")
                    completion(nil)
                    
                } catch let DecodingError.valueNotFound(type, context) {
                    self?.errorMessage = "Value not found for type \(type)"
                    print("❌ [Columbia] Decoding Error - Value not found: \(type)")
                    print("   Context: \(context.debugDescription)")
                    completion(nil)
                    
                } catch let DecodingError.dataCorrupted(context) {
                    self?.errorMessage = "Data corrupted"
                    print("❌ [Columbia] Decoding Error - Data corrupted")
                    print("   Context: \(context.debugDescription)")
                    completion(nil)
                    
                } catch {
                    self?.errorMessage = "Failed to parse data: \(error.localizedDescription)"
                    print("❌ [Columbia] Parse Error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }.resume()
    }
}
