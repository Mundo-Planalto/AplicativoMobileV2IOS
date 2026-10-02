//
//  CartaoDigitalView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Cartão do membro com QR Code (CoreImage) — docs/telas.md.
//

import SwiftUI
import Combine
import CoreImage
import CoreImage.CIFilterBuiltins

@MainActor
final class CartaoDigitalViewModel: ObservableObject {
    @Published var card: MemberCard?
    @Published var redemptions: [BenefitRedemption] = []

    func load() async {
        card = try? await RepositoryProvider.member.card()
        redemptions = (try? await RepositoryProvider.member.redemptions()) ?? []
    }
}

struct CartaoDigitalView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = CartaoDigitalViewModel()

    var body: some View {
        let member = appState.currentMember
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Cartão do membro", subtitulo: "Apresente nos parceiros para validar seus benefícios")

                CartaoDigitalCard(
                    nome: vm.card?.name ?? member.nome,
                    nivel: vm.card?.level.rawValue ?? member.nivel,
                    numeroMembro: vm.card?.memberNumber ?? member.numeroMembro,
                    desde: vm.card?.anoDesde ?? member.desde
                )

                HrCard {
                    VStack(spacing: 12) {
                        HrQRCodeView(content: vm.card?.verifyUrl ?? member.verifyUrl, size: 220)
                        HStack(spacing: 4) {
                            Text("Status: ")
                                .font(HrFont.body)
                                .foregroundColor(.hrTextMuted)
                            HrStatusDot(text: vm.card?.status.texto ?? "Ativo", color: (vm.card?.status ?? .active) == .active ? .hrSuccess : .hrError)
                        }
                        Text("Nível \(vm.card?.level.rawValue ?? member.nivel) • Membro desde \(vm.card?.anoDesde ?? member.desde)")
                            .font(HrFont.itemTitle)
                            .foregroundColor(.white)
                        Text("O parceiro escaneia o QR Code e vê em tempo real se o cliente está ativo e quantas vezes o benefício já foi usado.")
                            .font(HrFont.caption)
                            .foregroundColor(.hrTextMuted)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                }

                HrSectionTitle(titulo: "Utilizações recentes")
                    .padding(.top, 8)
                ForEach(vm.redemptions) { r in
                    HrListRow(icon: "checkmark.seal.fill", titulo: "\(r.partnerName) • \(r.discountText) • \(HrFormat.dayMonthYear(r.usedAt))", subtitulo: nil) {
                        HrTag(text: "Usado", color: .hrSuccess)
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .task { await vm.load() }
    }
}

/// QR Code preto sobre quadrado branco raio 12, gerado com CIQRCodeGenerator.
struct HrQRCodeView: View {
    let content: String
    var size: CGFloat = 220

    var body: some View {
        Group {
            if let image = Self.generate(content, scale: 12) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: size * 0.6))
                    .foregroundColor(.black)
            }
        }
        .padding(14)
        .frame(width: size, height: size)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
        .accessibilityLabel("QR Code do cartão do membro")
    }

    static func generate(_ text: String, scale: CGFloat) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: scale, y: scale)) else { return nil }
        let context = CIContext()
        guard let cg = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

#Preview {
    NavigationStack { CartaoDigitalView() }
        .environmentObject(AppState.shared)
}
