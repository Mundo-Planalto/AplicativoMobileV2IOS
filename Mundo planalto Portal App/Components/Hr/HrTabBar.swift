//
//  HrTabBar.swift
//  Hard Rock Hotel & Vacation Club
//
//  Tab bar: fundo hrBlack, cantos superiores 24, item selecionado com ícone dourado
//  sobre pastilha 40x40 raio 12 em hrGold 18%; não selecionado hrTextMuted; rótulos 9pt.
//

import SwiftUI

struct HrTabBar: View {
    @Binding var selected: TabItem
    var badges: [TabItem: Int] = [:]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                Button {
                    if selected != tab {
                        selected = tab
                    }
                } label: {
                    tabItem(tab)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(tab.rawValue)
                .accessibilityAddTraits(selected == tab ? [.isSelected] : [])
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous)
                .fill(Color.hrBlack)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous)
                        .stroke(Color.hrGoldBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(_ tab: TabItem) -> some View {
        let isSelected = selected == tab
        return VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .hrGold : .hrTextMuted)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? Color.hrGold.opacity(0.18) : Color.clear)
                    )
                if let count = badges[tab], count > 0 {
                    Text(count > 99 ? "99+" : "\(count)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.hrGold))
                        .offset(x: 6, y: -4)
                }
            }
            Text(tab.rawValue)
                .font(.system(size: 9, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .hrGold : .hrTextMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    VStack {
        Spacer()
        HrTabBar(selected: .constant(.inicio), badges: [.perfil: 2])
    }
    .hrScreen()
}
