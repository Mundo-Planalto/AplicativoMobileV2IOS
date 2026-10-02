//
//  AlteracaoDadosView.swift
//  Mundo Planalto
//
//  Alteração de dados (push): o cliente solicita troca de endereço, telefone ou e-mail
//  e a Central de Contratos confirma. Lista as solicitações com status.
//

import SwiftUI
import Combine

@MainActor
final class AlteracaoDadosViewModel: ObservableObject {
    @Published var campo: ChangeRequestField
    @Published var novoValor = ""
    @Published var endereco = AddressForm()
    @Published var solicitacoes: [ChangeRequest] = []
    @Published var valoresAtuais: [ChangeRequestField: String] = [:]
    @Published var enviando = false
    @Published var enviada = false
    @Published var erro: String?

    init(campo: ChangeRequestField) { self.campo = campo }

    var valorAtual: String { valoresAtuais[campo] ?? "—" }

    var podeEnviar: Bool {
        switch campo {
        case .address: return endereco.isValid
        case .phone: return novoValor.filter(\.isNumber).count >= 10
        case .email: return novoValor.contains("@") && novoValor.contains(".")
        }
    }

    func load() async {
        let perfil = PerfilViewModel()
        await perfil.loadUserData()
        valoresAtuais = [
            .phone: perfil.userPhone,
            .email: perfil.userEmail.isEmpty ? "—" : perfil.userEmail,
            .address: [perfil.userAddressLine1, perfil.userAddressLine2, perfil.userAddressCep].filter { !$0.isEmpty }.joined(separator: "\n")
        ]
        solicitacoes = (try? await RepositoryProvider.changeRequests.requests()) ?? []
    }

    func enviar() async {
        enviando = true
        erro = nil
        do {
            let created = try await RepositoryProvider.changeRequests.create(
                field: campo,
                newValue: novoValor.trimmingCharacters(in: .whitespacesAndNewlines),
                address: campo == .address ? endereco : nil
            )
            solicitacoes.insert(created, at: 0)
            novoValor = ""
            endereco = AddressForm()
            enviada = true
        } catch {
            erro = (error as? LocalizedError)?.errorDescription
                ?? AppErrorMapper.userMessage(for: error, fallback: "Não foi possível enviar a solicitação. Tente novamente.")
        }
        enviando = false
    }
}

struct AlteracaoDadosView: View {
    @StateObject private var vm: AlteracaoDadosViewModel

    init(campoInicial: ChangeRequestField = .phone) {
        _vm = StateObject(wrappedValue: AlteracaoDadosViewModel(campo: campoInicial))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Solicitar alteração", subtitulo: "A Central de Contratos confirma em até 2 dias úteis")

                HStack(spacing: 8) {
                    ForEach(ChangeRequestField.allCases) { field in
                        HrChip(text: field.titulo, selected: vm.campo == field) {
                            vm.campo = field
                            vm.erro = nil
                        }
                    }
                }

                HrCard {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(vm.campo.titulo) atual").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                            Text(vm.valorAtual.isEmpty ? "—" : vm.valorAtual)
                                .font(HrFont.body)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        switch vm.campo {
                        case .phone:
                            HrFormField(label: "Novo telefone", text: $vm.novoValor, placeholder: "(00) 00000-0000", keyboard: .phonePad)
                        case .email:
                            HrFormField(label: "Novo e-mail", text: $vm.novoValor, placeholder: "nome@exemplo.com", keyboard: .emailAddress, capitalization: .never)
                        case .address:
                            HrFormField(label: "CEP", text: $vm.endereco.zipCode, placeholder: "00000-000", keyboard: .numbersAndPunctuation, maxLength: 9)
                            HrFormField(label: "Logradouro", text: $vm.endereco.street, placeholder: "Rua, avenida...")
                            HStack(spacing: 8) {
                                HrFormField(label: "Número", text: $vm.endereco.number, placeholder: "Nº", keyboard: .numbersAndPunctuation)
                                    .frame(width: 96)
                                HrFormField(label: "Complemento", text: $vm.endereco.complement, placeholder: "Opcional")
                            }
                            HrFormField(label: "Bairro", text: $vm.endereco.neighborhood, placeholder: "Bairro")
                            HStack(spacing: 8) {
                                HrFormField(label: "Cidade", text: $vm.endereco.city, placeholder: "Cidade")
                                HrFormField(label: "UF", text: $vm.endereco.state, placeholder: "UF", capitalization: .characters, maxLength: 2)
                                    .frame(width: 84)
                            }
                        }

                        if let erro = vm.erro {
                            Text(erro)
                                .font(HrFont.caption)
                                .foregroundColor(.hrError)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HrGoldButton(text: "Enviar solicitação", trailingArrow: false, isLoading: vm.enviando, isEnabled: vm.podeEnviar) {
                            Task { await vm.enviar() }
                        }
                    }
                }

                HrSectionTitle(titulo: "Suas solicitações").padding(.top, 8)
                if vm.solicitacoes.isEmpty {
                    HrCard {
                        Text("Você ainda não fez solicitações.")
                            .font(HrFont.caption).foregroundColor(.hrTextMuted)
                    }
                } else {
                    ForEach(vm.solicitacoes) { item in
                        HrListRow(icon: icone(item.field), titulo: "\(item.field.titulo) • \(HrFormat.dayMonthYear(item.createdAt))", subtitulo: item.newValue) {
                            HrTag(text: item.status.texto, color: cor(item.status))
                                .fixedSize()
                        }
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .scrollDismissesKeyboard(.interactively)
        .hrScreen()
        .task { await vm.load() }
        .alert("Solicitação enviada", isPresented: $vm.enviada) {
            Button("OK") {}
        } message: {
            Text("A Central de Contratos confirma em até 2 dias úteis.")
        }
    }

    private func icone(_ field: ChangeRequestField) -> String {
        switch field {
        case .address: return "house.fill"
        case .phone: return "phone.fill"
        case .email: return "envelope.fill"
        }
    }

    private func cor(_ status: ChangeRequestStatus) -> Color {
        switch status {
        case .pending: return .hrWarning
        case .approved: return .hrSuccess
        case .rejected: return .hrError
        }
    }
}

#Preview {
    NavigationStack { AlteracaoDadosView() }
}
