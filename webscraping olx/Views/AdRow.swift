//
//  AdRow.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 12/02/25.
//

import SwiftUI

struct AdRow: View {
    let ad: AdModel

    var body: some View {
        Button(action: {
            openURL(ad.url)
        }) {
            HStack(alignment: .top, spacing: 12) {
                if let imageUrlString = ad.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(8)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(ad.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("Preço: \(ad.price.asCurrencyBR)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let trend = ad.priceTrend {
                            if trend == "up" {
                                Image(systemName: "arrowtriangle.up.fill")
                                    .foregroundColor(.green)
                            } else if trend == "down" {
                                Image(systemName: "arrowtriangle.down.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    if let location = ad.location, !location.isEmpty {
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    if let publishedAt = ad.publishedAt, !publishedAt.isEmpty {
                        Text(publishedAt)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(ad.superPrice ? Color.green.opacity(0.5) : Color.purple.opacity(0.2))
            )
        }
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
