//
//  DetalhesObraView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct DetalhesObraView: View {
    let venture: Venture
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: DetalhesObraViewModel

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    init(venture: Venture) {
        self.venture = venture
        self._viewModel = StateObject(wrappedValue: DetalhesObraViewModel(venture: venture))
    }

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    bg
                        .ignoresSafeArea()

                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(textP)
                                .font(.title2)
                        }

                        Spacer()

                        Text(venture.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(textP)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            if venture.progress > 0 {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Progresso da Obra")
                                            .font(.headline)
                                            .foregroundColor(textP)
                                        Spacer()
                                        Text("\(Int(venture.progress * 100))%")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.accentBlue)
                                    }
                                    .padding(.horizontal)

                                    ProgressView(value: venture.progress)
                                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accentBlue))
                                        .padding(.horizontal)
                                }
                                .padding(.vertical)
                            }

                            if viewModel.updates.isEmpty && !viewModel.isLoading {
                                Text("Nenhuma atualização disponível no momento.")
                                    .font(.subheadline)
                                    .foregroundColor(textS)
                                    .padding()
                            }

                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(AppColors.accentBlue)
                                    .frame(width: 5)
                                    .padding(.leading, 24)

                                LazyVStack(spacing: 32) {
                                    ForEach(viewModel.updates) { update in
                                        TimelineMarcoItem(update: update, isDark: isDark)
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
        .navigationBarBackButtonHidden(true)
    }
}

struct TimelineMarcoItem: View {
    let update: VentureUpdate
    var isDark: Bool = true

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                if update.isCompleted {
                    Circle()
                        .fill(AppColors.accentBlue)
                        .frame(width: 16, height: 16)
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .stroke(AppColors.accentBlue, lineWidth: 2)
                        .frame(width: 16, height: 16)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(update.date)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.accentBlue)

                Text(update.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(textP)

                Text(update.description)
                    .font(.body)
                    .foregroundColor(textS)
                    .lineSpacing(4)

                if let imageUrl = update.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(textS.opacity(0.2))
                                .overlay(Image(systemName: "photo").foregroundColor(textS))
                        default:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(textS.opacity(0.2))
                                .overlay(ProgressView())
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                }

                if let videoUrl = update.videoUrl, !videoUrl.isEmpty {
                    VideoPlayerView(urlString: videoUrl)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBg)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(isDark ? 0.2 : 0.08), radius: 8, x: 0, y: 4)
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
        .environmentObject(AppState.shared)
    }
}