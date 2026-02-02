//
//  CriarTicketView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct CriarTicketView: View {
    @StateObject private var viewModel = CriarTicketViewModel()
    @State private var navigateBack = false

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

                        Text("Criar Ticket")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                ScrollView {
                    VStack(spacing: 20) {
                        // Assunto
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assunto *")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("Digite o assunto do ticket", text: $viewModel.subject)
                                .padding(12)
                                .background(AppColors.cardBackground)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)

                        // Prioridade
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prioridade")
                                .font(.headline)
                                .foregroundColor(.white)

                            Picker("Prioridade", selection: $viewModel.priority) {
                                ForEach(TicketPriority.allCases, id: \.self) { priority in
                                    HStack {
                                        Circle()
                                            .fill(priority.color)
                                            .frame(width: 12, height: 12)
                                        Text(priority.rawValue)
                                            .foregroundColor(.white)
                                    }
                                    .tag(priority)
                                }
                            }
                            .pickerStyle(.segmented)
                            .background(AppColors.cardBackground)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        // Descrição
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descrição *")
                                .font(.headline)
                                .foregroundColor(.white)

                            ZStack(alignment: .topLeading) {
                                if viewModel.description.isEmpty {
                                    Text("Descreva detalhadamente o problema ou solicitação (mínimo 10 caracteres)")
                                        .foregroundColor(.gray.opacity(0.7))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 12)
                                }

                                TextEditor(text: $viewModel.description)
                                    .padding(8)
                                    .frame(minHeight: 120)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                        .padding(.horizontal)

                        // Informações adicionais
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Informações do Ticket")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            TicketInfoRow(icon: "person.fill", title: "Solicitante", value: "João Silva")
                            TicketInfoRow(icon: "envelope.fill", title: "E-mail", value: "joao.silva@email.com")
                            TicketInfoRow(icon: "phone.fill", title: "CPF", value: "123.456.789-00")
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // Botão criar ticket
                        VStack(spacing: 16) {
                            GradientButton(
                                title: "Criar Ticket",
                                action: {
                                    Task {
                                        await viewModel.createTicket()
                                    }
                                },
                                isLoading: viewModel.state == .loading,
                                isEnabled: viewModel.isFormValid
                            )
                            .padding(.horizontal)

                            // Mensagens de estado
                            switch viewModel.state {
                            case .error(let message):
                                Text(message)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            case .success(let ticketId):
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)

                                    Text("Ticket criado com sucesso!")
                                        .foregroundColor(.green)
                                        .font(.headline)

                                    Text("ID do ticket: \(ticketId)")
                                        .foregroundColor(AppColors.accentCyan)
                                        .font(.subheadline)

                                    Button("Voltar") {
                                        navigateBack = true
                                    }
                                    .foregroundColor(AppColors.accentCyan)
                                    .padding(.top, 8)
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            default:
                                EmptyView()
                            }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationDestination(isPresented: $navigateBack) {
            // Voltar para a tela anterior
            EmptyView()
        }
    }
}

struct TicketInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accentCyan)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        CriarTicketView()
    }
}