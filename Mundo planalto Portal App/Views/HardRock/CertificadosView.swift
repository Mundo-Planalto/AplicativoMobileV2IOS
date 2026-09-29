//
//  CertificadosView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Certificados de viagem (push) — docs/telas.md.
//

import SwiftUI
import Combine

@MainActor
final class CertificadosViewModel: ObservableObject {
    @Published var requests: [CertificateRequest] = []
    @Published var solicitando: CertificateType?
    @Published var mostrarConfirmacao = false

    let options = RepositoryProvider.certificados.options()

    func load() async {
        requests = (try? await RepositoryProvider.certificados.requests()) ?? []
    }

    func solicitado(_ type: CertificateType) -> Bool {
        requests.contains { $0.type == type && ($0.status == .requested || $0.status == .inProgress) }
    }

    func solicitar(_ type: CertificateType) async {
        solicitando = type
        if let created = try? await RepositoryProvider.certificados.request(type: type) {
            requests.removeAll { $0.id == created.id }
            requests.append(created)
            mostrarConfirmacao = true
        }
        solicitando = nil
    }
}

struct CertificadosView: View {
    @StateObject private var vm = CertificadosViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Certificados de viagem", subtitulo: "Escolha uma experiência para solicitar")

                ForEach(vm.options) { option in
                    let jaSolicitado = vm.solicitado(option.type)
                    HrPhotoCard(url: option.imageUrl, height: 260) {
                        VStack(alignment: .leading, spacing: 8) {
                            HrTag(text: option.type.tag)
                            Text(option.titulo)
                                .font(HrFont.heroTitle)
                                .foregroundColor(.white)
                            Text(option.descricao)
                                .font(HrFont.caption)
                                .foregroundColor(.white.opacity(0.85))
                            if jaSolicitado {
                                HrStatusDot(text: "Solicitado", color: .hrWarning)
                                HrOutlineButton(text: "Aguardando Pós-vendas", isEnabled: false) {}
                            } else {
                                HrStatusDot(text: "Disponível")
                                HrGoldButton(text: "Solicitar código", isLoading: vm.solicitando == option.type) {
                                    Task { await vm.solicitar(option.type) }
                                }
                            }
                        }
                    }
                }

                HrCard {
                    HStack(alignment: .top, spacing: 12) {
                        HrIconBox(icon: "info.circle")
                        Text("Após a solicitação, o Pós-vendas fará a reserva e a liberação do código.")
                            .font(HrFont.caption)
                            .foregroundColor(.hrTextMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .task { await vm.load() }
        .alert("Solicitação enviada", isPresented: $vm.mostrarConfirmacao) {
            Button("OK") {}
        } message: {
            Text("Sua solicitação foi registrada. O Pós-vendas entrará em contato com o código do certificado.")
        }
    }
}

#Preview {
    NavigationStack { CertificadosView() }
}
