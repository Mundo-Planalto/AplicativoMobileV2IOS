//
//  PerfilViagemView.swift
//  Mundo Planalto
//
//  Perfil de viagem (push): onde mora, destinos preferidos (até 4) e próxima viagem.
//  Pré-preenchido com as respostas da compra; cada edição fica registrada para o Pós-vendas.
//  Também: campo de formulário padrão e troca de senha.
//

import SwiftUI
import Combine

@MainActor
final class PerfilViagemViewModel: ObservableObject {
    @Published var cidade = ""
    @Published var uf = ""
    @Published var destinos: [String] = []
    @Published var quando: NextTripWhen = .unknown
    @Published var paraOnde = ""
    @Published var isLoading = true
    @Published var isSaving = false
    @Published var salvo = false
    @Published var erro: String?

    func load() async {
        if let p = try? await RepositoryProvider.travelProfile.profile() {
            cidade = p.homeCity
            uf = p.homeState
            destinos = p.preferredDestinations
            quando = p.nextTripWhen ?? .unknown
            paraOnde = p.nextTripDestination ?? ""
        }
        isLoading = false
    }

    func alternar(_ destino: String) {
        if let i = destinos.firstIndex(of: destino) {
            destinos.remove(at: i)
        } else if destinos.count < TravelDestinations.maxSelected {
            destinos.append(destino)
        }
    }

    func salvar() async {
        isSaving = true
        erro = nil
        let profile = TravelProfile(
            homeCity: cidade.trimmingCharacters(in: .whitespaces),
            homeState: uf.trimmingCharacters(in: .whitespaces).uppercased(),
            preferredDestinations: destinos,
            nextTripWhen: quando,
            nextTripDestination: paraOnde.trimmingCharacters(in: .whitespaces),
            source: "app"
        )
        do {
            _ = try await RepositoryProvider.travelProfile.save(profile)
            salvo = true
        } catch {
            erro = AppErrorMapper.userMessage(for: error, fallback: "Não foi possível salvar. Tente novamente.")
        }
        isSaving = false
    }
}

struct PerfilViagemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = PerfilViagemViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Perfil de viagem", subtitulo: "Conte para onde você quer ir")

                HrCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Onde você mora").font(HrFont.itemTitle).foregroundColor(.white)
                        HStack(spacing: 8) {
                            HrFormField(label: "Cidade", text: $vm.cidade, placeholder: "Cidade")
                            HrFormField(label: "UF", text: $vm.uf, placeholder: "UF", capitalization: .characters, maxLength: 2)
                                .frame(width: 84)
                        }
                    }
                }

                HrCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Destinos preferidos").font(HrFont.itemTitle).foregroundColor(.white)
                            Spacer()
                            Text("\(vm.destinos.count) de \(TravelDestinations.maxSelected)")
                                .font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                        }
                        HrFlow(spacing: 8) {
                            ForEach(TravelDestinations.all, id: \.self) { destino in
                                HrChip(text: destino, selected: vm.destinos.contains(destino)) { vm.alternar(destino) }
                            }
                        }
                    }
                }

                HrCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quando pretende viajar").font(HrFont.itemTitle).foregroundColor(.white)
                        HrFlow(spacing: 8) {
                            ForEach(NextTripWhen.allCases) { opcao in
                                HrChip(text: opcao.texto, selected: vm.quando == opcao) { vm.quando = opcao }
                            }
                        }
                        HrFormField(label: "Para onde", text: $vm.paraOnde, placeholder: "Ex.: Gramado")
                            .padding(.top, 4)
                    }
                }

                Text("Preenchido com as respostas da sua compra. Suas alterações ficam registradas para o Pós-vendas.")
                    .font(HrFont.caption)
                    .foregroundColor(.hrTextMuted)
                    .fixedSize(horizontal: false, vertical: true)

                if let erro = vm.erro {
                    Text(erro).font(HrFont.caption).foregroundColor(.hrError)
                }

                HrGoldButton(text: "Salvar", trailingArrow: false, isLoading: vm.isSaving) {
                    Task { await vm.salvar() }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .scrollDismissesKeyboard(.interactively)
        .hrScreen()
        .task { await vm.load() }
        .hrToast("Perfil atualizado", isPresented: $vm.salvo) { dismiss() }
    }
}

// MARK: - Campo de formulário padrão

struct HrFormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .sentences
    var maxLength: Int? = nil
    var isSecure = false
    var readOnly = false

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.hrTextMuted.opacity(0.7)))
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.hrTextMuted.opacity(0.7)))
                }
            }
            .font(.system(size: 15))
            .foregroundColor(readOnly ? .hrTextMuted : .white)
            .tint(.hrGold)
            .keyboardType(keyboard)
            .textInputAutocapitalization(capitalization)
            .autocorrectionDisabled()
            .focused($focused)
            .disabled(readOnly)
            .onChange(of: text) { _, value in
                if let maxLength, value.count > maxLength { text = String(value.prefix(maxLength)) }
            }
            .padding(.horizontal, 12)
            .frame(height: 46)
            .background(RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous).fill(Color.hrSurfaceElevated))
            .overlay(
                RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                    .stroke(focused ? Color.hrGold : Color.hrGoldBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Toast

private struct HrToastModifier: ViewModifier {
    let text: String
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if isPresented {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.hrSuccess)
                    Text(text).font(HrFont.itemTitle).foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.hrSurfaceElevated))
                .overlay(Capsule().stroke(Color.hrGoldBorder, lineWidth: 1))
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    withAnimation { isPresented = false }
                    onDismiss?()
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPresented)
    }
}

extension View {
    func hrToast(_ text: String, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(HrToastModifier(text: text, isPresented: isPresented, onDismiss: onDismiss))
    }
}

// MARK: - Trocar senha (POST auth/change-password)

struct TrocarSenhaView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var atual = ""
    @State private var nova = ""
    @State private var confirmacao = ""
    @State private var enviando = false
    @State private var erro: String?
    @State private var sucesso = false

    private var valido: Bool { !atual.isEmpty && nova.count >= 6 && nova == confirmacao }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Trocar senha", subtitulo: "A nova senha precisa ter pelo menos 6 caracteres") { dismiss() }
                HrFormField(label: "Senha atual", text: $atual, capitalization: .never, isSecure: true)
                HrFormField(label: "Nova senha", text: $nova, capitalization: .never, isSecure: true)
                HrFormField(label: "Confirmar nova senha", text: $confirmacao, capitalization: .never, isSecure: true)
                if !confirmacao.isEmpty && nova != confirmacao {
                    Text("As senhas não conferem.").font(HrFont.caption).foregroundColor(.hrError)
                }
                if let erro {
                    Text(erro).font(HrFont.caption).foregroundColor(.hrError)
                }
                HrGoldButton(text: "Salvar nova senha", trailingArrow: false, isLoading: enviando, isEnabled: valido) {
                    Task { await enviar() }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.top, 8)
        }
        .hrScreen()
        .presentationBackground(Color.hrBlack)
        .alert("Senha alterada", isPresented: $sucesso) {
            Button("OK") { dismiss() }
        } message: {
            Text("Use a nova senha no próximo acesso.")
        }
    }

    private func enviar() async {
        erro = nil
        if AppState.shared.isDemoSession {
            erro = "Na demonstração a senha não é alterada. Entre com sua conta para trocar a senha."
            return
        }
        enviando = true
        do {
            _ = try await ProfileService.shared.changePassword(currentPassword: atual, newPassword: nova, confirmPassword: confirmacao)
            atual = ""; nova = ""; confirmacao = ""
            sucesso = true
        } catch {
            erro = AppErrorMapper.userMessage(for: error, fallback: "Não foi possível trocar a senha. Confira a senha atual e tente novamente.")
        }
        enviando = false
    }
}

#Preview {
    NavigationStack { PerfilViagemView() }
}
