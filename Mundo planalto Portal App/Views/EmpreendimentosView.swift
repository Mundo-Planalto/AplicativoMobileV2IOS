//
//  EmpreendimentosView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct EmpreendimentosView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @StateObject private var viewModel = EmpreendimentosViewModel()
    @State private var selectedVenture: Venture?

    private var isDark: Bool { appState.isDarkTheme }
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad || hSizeClass == .regular }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isLoading {
                    if !viewModel.ventures.isEmpty {
                        GeometryReader { geometry in
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.ventures) { venture in
                                        let horizontalPadding = isPad ? geometry.size.width * 0.025 : 20.0
                                        EmpreendimentoCard(
                                            venture: venture,
                                            isDark: isDark,
                                            onOpenDetails: { selectedVenture = venture }
                                        )
                                            .padding(.horizontal, horizontalPadding)
                                    }
                                }
                                .padding(.vertical)
                            }
                            .refreshable {
                                await viewModel.loadVentures(forceRefresh: true)
                            }
                        }
                        .overlay {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                                .scaleEffect(1.05)
                                .allowsHitTesting(false)
                        }
                    } else {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                        Spacer()
                    }
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
                                await viewModel.loadVentures(forceRefresh: true)
                            }
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .padding()
                    Spacer()
                } else {
                    if viewModel.ventures.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "building.2")
                                .font(.system(size: 44))
                                .foregroundColor(AppColors.accentBlue)
                            Text("Nenhum empreendimento encontrado")
                                .foregroundColor(textP)
                                .font(.headline)
                            Text("Tente atualizar a lista para recarregar os dados.")
                                .foregroundColor(textS)
                                .font(.subheadline)
                        }
                        .padding()
                        Spacer()
                    } else {
                        GeometryReader { geometry in
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.ventures) { venture in
                                        let horizontalPadding = isPad ? geometry.size.width * 0.025 : 20.0
                                        EmpreendimentoCard(
                                            venture: venture,
                                            isDark: isDark,
                                            onOpenDetails: { selectedVenture = venture }
                                        )
                                            .padding(.horizontal, horizontalPadding)
                                    }
                                }
                                .padding(.vertical)
                            }
                            .refreshable {
                                await viewModel.loadVentures(forceRefresh: true)
                            }
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
    NavigationView {
        EmpreendimentosView()
            .environmentObject(AppState.shared)
    }
}
