//
//  FinanceiroView.swift
//  Mundo Planalto
//
//  Tela Financeiro (push a partir da Início) — docs/telas.md.
//

import SwiftUI
import Combine

@MainActor
final class FinanceiroViewModel: ObservableObject {
    @Published var resumo: FinanceiroResumo?
    @Published var isLoading = false
    @Published var error: String?

    func load(forceRefresh: Bool = false, venture: Venture? = nil) async {
        isLoading = true
        error = nil
        do {
            resumo = try await RepositoryProvider.financeiro.resumo(forceRefresh: forceRefresh, venture: venture)
        } catch {
            self.error = AppErrorMapper.userMessage(for: error, fallback: "Não foi possível carregar seus dados financeiros.")
        }
        isLoading = false
    }
}

struct FinanceiroView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = FinanceiroViewModel()
    /// Preenchido quando aberto pela página do empreendimento: seletor fixo e dados filtrados.
    var venture: Venture? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Financeiro", subtitulo: "Acompanhe sua situação e tenha mais controle sobre seu investimento")

                if let r = vm.resumo {
                    seletorEmpreendimento(r)
                    situacaoCard(r)
                    HStack(spacing: 8) {
                        HrStatPill(icon: "creditcard", valor: r.saldoContrato, rotulo: "Saldo do contrato")
                        HrStatPill(icon: "checkmark.circle", valor: r.parcelasPagas, rotulo: "Parcelas pagas")
                        HrStatPill(icon: "calendar", valor: r.parcelasRestantes, rotulo: "Parcelas restantes")
                    }
                    HrSectionTitle(titulo: "Próximas parcelas", acao: "Ver todas") { router.push(.extrato) }
                        .padding(.top, 8)
                    ForEach(r.proximasParcelas) { parcela in
                        parcelaRow(parcela)
                    }
                    if r.proximasParcelas.isEmpty {
                        HrCard { Text("Nenhuma parcela em aberto.").font(HrFont.caption).foregroundColor(.hrTextMuted) }
                    }
                } else if vm.isLoading {
                    HrCard { HStack { Spacer(); ProgressView().tint(.hrGold); Spacer() } }
                } else if let error = vm.error {
                    HrCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(error).font(HrFont.body).foregroundColor(.white)
                            HrOutlineButton(text: "Tentar novamente") { Task { await vm.load(forceRefresh: true, venture: venture) } }
                        }
                    }
                }

                HrSectionTitle(titulo: "Documentos financeiros")
                    .padding(.top, 8)
                HrListRow(icon: "doc.text.fill", titulo: "Segunda via de boleto", subtitulo: "Emita a segunda via da sua parcela") { router.push(.extrato) }
                HrListRow(icon: "list.bullet.rectangle.fill", titulo: "Extrato financeiro", subtitulo: "Acompanhe seu histórico de pagamentos") { router.push(.extrato) }
                HrListRow(icon: "doc.richtext.fill", titulo: "Informe de rendimentos", subtitulo: "Acesse seu informe anual") { router.push(.informeRendimentos) }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .refreshable { await vm.load(forceRefresh: true, venture: venture) }
        .hrScreen()
        .task { await vm.load(venture: venture) }
    }

    private func seletorEmpreendimento(_ r: FinanceiroResumo) -> some View {
        HrCard(padding: 12) {
            HStack(spacing: 12) {
                HrPhoto(url: r.empreendimentoImagem, height: 48, cornerRadius: 10, placeholderIcon: "building.2.fill")
                    .frame(width: 48)
                VStack(alignment: .leading, spacing: 3) {
                    HrTag(text: "Empreendimento")
                    Text(r.empreendimentoNome)
                        .font(HrFont.itemTitle)
                        .foregroundColor(.white)
                    if !r.empreendimentoLocal.isEmpty {
                        Text(r.empreendimentoLocal)
                            .font(HrFont.captionSmall)
                            .foregroundColor(.hrTextMuted)
                    }
                }
                Spacer()
                if venture == nil {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.hrGold)
                }
            }
        }
    }

    /// Card de situação sem foto de fundo (revisão de 01/10): só box com borda dourada.
    private func situacaoCard(_ r: FinanceiroResumo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HrTag(text: "Situação financeira")
                Spacer()
                HrStatusDot(text: r.situacao, color: r.situacaoEmDia ? .hrSuccess : .hrError)
            }
            Text("Próximo vencimento")
                .font(HrFont.caption)
                .foregroundColor(.hrTextMuted)
                .padding(.top, 4)
            Text(r.proximoVencimento)
                .font(HrFont.itemTitle)
                .foregroundColor(.white)
            Text(r.proximoValor)
                .font(HrFont.money)
                .foregroundColor(.hrGold)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            HrGoldButton(text: "Pagar parcela") { router.push(.extrato) }
                .padding(.top, 4)
        }
        .padding(HrMetrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hrSurface)
        .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous).stroke(Color.hrGold, lineWidth: 1))
    }

    private func parcelaRow(_ p: ParcelaResumo) -> some View {
        HStack(spacing: 12) {
            HrIconBox(icon: "calendar")
            Text(p.vencimento)
                .font(HrFont.itemTitle)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 8)
            Text(p.valor)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.hrGold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            HrTag(text: p.status.texto, color: p.status == .vencida ? .hrError : .hrWarning)
                .fixedSize()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.hrSurface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
    }
}

#Preview {
    NavigationStack { FinanceiroView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
