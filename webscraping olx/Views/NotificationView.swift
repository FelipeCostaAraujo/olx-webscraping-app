//
//  NotificationView.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 12/02/25.
//

import SwiftUI

struct NotificationView: View {
    @StateObject private var viewModel = NotificationViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Carregando notificações...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text("Erro: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.notifications.isEmpty {
                    Text("Nenhuma notificação recebida.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.notifications) { notification in
                        NotificationRow(notification: notification)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Notificações")
            .onAppear {
                if viewModel.notifications.isEmpty {
                    viewModel.fetchNotifications()
                }
            }
        }
    }
}


struct NotificationRow: View {
    let notification: NotificationModel

    var body: some View {
        Button(action: {
            if let url = URL(string: notification.url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                if let imageUrl = notification.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
                } else {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(notification.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text("Preço: \(notification.price, specifier: "%.0f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
