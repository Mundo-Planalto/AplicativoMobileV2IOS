//
//  EmpreendimentosView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct EmpreendimentosView: View {
    @StateObject private var viewModel = EmpreendimentosViewModel()
    @State private var selectedVenture: Venture?

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button("Tentar Novamente") {
                            Task {
                                await viewModel.loadVentures()
                            }
                        }
                        .foregroundColor(AppColors.accentCyan)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.ventures) { venture in
                                EmpreendimentoCard(venture: venture)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        selectedVenture = venture
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationDestination(item: $selectedVenture) { venture in
            DetalhesObraView(venture: venture)
        }
        .onAppear {
            Task {
                await viewModel.loadVentures()
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmpreendimentosView()
    }
}