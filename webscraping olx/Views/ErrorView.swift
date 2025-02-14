//
//  ErrorView.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 12/02/25.
//
import SwiftUI

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Erro: \(error)")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            Button("Tentar novamente", action: retryAction)
                .padding()
                .background(Color.deepOrange)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}
