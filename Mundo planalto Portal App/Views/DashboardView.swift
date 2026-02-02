//
//  DashboardView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var navigateToSupport = false
    
    @State private var showChatScreen = false
    
    // Você também já tem (ou deveria ter) esta, pois usa no .navigationDestination
    @State private var navigateToProfile = false    // já existe no seu código
    
    // E esta também aparece no switch, então adicione se ainda não tiver
    @State private var navigateToFinancial = false  // ← faltando no código mostrado
    
    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderSection(greeting: viewModel.greeting)
                        .padding(.horizontal)

                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 50)
                    } else {
                        // Resumo Financeiro
                        if let summary = viewModel.financialSummary {
                            FinancialOverviewCard(summary: summary)
                                .padding(.horizontal)
                        }

                        // Ações Rápidas
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ações Rápidas")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 20) {
                                ForEach(QuickAction.allCases) { action in
                                    QuickActionButton(action: action)
                                        .onTapGesture {
                                            handleQuickAction(action)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showChatScreen) {
            ChatAIScreen()
        }
            .navigationDestination(isPresented: $navigateToProfile) {
                SistemaView()
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

    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .viewStatement:
            navigateToFinancial = true
        case .trackWorks:
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToVentures"), object: nil)
        case .newsAlerts:
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToNews"), object: nil)
        case .profile:
            navigateToProfile = true
        case .chatAI:
            showChatScreen = true
        case .irReport:
            // TODO: Implementar navegação para informe IR
            print("Informe IR")
        case .changeAddress:
            // TODO: Implementar mudança de endereço
            print("Mudar endereço")
        case .requestService:
            navigateToSupport = true
        case .sendEmail:
            // TODO: Implementar envio de email
            print("Enviar email")
        case .whatsappCall:
            // TODO: Implementar chamada WhatsApp
            print("Chamar WhatsApp")
        }
    }
}

#Preview {
    DashboardView()
}
