//
//  FilterView.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 12/02/25.
//
import SwiftUI

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
