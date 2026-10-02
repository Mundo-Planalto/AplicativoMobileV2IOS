//
//  EmpreendimentosView.swift
//  Mundo Planalto
//
//  Aba Empreendimentos: lista dos empreendimentos do cliente (GET ventures).
//

import SwiftUI

struct EmpreendimentosView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = EmpreendimentosViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(nome: appState.currentMember.nome, titulo: "Meu empreendimento", subtitulo: "Acompanhe a obra, fotos e vídeos do seu investimento") {
                    router.push(.avisosNoticias)
                }

                if viewModel.isLoading && viewModel.ventures.isEmpty {
                    HrCard { HStack { Spacer(); ProgressView().tint(.hrGold); Spacer() } }
                } else if let error = viewModel.error, viewModel.ventures.isEmpty {
                    HrCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(error).font(HrFont.body).foregroundColor(.white)
                            HrOutlineButton(text: "Tentar novamente") { Task { await viewModel.loadVentures(forceRefresh: true) } }
                        }
                    }
                } else if viewModel.ventures.isEmpty {
                    HrCard {
                        HStack(spacing: 12) {
                            HrIconBox(icon: "building.2")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Nenhum empreendimento encontrado").font(HrFont.itemTitle).foregroundColor(.white)
                                Text("Tente atualizar a lista para recarregar os dados.").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                            }
                        }
                    }
                } else {
                    ForEach(viewModel.ventures) { venture in
                        EmpreendimentoCard(venture: venture) {
                            router.push(.empreendimento(venture))
                        }
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .refreshable { await viewModel.loadVentures(forceRefresh: true) }
        .hrScreen()
        .task { await viewModel.loadVentures() }
    }
}

#Preview {
    NavigationStack { EmpreendimentosView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
