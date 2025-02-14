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
                    NavigationLink(destination: NotificationView()) {
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

extension Color {
    static let deepOrange = Color(red: 255/255, green: 87/255, blue: 34/255)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
