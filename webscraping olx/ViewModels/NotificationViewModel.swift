//
//  NotificationViewModel.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 12/02/25.
//

import Foundation
import Combine

class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchNotifications() {
        guard let url = URL(string: "http://192.168.10.126:6000/notifications") else {
            self.errorMessage = "URL inválida"
            return
        }
        isLoading = true
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [NotificationModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] notifications in
                self?.notifications = notifications
            }
            .store(in: &cancellables)
    }
}
