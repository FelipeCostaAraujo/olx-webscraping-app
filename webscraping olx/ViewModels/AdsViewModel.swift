//
//  AdsViewModel.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 10/02/25.
//

import Foundation
import SwiftUI

class AdsViewModel: ObservableObject {
    @Published var ads: [AdModel] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    @Published var filterSuperPrice: Bool = UserDefaults.standard.bool(forKey: "filterSuperPrice")
    @Published var filterRecent: Bool = UserDefaults.standard.bool(forKey: "filterRecent")
    @Published var priceOrder: String = UserDefaults.standard.string(forKey: "priceOrder") ?? "none"
    @Published var selectedCategory: String = UserDefaults.standard.string(forKey: "selectedCategory") ?? "all"
    
    init() { }
    
    func savePreferences() {
        UserDefaults.standard.set(filterSuperPrice, forKey: "filterSuperPrice")
        UserDefaults.standard.set(filterRecent, forKey: "filterRecent")
        UserDefaults.standard.set(priceOrder, forKey: "priceOrder")
        UserDefaults.standard.set(selectedCategory, forKey: "selectedCategory")
    }
    
    /// Fetches ads from the API using the current filter settings.
    func fetchAds() {
        var urlString = "http://192.168.10.126:6000/ads"
        var params = [String]()
        if filterSuperPrice { params.append("superPrice=true") }
        if filterRecent { params.append("recent=true") }
        
        if priceOrder != "none" {
            params.append("price=\(priceOrder)")
        }
        if selectedCategory != "all" {
            params.append("category=\(selectedCategory)")
        }
        if !params.isEmpty {
            urlString += "?" + params.joined(separator: "&")
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "URL inválida."
                self.isLoading = false
            }
            return
        }
        self.isLoading = true
        self.errorMessage = nil
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else {
                    self.errorMessage = "Dados inválidos."
                    return
                }
                do {
                    let ads = try JSONDecoder().decode([AdModel].self, from: data)
                    self.ads = ads
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
    
    /// Deletes an ad using the API (via DELETE request) and removes it from the list on success.
    func deleteAd(at offsets: IndexSet) {
        for index in offsets {
            let ad = self.ads[index]
            guard let url = URL(string: "http://192.168.10.126:6000/ads/\(ad.id)") else {
                DispatchQueue.main.async {
                    self.errorMessage = "URL inválida para exclusão."
                }
                continue
            }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        self.errorMessage = "Erro ao excluir anúncio."
                        return
                    }
                    self.ads.removeAll { $0.id == ad.id }
                }
            }.resume()
        }
    }
}
