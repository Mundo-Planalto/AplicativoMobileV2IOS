//
//  HrDialogs.swift
//  Hard Rock Hotel & Vacation Club
//
//  Folhas (sheets) no visual preto e dourado: cupom do parceiro e histórico de milhas.
//

import SwiftUI

/// Cupom: código em dourado e "Apresente este código no parceiro".
struct HrCouponSheet: View {
    let coupon: Coupon
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(Color.hrGoldBorder).frame(width: 40, height: 4).padding(.top, 8)
            HrTag(text: "Cupom")
            Text(coupon.partnerName)
                .font(HrFont.sectionTitle)
                .foregroundColor(.white)
            Text(coupon.discountText)
                .font(HrFont.body)
                .foregroundColor(.hrTextMuted)
            Text(coupon.code)
                .font(.system(size: 28, weight: .black, design: .monospaced))
                .tracking(2)
                .foregroundColor(.hrGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                        .fill(Color.hrSurfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                        .stroke(Color.hrGold, lineWidth: 1)
                )
                .textSelection(.enabled)
            Text(coupon.instructions)
                .font(HrFont.caption)
                .foregroundColor(.hrTextMuted)
            HrGoldButton(text: "Fechar", trailingArrow: false) { dismiss() }
                .padding(.top, 4)
        }
        .padding(HrMetrics.screenMargin)
        .frame(maxWidth: .infinity)
        .background(Color.hrBlack.ignoresSafeArea())
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.hrBlack)
    }
}

/// Histórico de milhas: lista de lançamentos.
struct HrMilesHistorySheet: View {
    let account: MilesAccount
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(Color.hrGoldBorder).frame(width: 40, height: 4).padding(.top, 8)
            HrSectionTitle(titulo: "Histórico de milhas", subtitulo: "Saldo atual \(HrFormat.integer(account.balance)) milhas")
            VStack(spacing: 8) {
                ForEach(account.entries) { entry in
                    HStack(alignment: .top, spacing: 12) {
                        Text((entry.amount >= 0 ? "+" : "") + HrFormat.integer(entry.amount))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.hrGold)
                            .frame(width: 72, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.description)
                                .font(HrFont.itemTitle)
                                .foregroundColor(.white)
                            Text(HrFormat.dayMonthYear(entry.createdAt))
                                .font(HrFont.captionSmall)
                                .foregroundColor(.hrTextMuted)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.hrSurface))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
                }
            }
            HrOutlineButton(text: "Fechar") { dismiss() }
        }
        .padding(HrMetrics.screenMargin)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hrBlack.ignoresSafeArea())
        .presentationDetents([.height(420)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.hrBlack)
    }
}

/// Card com Toggle dourado "Receber novas promoções".
struct HrPromoToggleCard: View {
    @Binding var isOn: Bool

    var body: some View {
        HrCard {
            HStack(spacing: 12) {
                HrIconBox(icon: "bell.badge.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Receber novas promoções")
                        .font(HrFont.itemTitle)
                        .foregroundColor(.white)
                    Text("Seja o primeiro a saber sobre ofertas e benefícios")
                        .font(HrFont.captionSmall)
                        .foregroundColor(.hrTextMuted)
                }
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(.hrGold)
            }
        }
    }
}
