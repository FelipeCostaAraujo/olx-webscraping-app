//
//  Double+Concurrency.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 10/02/25.
//

import Foundation

extension Double {
    var asCurrencyBR: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "R$\(self)"
    }
}
