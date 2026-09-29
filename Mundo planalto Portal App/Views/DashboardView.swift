//
//  DashboardView.swift
//  Mundo planalto Portal App
//
//  Tela principal do app (resumo financeiro, ações rápidas, empreendimentos).
//

import SwiftUI

private let emailAtendimento = "atendimento@mundoplanalto.com.br"
private let whatsAppURL = "https://api.whatsapp.com/send/?phone=556240002200&text&type=phone_number&app_absent=0"

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    @State private var navigateToSupport = false
    @State private var showChatScreen = false
    @State private var navigateToFinancial = false
    @State private var navigateToInforme = false
    @State private var showSolicitarAtendimento = false
    @State private var solicitarAtendimentoMessage = ""
    @State private var supportAlertMessage: String?
    @State private var showSupportAlert = false

    private var isDark: Bool { appState.isDarkTheme }

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary(dark: isDark)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    HeaderSection(greeting: viewModel.greeting, isDark: isDark)
                        .padding(.horizontal)

                    FinancialOverviewCard(
                        summary: viewModel.financialSummary,
                        isDark: isDark,
                        onVerExtrato: { navigateToFinancial = true },
                        isLoading: viewModel.isLoadingFinancial
                    )
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ações Rápidas")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary(dark: isDark))
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(DashboardQuickAction.allCases.filter { $0 != .chatAI }) { action in
                                QuickActionButton(action: action, isDark: isDark)
                                    .onTapGesture {
                                        handleQuickAction(action)
                                    }
                            }
                        }
                        .padding(.horizontal)

                        MeusEmpreendimentosCard(isDark: isDark)
                            .padding(.horizontal)
                            .onTapGesture {
                                NotificationCenter.default.post(name: NSNotification.Name("SwitchToVentures"), object: nil)
                            }
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.refreshFinancialOverview()
            }
        }
        .sheet(isPresented: $showChatScreen) {
            ChatAIScreen()
        }
        .sheet(isPresented: $showSolicitarAtendimento) {
            SolicitarAtendimentoModal(
                message: $solicitarAtendimentoMessage,
                isDark: isDark
            ) { msg in
                let cpf = PreferencesManager.shared.getUserCpfCnpj() ?? ""
                do {
                    let result = try await SupportService.shared.sendExternalSupportRequest(cpf: cpf, message: msg)
                    await MainActor.run {
                        solicitarAtendimentoMessage = ""
                        showSolicitarAtendimento = false
                        supportAlertMessage = result.success ? (result.message ?? "Solicitação enviada com sucesso.") : result.message
                        showSupportAlert = true
                    }
                } catch {
                    await MainActor.run {
                        supportAlertMessage = "Erro de conexão. Tente novamente."
                        showSupportAlert = true
                    }
                }
            }
            .presentationDetents([.height(410)])
            .presentationDragIndicator(.visible)
        }
        .alert("Solicitação de Atendimento", isPresented: $showSupportAlert) {
            Button("OK") { supportAlertMessage = nil }
        } message: {
            if let msg = supportAlertMessage {
                Text(msg)
            }
        }
        .navigationDestination(isPresented: $navigateToFinancial) {
            ExtratoView()
        }
        .navigationDestination(isPresented: $navigateToInforme) {
            InformeRendimentosView()
        }
        .navigationDestination(isPresented: $navigateToSupport) {
            CriarTicketView()
        }
        .onAppear {
            Task {
                await viewModel.loadDashboardData()
            }
        }
    }

    private func handleQuickAction(_ action: DashboardQuickAction) {
        switch action {
        case .viewStatement:
            navigateToFinancial = true
        case .trackWorks:
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToVentures"), object: nil)
        case .newsAlerts:
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToNews"), object: nil)
        case .irReport:
            navigateToInforme = true
        case .chatAI:
            showChatScreen = true
        case .requestService:
            solicitarAtendimentoMessage = ""
            showSolicitarAtendimento = true
        case .sendEmail:
            let mailto = "mailto:\(emailAtendimento)?subject=Contato%20Portal"
            if let url = URL(string: mailto) {
                UIApplication.shared.open(url)
            }
        case .whatsappCall:
            if let url = URL(string: whatsAppURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState.shared)
}

