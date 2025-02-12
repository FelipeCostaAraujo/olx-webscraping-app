//
//  ad.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 10/02/25.
//

import Foundation

struct Ad: Identifiable, Codable {
    let id: String
    let title: String
    let price: Double
    let url: String
    let imageUrl: String?
    let searchQuery: String?
    let superPrice: Bool
    let location: String?
    let publishedAt: String?
    let priceTrend: String?
    let priceDifference: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, price, url, imageUrl, searchQuery, superPrice, location, publishedAt, priceTrend, priceDifference
    }
}
