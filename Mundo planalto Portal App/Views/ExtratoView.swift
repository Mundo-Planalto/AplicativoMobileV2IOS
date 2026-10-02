//
//  ExtratoView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct ExtratoView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ExtratoViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Extrato financeiro", subtitulo: "Parcelas, boletos e histórico de pagamentos")

                ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.tabOptions, id: \.rawValue) { tab in
                        ZStack(alignment: .topTrailing) {
                            HrChip(text: tab.rawValue, selected: viewModel.selectedFilter == tab) {
                                viewModel.setFilter(tab)
                                if tab == .aVencer || tab == .vencidas {
                                    appState.markBoletoTabAsSeen(tab, items: viewModel.allItems)
                                }
                            }
                            let count = appState.unreadBoletoCount(for: tab)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Capsule().fill(Color.hrGoldLight))
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }
                    Spacer()
                    Button {
                        viewModel.showFilterModal = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 14, weight: .semibold))
                            Text("Filtros").font(.system(size: 13, weight: .semibold)).lineLimit(1)
                        }
                        .fixedSize()
                        .foregroundColor(.hrGoldLight)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: HrMetrics.chipRadius, style: .continuous).stroke(Color.hrGold, lineWidth: 1))
                    }
                    .buttonStyle(HrPressStyle())
                }
                .padding(.horizontal, HrMetrics.screenMargin)
                }
                .padding(.horizontal, -HrMetrics.screenMargin)

                if viewModel.isLoading && viewModel.allItems.isEmpty {
                    HrCard { HStack { Spacer(); ProgressView().tint(.hrGold); Spacer() } }
                } else if let error = viewModel.error, viewModel.allItems.isEmpty {
                    HrCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(error).font(HrFont.body).foregroundColor(.white)
                            HrOutlineButton(text: "Tentar novamente") { Task { await viewModel.loadFinancialStatement(forceRefresh: true) } }
                        }
                    }
                } else if viewModel.filteredItems.isEmpty {
                    HrCard {
                        HStack(spacing: 12) {
                            HrIconBox(icon: "doc.text")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Boleto não gerado").font(HrFont.itemTitle).foregroundColor(.white)
                                Text("Não há registros para exibir nesta aba.").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                            }
                        }
                    }
                } else {
                    ForEach(viewModel.filteredItems) { item in
                        ParcelaCardExtrato(item: item, isUnread: appState.isBoletoUnread(item.id))
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .refreshable {
            await viewModel.loadFinancialStatement(forceRefresh: true)
            await appState.refreshUnreadBoletoCounts(from: viewModel.allItems)
        }
        .hrScreen()
        .sheet(isPresented: $viewModel.showFilterModal) {
            FiltrarParcelasModal(
                empreendimento: $viewModel.filtroEmpreendimento,
                empreendimentoOptions: viewModel.empreendimentoOptions,
                periodo: $viewModel.filtroPeriodo,
                onCancel: { viewModel.showFilterModal = false },
                onApply: { viewModel.applyFiltersFromModal() },
                isDark: true
            )
            .presentationBackground(Color.hrBlack)
        }
        .task {
            await viewModel.loadFinancialStatement()
            await appState.refreshUnreadBoletoCounts(from: viewModel.allItems)
            if viewModel.selectedFilter == .aVencer || viewModel.selectedFilter == .vencidas {
                appState.markBoletoTabAsSeen(viewModel.selectedFilter, items: viewModel.allItems)
            }
        }
    }
}

// MARK: - Card no layout do anexo: descrição, tag, Vencimento, Valor; Ver Boleto / Gerar 2ª Via só para A Vencer
struct ParcelaCardExtrato: View {
    let item: FinancialStatementItem
    var isDark: Bool = true
    var isUnread: Bool = false
    @EnvironmentObject private var appState: AppState
    @State private var loadingBoleto = false
    @State private var showBoletoNaoGeradoModal = false
    @State private var showBoletoShareSheet = false
    @State private var boletoShareItems: [Any] = []

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    /// Exibir botões de boleto para parcelas a vencer e vencidas.
    private var mostraBotoesBoleto: Bool { item.status == .upcoming || item.status == .overdue }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private func statusText(_ status: PaymentStatus) -> String {
        switch status {
        case .paid: return "Pagas"
        case .upcoming: return "A Vencer"
        case .overdue: return "Vencidas"
        }
    }

    private func statusTagColor(_ status: PaymentStatus) -> Color {
        switch status {
        case .paid: return .green
        case .upcoming: return Color(hex: "#E68A00")
        case .overdue: return .red
        }
    }

    /// Ver Boleto: abre a URL no navegador.
    private func verBoleto() {
        guard item.billReceivableId != nil || item.esolutionBoletoId != nil else {
            showBoletoNaoGeradoModal = true
            return
        }
        loadingBoleto = true
        Task {
            let url = await ExtratoService.shared.getBoletoPdfUrl(item: item)
            await MainActor.run {
                loadingBoleto = false
                if let url = url {
                    appState.markBoletoAsRead(item)
                    UIApplication.shared.open(url)
                } else {
                    showBoletoNaoGeradoModal = true
                }
            }
        }
    }

    /// Instalar documento: baixa o PDF e abre direto o recurso da Apple (share sheet) para o usuário escolher onde salvar.
    private func instalarDocumento() {
        guard item.billReceivableId != nil || item.esolutionBoletoId != nil else {
            showBoletoNaoGeradoModal = true
            return
        }
        loadingBoleto = true
        Task {
            let url = await ExtratoService.shared.getBoletoPdfUrl(item: item)
            guard let webUrl = url else {
                await MainActor.run {
                    loadingBoleto = false
                    showBoletoNaoGeradoModal = true
                }
                return
            }
            var request = URLRequest(url: webUrl)
            if let token = PreferencesManager.shared.getAuthToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  (response as? HTTPURLResponse)?.statusCode == 200 else {
                await MainActor.run {
                    loadingBoleto = false
                    showBoletoNaoGeradoModal = true
                }
                return
            }
            let fileName = "Boleto_\(item.parcela.replacingOccurrences(of: "/", with: "-")).pdf"
            let temp = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            do {
                try data.write(to: temp)
                await MainActor.run {
                    loadingBoleto = false
                    appState.markBoletoAsRead(item)
                    boletoShareItems = [temp]
                    showBoletoShareSheet = true
                }
            } catch {
                await MainActor.run {
                    loadingBoleto = false
                    showBoletoNaoGeradoModal = true
                }
            }
        }
    }

    private var statusColor: Color {
        switch item.status {
        case .paid: return .hrSuccess
        case .upcoming: return .hrWarning
        case .overdue: return .hrError
        }
    }

    var body: some View {
        HrCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.ventureName)
                            .font(HrFont.itemTitle)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        Text("Parcela \(item.parcela)")
                            .font(HrFont.captionSmall)
                            .foregroundColor(.hrTextMuted)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        if isUnread && mostraBotoesBoleto {
                            HrTag(text: "Novo", filled: true, color: .hrGoldLight)
                        }
                        HrTag(text: statusText(item.status), color: statusColor)
                    }
                }

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vencimento").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                        Text(item.dueDate).font(HrFont.body).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Valor").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                        Text(formatCurrency(item.amount))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.hrGold)
                    }
                }

                if item.status == .paid {
                    let paymentDate = item.paymentDate?.trimmingCharacters(in: .whitespacesAndNewlines)
                    HStack {
                        Text("Data de pagamento").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                        Spacer()
                        Text((paymentDate?.isEmpty == false) ? paymentDate! : "Não informada")
                            .font(HrFont.body)
                            .foregroundColor(.white)
                    }
                }

                if mostraBotoesBoleto {
                    HStack(spacing: 8) {
                        HrOutlineButton(text: "Ver boleto", icon: "eye", isEnabled: !loadingBoleto) { verBoleto() }
                        HrGoldButton(text: "Gerar 2ª via", trailingArrow: false, isLoading: loadingBoleto) { instalarDocumento() }
                    }
                }
            }
        }
        .sheet(isPresented: $showBoletoNaoGeradoModal) {
            BoletoNaoGeradoModalView(item: item, isDark: isDark, onDismiss: { showBoletoNaoGeradoModal = false })
        }
        .sheet(isPresented: $showBoletoShareSheet) {
            ShareSheet(activityItems: boletoShareItems)
        }
    }
}

// MARK: - Modal "Boleto não gerado": detalhes do item + Fechar e Solicitar via WhatsApp
private struct BoletoNaoGeradoModalView: View {
    let item: FinancialStatementItem
    var isDark: Bool = true
    var onDismiss: () -> Void

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    private static let whatsAppPhone = "556240002200"
    private var whatsAppUrl: URL? {
        let contract = item.contractNumber ?? "-"
        let text = "Solicito a segunda via do boleto contrato \(contract), vencimento \(item.dueDate)."
        var components = URLComponents(string: "https://api.whatsapp.com/send/")
        components?.queryItems = [
            URLQueryItem(name: "phone", value: Self.whatsAppPhone),
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "type", value: "phone_number"),
            URLQueryItem(name: "app_absent", value: "0")
        ]
        return components?.url
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Boleto não gerado")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body)
                        .foregroundColor(textS)
                }
            }

            Text("O boleto ainda não foi gerado pelo sistema.")
                .font(.subheadline)
                .foregroundColor(textS)

            VStack(alignment: .leading, spacing: 8) {
                detailRow("Empreendimento:", value: item.ventureName)
                detailRow("Contrato:", value: item.contractNumber ?? "-")
                detailRow("Parcela:", value: item.parcela)
                detailRow("Vencimento:", value: item.dueDate)
            }

            HStack(spacing: 12) {
                Button("Fechar") {
                    onDismiss()
                }
                .font(.headline)
                .foregroundColor(textS)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(cardBg)
                .cornerRadius(10)

                if let url = whatsAppUrl {
                    Link(destination: url) {
                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                                .font(.body)
                            Text("Solicitar via WhatsApp")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.18, green: 0.78, blue: 0.44))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(24)
        .background(cardBg)
        .cornerRadius(16)
        .padding(40)
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textS)
            Text(value)
                .font(.subheadline)
                .foregroundColor(textP)
        }
    }
}

// MARK: - Modal Filtrar Parcelas
struct FiltrarParcelasModal: View {
    @Binding var empreendimento: String
    let empreendimentoOptions: [String]
    @Binding var periodo: FiltroPeriodo
    var onCancel: () -> Void
    var onApply: () -> Void
    var isDark: Bool = true

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        VStack(spacing: 0) {
            Text("Filtrar Parcelas")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textP)
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 16) {
                Text("Empreendimento")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                ForEach(empreendimentoOptions, id: \.self) { opt in
                    Button {
                        empreendimento = opt
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: empreendimento == opt ? "circle.inset.filled" : "circle")
                                .foregroundColor(AppColors.accentBlue)
                            Text(opt)
                                .font(.subheadline)
                                .foregroundColor(textP)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 16) {
                Text("Período")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                ForEach(FiltroPeriodo.allCases, id: \.rawValue) { opt in
                    Button {
                        periodo = opt
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: periodo == opt ? "circle.inset.filled" : "circle")
                                .foregroundColor(AppColors.accentBlue)
                            Text(opt.rawValue)
                                .font(.subheadline)
                                .foregroundColor(textP)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 24)

            HStack(spacing: 12) {
                Button("Cancelar") {
                    onCancel()
                }
                .font(.headline)
                .foregroundColor(AppColors.accentBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.accentBlue, lineWidth: 1)
                )

                Button("Aplicar Filtros") {
                    onApply()
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.hrGold)
                .cornerRadius(10)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBg)
    }
}

#Preview {
    NavigationView {
        ExtratoView()
            .environmentObject(AppState.shared)
    }
}
