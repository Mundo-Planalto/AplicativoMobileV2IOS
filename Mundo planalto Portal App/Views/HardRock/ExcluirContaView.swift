//
//  ExcluirContaView.swift
//  Mundo Planalto
//
//  Exclusão de conta (push, a partir de Perfil > Segurança): explica o que acontece, pede
//  confirmação, envia o pedido e encerra a sessão. Exigência da App Store para apps com cadastro.
//

import SwiftUI
import Combine

@MainActor
final class ExcluirContaViewModel: ObservableObject {
    @Published var motivo = ""
    @Published var confirmando = false
    @Published var enviando = false
    @Published var erro: String?
    @Published var resultado: AccountDeletionResult?

    func solicitar() async {
        enviando = true
        erro = nil
        do {
            let motivoLimpo = motivo.trimmingCharacters(in: .whitespacesAndNewlines)
            resultado = try await RepositoryProvider.account.requestDeletion(reason: motivoLimpo.isEmpty ? nil : motivoLimpo)
        } catch {
            erro = AppErrorMapper.userMessage(for: error, fallback: "Não foi possível enviar o pedido. Tente novamente ou fale com a Central de Contratos.")
        }
        enviando = false
    }
}

struct ExcluirContaView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = ExcluirContaViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Excluir conta", subtitulo: "Encerra seu acesso ao app e ao portal")

                HrCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("O que acontece ao excluir a conta")
                            .font(HrFont.itemTitle)
                            .foregroundColor(.white)
                        item("Seu login no app e no Portal do Cliente é desativado e os dados de uso do app são apagados.")
                        item("Os dados do seu contrato e do financeiro são mantidos pelo prazo exigido por lei; eles não dependem da conta no app.")
                        item("A Central de Contratos confirma o pedido e você recebe um protocolo. Para voltar a usar o app depois, será preciso um novo primeiro acesso.")
                    }
                }

                HrCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HrFormField(label: "Motivo (opcional)", text: $vm.motivo, placeholder: "Conte por que está saindo")
                        if let erro = vm.erro {
                            Text(erro).font(HrFont.caption).foregroundColor(.hrError).fixedSize(horizontal: false, vertical: true)
                        }
                        if RepositoryProvider.acoesSimuladas {
                            HrEmBreveButton()
                            HrAvisoPendente(texto: "A exclusão pelo app ainda não está ligada ao servidor. Enquanto isso, peça pela Central de Contratos.")
                        } else {
                            Button {
                                vm.confirmando = true
                            } label: {
                                HStack(spacing: 6) {
                                    if vm.enviando { ProgressView().tint(.white).scaleEffect(0.8) }
                                    Text("Solicitar exclusão da conta").font(HrFont.buttonPrimary)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: HrMetrics.primaryButtonHeight)
                                .background(RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous).fill(Color.hrError))
                            }
                            .buttonStyle(HrPressStyle())
                            .disabled(vm.enviando)
                        }
                    }
                }

                Text("Dúvidas? Fale com a Central de Contratos pelos canais de atendimento do portal.")
                    .font(HrFont.captionSmall)
                    .foregroundColor(.hrTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .scrollDismissesKeyboard(.interactively)
        .hrScreen()
        .alert("Excluir sua conta?", isPresented: $vm.confirmando) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) { Task { await vm.solicitar() } }
        } message: {
            Text("Seu acesso será encerrado depois da confirmação da Central de Contratos. Esta ação não pode ser desfeita pelo app.")
        }
        .alert("Pedido registrado", isPresented: Binding(get: { vm.resultado != nil }, set: { if !$0 { vm.resultado = nil } })) {
            Button("OK") {
                vm.resultado = nil
                Task { await appState.logout() }
            }
        } message: {
            if let r = vm.resultado {
                Text("Protocolo \(r.protocolNumber). A Central de Contratos conclui \(r.prazoTexto). Você será desconectado agora.")
            }
        }
    }

    private func item(_ texto: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill").font(.system(size: 5)).foregroundColor(.hrGold).padding(.top, 7)
            Text(texto).font(HrFont.caption).foregroundColor(.hrTextMuted).fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack { ExcluirContaView() }
        .environmentObject(AppState.shared)
}
