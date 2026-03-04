//
//  EmpreendimentosView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct EmpreendimentosView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = EmpreendimentosViewModel()
    @State private var selectedVenture: Venture?

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(textP)
                            .multilineTextAlignment(.center)
                        Button("Tentar Novamente") {
                            Task {
                                await viewModel.loadVentures()
                            }
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .padding()
                    Spacer()
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.ventures) { venture in
                                    EmpreendimentoCard(venture: venture, isDark: isDark)
                                        .padding(.horizontal, geometry.size.width * 0.025)
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
        }
        .navigationTitle("Meus Empreendimentos")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(isDark ? .dark : .light, for: .navigationBar)
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
            .environmentObject(AppState.shared)
    }
}
