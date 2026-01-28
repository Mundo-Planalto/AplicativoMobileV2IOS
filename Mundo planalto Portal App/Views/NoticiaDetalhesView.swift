//
//  NoticiaDetalhesView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct NoticiaDetalhesView: View {
    let notice: Notice
    @StateObject private var viewModel: NoticiaDetalhesViewModel

    init(notice: Notice) {
        self.notice = notice
        self._viewModel = StateObject(wrappedValue: NoticiaDetalhesViewModel(notice: notice))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopAppBar
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

                        Text(notice.type == .notice ? "Aviso" : "Notícia")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

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
                        VStack(alignment: .leading, spacing: 20) {
                            // Header com tipo e data
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: notice.type == .notice ? "bell.fill" : "newspaper.fill")
                                        .foregroundColor(notice.type == .notice ? .orange : AppColors.accentBlue)

                                    Text(notice.type == .notice ? "Aviso" : "Notícia")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(notice.type == .notice ? .orange : AppColors.accentBlue)
                                }

                                Spacer()

                                Text(notice.date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            // Título grande
                            Text(notice.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .lineSpacing(8)

                            // Conteúdo completo
                            Text(notice.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                                .multilineTextAlignment(.leading)

                            // Espaço adicional no final
                            Spacer(minLength: 32)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadNoticeDetails()
            }
        }
    }
}

#Preview {
    NavigationStack {
        NoticiaDetalhesView(notice: Notice(
            id: "1",
            title: "Reunião de Condôminos - Residencial Parque das Flores",
            description: "Reunião marcada para o dia 15/02 às 19h na sala de eventos do prédio. Ordem do dia: prestação de contas, manutenção preventiva e sugestões dos moradores. Todos os condôminos estão convidados a participar desta importante reunião onde serão discutidos os assuntos administrativos do condomínio, incluindo a aprovação do orçamento para o próximo ano, planejamento de manutenções preventivas e espaço para sugestões e reclamações dos moradores. A presença de todos é fundamental para a boa gestão do nosso lar.",
            date: "10/01/2025",
            type: .notice
        ))
    }
}