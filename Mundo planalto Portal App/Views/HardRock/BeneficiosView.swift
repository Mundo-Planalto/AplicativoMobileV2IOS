//
//  BeneficiosView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Aba Benefícios (docs/telas.md).
//

import SwiftUI
import Combine

@MainActor
final class BeneficiosViewModel: ObservableObject {
    @Published var partners: [Partner] = []
    @Published var coupon: Coupon?
    @Published var filtro = "Todos"
    let filtros = ["Todos", "Viagens", "Gramado"]

    func load() async {
        partners = (try? await RepositoryProvider.beneficios.partners()) ?? []
    }

    func abrirCupom(partnerId: Int) async {
        coupon = try? await RepositoryProvider.beneficios.coupon(partnerId: partnerId)
    }

    var mostraViagens: Bool { filtro == "Todos" || filtro == "Viagens" }
    var mostraGramado: Bool { filtro == "Todos" || filtro == "Gramado" }
    var mostraUnity: Bool { filtro == "Todos" || filtro == "Viagens" }
}

struct BeneficiosView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = BeneficiosViewModel()

    private let imagemGramado = "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800"
    private let imagemRestaurante = "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(nome: appState.currentMember.nome, titulo: "Benefícios", subtitulo: "Vantagens exclusivas para você") {
                    router.push(.avisosNoticias)
                }

                HrChipRow(options: vm.filtros, selected: $vm.filtro)

                if vm.mostraViagens {
                    HrPhotoCard(url: imagemGramado, height: 240) {
                        VStack(alignment: .leading, spacing: 8) {
                            HrTag(text: "Certificado")
                            Text("Experiência Gramado")
                                .font(HrFont.heroTitle)
                                .foregroundColor(.white)
                            HrStatusDot(text: "Disponível")
                            HrGoldButton(text: "Solicitar código") { router.push(.certificados) }
                        }
                    }
                }

                if vm.mostraGramado {
                    HrPhotoCard(url: imagemRestaurante, height: 240) {
                        VStack(alignment: .leading, spacing: 8) {
                            HrTag(text: "Parceiro")
                            Text("20% no jantar")
                                .font(HrFont.heroTitle)
                                .foregroundColor(.white)
                            Text("Restaurante Belle du Val • Gramado")
                                .font(HrFont.caption)
                                .foregroundColor(.white.opacity(0.85))
                            HrGoldButton(text: "Ver voucher") { Task { await vm.abrirCupom(partnerId: 2) } }
                        }
                    }
                }

                if vm.mostraUnity {
                    HrCard(highlighted: true) {
                        HStack(spacing: 12) {
                            HrIconBox(icon: "globe")
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Hard Rock Unity")
                                    .font(HrFont.sectionTitle)
                                    .foregroundColor(.white)
                                Text("Conecte sua conta e desbloqueie benefícios")
                                    .font(HrFont.caption)
                                    .foregroundColor(.hrTextMuted)
                            }
                            Spacer()
                            Button { if let u = URL(string: AppConfig.unityURL) { UIApplication.shared.open(u) } } label: {
                                Text("Cadastrar")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.hrGoldLight)
                            }
                            .buttonStyle(HrPressStyle())
                        }
                    }
                }

                if vm.mostraGramado {
                    HrSectionTitle(
                        titulo: "Parceiros em Gramado",
                        subtitulo: "Mínimo de 10% de desconto • validação por cupom",
                        acao: "Ver ofertas"
                    ) { router.switchTab(.ofertas) }
                    .padding(.top, 8)

                    ForEach(vm.partners) { partner in
                        HrListRow(icon: iconePara(partner.category), titulo: partner.name, subtitulo: partner.discountText) {
                            Task { await vm.abrirCupom(partnerId: partner.id) }
                        }
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .task { await vm.load() }
        .sheet(item: $vm.coupon) { coupon in
            HrCouponSheet(coupon: coupon)
        }
    }

    private func iconePara(_ c: PartnerCategory) -> String {
        switch c {
        case .gastronomia: return "fork.knife"
        case .hospedagem: return "bed.double.fill"
        case .experiencias: return "ticket.fill"
        case .compras: return "bag.fill"
        case .outros: return "tag.fill"
        }
    }
}

extension Coupon: Identifiable {
    var id: String { "\(partnerId)-\(code)" }
}

#Preview {
    NavigationStack { BeneficiosView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
