//
//  HrDialogs.swift
//  Mundo Planalto
//
//  Folhas (sheets) no visual preto e dourado: cupom do parceiro.
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
