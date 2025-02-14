//
//  NotificationModel.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 12/02/25.
//

import Foundation

struct NotificationModel: Codable, Identifiable {
    let id: String
    let adId: String
    let title: String
    let price: Double
    let url: String
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case adId, title, price, url, imageUrl
    }
}
