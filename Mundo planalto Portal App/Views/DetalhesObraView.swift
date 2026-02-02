//
//  DetalhesObraView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct DetalhesObraView: View {
    let venture: Venture
    @StateObject private var viewModel: DetalhesObraViewModel

    init(venture: Venture) {
        self.venture = venture
        self._viewModel = StateObject(wrappedValue: DetalhesObraViewModel(venture: venture))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopAppBar conforme documentação
                ZStack {
                    AppColors.backgroundPrimary
                        .ignoresSafeArea()

                    HStack {
                        Button(action: {
                            // Voltar será tratado pela NavigationStack
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }

                        Spacer()

                        Text(venture.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Barra de Progresso Geral (Topo)
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Progresso da Obra")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(venture.progress * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.accentCyan)
                                }
                                .padding(.horizontal)

                                ProgressView(value: venture.progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accentCyan))
                                    .padding(.horizontal)
                            }
                            .padding(.vertical)

                            // Timeline Vertical
                            ZStack(alignment: .leading) {
                                // Linha contínua ciana (5dp width)
                                Rectangle()
                                    .fill(AppColors.accentCyan)
                                    .frame(width: 5)
                                    .padding(.leading, 24)

                                // Lista de marcos
                                LazyVStack(spacing: 32) {
                                    ForEach(viewModel.updates) { update in
                                        TimelineMarcoItem(update: update)
                                    }
                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 16)
                                .padding(.vertical)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadVentureDetails()
            }
        }
    }
}

struct TimelineMarcoItem: View {
    let update: VentureUpdate

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Indicador circular (16dp)
            ZStack {
                if update.isCompleted {
                    Circle()
                        .fill(AppColors.accentCyan)
                        .frame(width: 16, height: 16)
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .stroke(AppColors.accentCyan, lineWidth: 2)
                        .frame(width: 16, height: 16)
                }
            }

            // Card de conteúdo (surfaceVariant, radius 16dp)
            VStack(alignment: .leading, spacing: 12) {
                // Data em AccentCyan (18sp SemiBold)
                Text(update.date)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.accentCyan)

                // Título em onBackground bold 20sp
                Text(update.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Descrição em onSurface 80% alpha
                Text(update.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)

                // Galeria horizontal (LazyRow imagens 120x90dp radius 12dp)
                if !update.images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(update.images, id: \.self) { imageName in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 90)
                                    .cornerRadius(12)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(16) // 16dp padding interno
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    NavigationStack {
        DetalhesObraView(venture: Venture(
            id: "1",
            name: "Residencial Parque das Flores",
            imageUrl: "venture1",
            progress: 0.75,
            lastUpdate: "Atualizado há 2 dias"
        ))
    }
}