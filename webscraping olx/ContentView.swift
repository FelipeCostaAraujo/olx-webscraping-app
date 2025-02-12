//
//  ContentView.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 10/02/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AdsViewModel()
    @State private var showingFilterSheet = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Carregando anúncios...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error) {
                        viewModel.fetchAds()
                    }
                } else if viewModel.ads.isEmpty {
                    VStack(spacing: 16) {
                        Text("Nenhum anúncio encontrado.")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Button("Recarregar") {
                            viewModel.fetchAds()
                        }
                        .padding()
                        .background(Color.deepOrange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack{
                        HStack{
                            Spacer()
                            Text("\(viewModel.ads.count) anúncio(s) encontrado(s)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }.padding(5)

                        List {
                            ForEach(viewModel.ads) { ad in
                                AdRow(ad: ad)
                            }
                            .onDelete(perform: viewModel.deleteAd)
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            viewModel.fetchAds()
                        }
                    }
                }
            }
            .navigationTitle("Anúncios OLX")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingFilterSheet.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Placeholder for notifications.
                    }) {
                        Image(systemName: "bell")
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.fetchAds()
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Alert(title: Text("Erro"),
                  message: Text(viewModel.errorMessage ?? "Erro desconhecido"),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct AdRow: View {
    let ad: Ad

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
                        // Exibe o preço formatado com a extensão asCurrencyBR
                        Text("Preço: \(ad.price.asCurrencyBR)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Verifica a tendência de preço e exibe o ícone correspondente
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


struct FilterView: View {
    @ObservedObject var viewModel: AdsViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ordenação")) {
                    Toggle("Super Preço primeiro", isOn: $viewModel.filterSuperPrice)
                    Toggle("Publicados mais recentes", isOn: $viewModel.filterRecent)
                    
                    Picker("Ordenação de preço", selection: $viewModel.priceOrder) {
                        Text("Nenhum").tag("none")
                        Text("Preço baixo primeiro").tag("asc")
                        Text("Preço alto primeiro").tag("desc")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Categoria")) {
                    Picker("Categoria", selection: $viewModel.selectedCategory) {
                        Text("Todos").tag("all")
                        Text("Hardware").tag("hardware")
                        Text("Carros").tag("car")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Filtros")
            .navigationBarItems(trailing: Button("Aplicar") {
                viewModel.savePreferences()
                viewModel.fetchAds()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}



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

extension Color {
    static let deepOrange = Color(red: 255/255, green: 87/255, blue: 34/255)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
