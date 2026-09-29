//
//  ShimmerSkeletonCard.swift
//  Mundo planalto Portal App
//
//  Skeleton com animação (shimmer) para telas em loading.
//

import SwiftUI

struct ShimmerSkeletonCard: View {
    let height: CGFloat
    let isDark: Bool
    @State private var phase: CGFloat = 0

    private var baseColor: Color {
        AppColors.cardBackground(dark: isDark).opacity(0.6)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(baseColor)
            .overlay(
                GeometryReader { geo in
                    let width = max(geo.size.width * 0.45, 120)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    (isDark ? Color.white : Color.gray).opacity(0.18),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width)
                        .offset(x: -width + (geo.size.width + width) * phase)
                }
            )
            .frame(height: height)
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

