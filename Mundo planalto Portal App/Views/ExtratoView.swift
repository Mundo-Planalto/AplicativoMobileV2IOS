//
//  ExtratoView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct ExtratoView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ExtratoViewModel()

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra superior: voltar + título
                HStack(spacing: 16) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(isDark ? .white : .primary)
                    }
                    Spacer()
                    Text("Extrato Financeiro")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                    Spacer()
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(bg)

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
                            Task { await viewModel.loadFinancialStatement(forceRefresh: true) }
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .padding()
                    Spacer()
                } else {
                    // Abas: A Vencer | Pagas | Vencidas  +  Filtros
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(viewModel.tabOptions, id: \.rawValue) { tab in
                            Button {
                                viewModel.setFilter(tab)
                                if tab == .aVencer || tab == .vencidas {
                                    appState.markBoletoTabAsSeen(tab, items: viewModel.allItems)
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    HStack(spacing: 5) {
                                        Text(tab.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(viewModel.selectedFilter == tab ? .semibold : .regular)
                                            .foregroundColor(viewModel.selectedFilter == tab ? AppColors.accentBlue : textS)
                                        UnreadCountBadge(count: appState.unreadBoletoCount(for: tab))
                                    }
                                    Rectangle()
                                        .fill(viewModel.selectedFilter == tab ? AppColors.accentBlue : Color.clear)
                                        .frame(height: 2)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button {
                            viewModel.showFilterModal = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.body)
                                Text("Filtros")
                                    .font(.subheadline)
                            }
                            .foregroundColor(AppColors.accentBlue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.textSecondary(dark: isDark).opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(bg)

                    ScrollView {
                        if viewModel.filteredItems.isEmpty {
                            VStack(spacing: 10) {
                                Text("Boleto não gerado")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(textP)
                                Text("Não há registros para exibir nesta aba.")
                                    .font(.subheadline)
                                    .foregroundColor(textS)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                            .padding(.horizontal, 20)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredItems) { item in
                                    ParcelaCardExtrato(
                                        item: item,
                                        isDark: isDark,
                                        isUnread: appState.isBoletoUnread(item.id)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                    .refreshable {
                        await viewModel.loadFinancialStatement(forceRefresh: true)
                        await appState.refreshUnreadBoletoCounts(from: viewModel.allItems)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showFilterModal) {
            FiltrarParcelasModal(
                empreendimento: $viewModel.filtroEmpreendimento,
                empreendimentoOptions: viewModel.empreendimentoOptions,
                periodo: $viewModel.filtroPeriodo,
                onCancel: { viewModel.showFilterModal = false },
                onApply: { viewModel.applyFiltersFromModal() },
                isDark: isDark
            )
        }
        .onAppear {
            Task {
                await viewModel.loadFinancialStatement()
                await appState.refreshUnreadBoletoCounts(from: viewModel.allItems)
                if viewModel.selectedFilter == .aVencer || viewModel.selectedFilter == .vencidas {
                    appState.markBoletoTabAsSeen(viewModel.selectedFilter, items: viewModel.allItems)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Linha 1: nome + parcela  |  tag (A Vencer / Vencidas / Pagas)
            HStack(alignment: .top) {
                Text("\(item.ventureName) - \(item.parcela)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                    .lineLimit(2)
                Spacer()
                HStack(spacing: 6) {
                    if isUnread && mostraBotoesBoleto {
                        Text("Novo")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppColors.accentBlue)
                            .clipShape(Capsule())
                    }
                    Text(statusText(item.status))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(statusTagColor(item.status))
                        )
                }
            }

            // Linha 2: Vencimento (esq)  |  Valor (dir)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vencimento")
                        .font(.caption)
                        .foregroundColor(textS)
                    Text(item.dueDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(textP)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Valor")
                        .font(.caption)
                        .foregroundColor(textS)
                    Text(formatCurrency(item.amount))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                }
            }

            if item.status == .paid {
                let paymentDate = item.paymentDate?.trimmingCharacters(in: .whitespacesAndNewlines)
                HStack(alignment: .top) {
                    Text("Data de pagamento")
                        .font(.caption)
                        .foregroundColor(textS)
                    Spacer()
                    Text((paymentDate?.isEmpty == false) ? paymentDate! : "Não informada")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(textP)
                }
            }

            // Botões: Ver Boleto | Gerar 2ª Via (instalar) — somente para "A Vencer"
            if mostraBotoesBoleto {
                HStack(spacing: 12) {
                    Button {
                        verBoleto()
                    } label: {
                        HStack(spacing: 6) {
                            if loadingBoleto {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "eye.fill")
                                    .font(.caption)
                            }
                            Text("Ver Boleto")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.accentBlue)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(loadingBoleto)

                    Button {
                        instalarDocumento()
                    } label: {
                        HStack(spacing: 6) {
                            if loadingBoleto {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.down.doc.fill")
                                    .font(.caption)
                            }
                            Text("Gerar 2ª Via")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.accentBlue)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(loadingBoleto)
                }
            }

        }
        .padding()
        .background(cardBg)
        .cornerRadius(12)
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
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.accentBlue)
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
