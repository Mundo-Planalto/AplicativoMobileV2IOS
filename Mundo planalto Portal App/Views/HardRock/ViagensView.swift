//
//  ViagensView.swift
//  Mundo Planalto
//
//  Viagens (push): certificados do cliente com status, protocolo e validade, reservas e
//  vouchers (docs/telas.md). Os certificados vêm do cadastro da Central de Contratos.
//

import SwiftUI
import Combine

@MainActor
final class ViagensViewModel: ObservableObject {
    @Published var certificates: [Certificate] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var confirmando: Certificate?
    @Published var solicitandoId: Int?
    @Published var resultado: CertificateRequestResult?
    @Published var codigoCopiado: Int?

    func load() async {
        isLoading = certificates.isEmpty
        error = nil
        do {
            certificates = try await RepositoryProvider.certificates.certificates()
        } catch {
            self.error = AppErrorMapper.userMessage(for: error, fallback: "Não foi possível carregar seus certificados.")
        }
        isLoading = false
    }

    func solicitar(_ cert: Certificate) async {
        solicitandoId = cert.id
        do {
            let result = try await RepositoryProvider.certificates.requestActivation(id: cert.id)
            if let i = certificates.firstIndex(where: { $0.id == cert.id }) {
                certificates[i].status = .requested
                certificates[i].protocolNumber = result.protocolNumber
            }
            resultado = result
        } catch {
            self.error = AppErrorMapper.userMessage(for: error, fallback: "Não foi possível enviar a solicitação. Tente novamente.")
        }
        solicitandoId = nil
    }
}

struct ViagensView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = ViagensViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Viagens", subtitulo: "Seus certificados, reservas e vouchers")

                HrSectionTitle(titulo: "Meus certificados", subtitulo: "Cadastrados pela Central de Contratos na sua compra")
                    .padding(.top, 4)

                if vm.isLoading {
                    HrCard { HStack { Spacer(); ProgressView().tint(.hrGold); Spacer() } }
                } else if let error = vm.error, vm.certificates.isEmpty {
                    HrCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(error).font(HrFont.body).foregroundColor(.white)
                            HrOutlineButton(text: "Tentar novamente") { Task { await vm.load() } }
                        }
                    }
                } else if vm.certificates.isEmpty {
                    emptyCard(icon: "ticket", text: "Você ainda não tem certificados cadastrados.")
                } else {
                    ForEach(vm.certificates) { cert in
                        certificateCard(cert)
                    }
                }

                HrSectionTitle(titulo: "Minhas viagens").padding(.top, 8)
                emptyCard(icon: "airplane", text: "Suas reservas aparecerão aqui quando forem confirmadas pelo Pós-vendas.")

                HrSectionTitle(titulo: "Vouchers").padding(.top, 8)
                emptyCard(icon: "gift.fill", text: "Em breve: seus vouchers e brindes digitais.")

                HrCard {
                    HStack(alignment: .top, spacing: 12) {
                        HrIconBox(icon: "info.circle")
                        Text("Após a solicitação, o Pós-vendas faz a reserva e libera o código. Você recebe um aviso no app.")
                            .font(HrFont.caption)
                            .foregroundColor(.hrTextMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .refreshable { await vm.load() }
        .hrScreen()
        .task { await vm.load() }
        .alert("Solicitar ativação do certificado?", isPresented: Binding(get: { vm.confirmando != nil }, set: { if !$0 { vm.confirmando = nil } })) {
            Button("Cancelar", role: .cancel) { vm.confirmando = nil }
            Button("Solicitar") {
                if let cert = vm.confirmando {
                    vm.confirmando = nil
                    Task { await vm.solicitar(cert) }
                }
            }
        } message: {
            Text("O Pós-vendas vai fazer a reserva e liberar o código.")
        }
        .alert("Solicitação enviada", isPresented: Binding(get: { vm.resultado != nil }, set: { if !$0 { vm.resultado = nil } })) {
            Button("OK") { vm.resultado = nil }
        } message: {
            if let r = vm.resultado {
                Text("Protocolo \(r.protocolNumber). O Pós-vendas responde \(r.prazoTexto).")
            }
        }
    }

    private func emptyCard(icon: String, text: String) -> some View {
        HrCard {
            HStack(alignment: .top, spacing: 12) {
                HrIconBox(icon: icon)
                Text(text)
                    .font(HrFont.caption)
                    .foregroundColor(.hrTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func statusDot(_ cert: Certificate) -> some View {
        switch cert.status {
        case .available: HrStatusDot(text: "Disponível")
        case .requested: HrStatusDot(text: "Aguardando Pós-vendas", color: .hrWarning)
        case .released: HrStatusDot(text: "Liberado")
        case .used: HrStatusDot(text: "Utilizado", color: .hrTextMuted)
        case .expired: HrStatusDot(text: "Expirado", color: .hrError)
        }
    }

    private func certificateCard(_ cert: Certificate) -> some View {
        HrCard(highlighted: cert.status == .released) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HrTag(text: cert.type.tag)
                    Spacer()
                    statusDot(cert)
                }
                Text(cert.name)
                    .font(HrFont.sectionTitle)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(cert.quantidadeTexto)
                    .font(HrFont.caption)
                    .foregroundColor(.hrTextMuted)

                switch cert.status {
                case .used:
                    Text("Utilizado em \(HrFormat.dayMonthYear(cert.usedAt))")
                        .font(HrFont.caption).foregroundColor(.hrTextMuted)
                case .expired:
                    Text("Expirado em \(HrFormat.dayMonthYear(cert.expiresAt))")
                        .font(HrFont.caption).foregroundColor(.hrError)
                default:
                    if cert.expiresAt != nil {
                        Text("Expira em \(HrFormat.dayMonthYear(cert.expiresAt))")
                            .font(HrFont.caption)
                            .foregroundColor(cert.expiraEmBreve ? .hrError : .hrTextMuted)
                    }
                }

                if let protocolo = cert.protocolNumber, !protocolo.isEmpty {
                    Text("Protocolo \(protocolo)")
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                }

                switch cert.status {
                case .available:
                    HrGoldButton(text: "Solicitar ativação", isLoading: vm.solicitandoId == cert.id) { vm.confirmando = cert }
                        .padding(.top, 4)
                case .requested:
                    HrOutlineButton(text: "Aguardando Pós-vendas", isEnabled: false) {}
                        .padding(.top, 4)
                case .released:
                    if let code = cert.code, !code.isEmpty {
                        Button {
                            UIPasteboard.general.string = code
                            vm.codigoCopiado = cert.id
                            Task {
                                try? await Task.sleep(nanoseconds: 1_800_000_000)
                                if vm.codigoCopiado == cert.id { vm.codigoCopiado = nil }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(vm.codigoCopiado == cert.id ? "Código copiado" : "Código \(code)")
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: vm.codigoCopiado == cert.id ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.hrGoldLight)
                        }
                        .buttonStyle(HrPressStyle())
                        .accessibilityHint("Toque para copiar o código")
                    }
                    HrGoldButton(text: "Usar") { router.open(cert.useUrl) }
                        .padding(.top, 4)
                    Text("Você vai reservar na plataforma Mais Viagens com seu login de lá.")
                        .font(HrFont.captionSmall)
                        .foregroundColor(.hrTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                case .used, .expired:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ViagensView() }
        .environmentObject(AppRouter())
}
