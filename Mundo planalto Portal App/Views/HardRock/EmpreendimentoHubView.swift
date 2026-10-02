//
//  EmpreendimentoHubView.swift
//  Mundo Planalto
//
//  Página do empreendimento (hub): capa, atalhos (Financeiro, Galeria, Vídeos, Documentos),
//  redes sociais e última atualização. Sem percentual de evolução da obra.
//  Também: Galeria (grade 2 colunas com tela cheia) e Documentos.
//

import SwiftUI
import Combine

struct EmpreendimentoHubView: View {
    let venture: Venture
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm: DetalhesObraViewModel

    init(venture: Venture) {
        self.venture = venture
        self._vm = StateObject(wrappedValue: DetalhesObraViewModel(venture: venture))
    }

    private var temRedes: Bool {
        [venture.instagramUrl, venture.youtubeUrl, venture.whatsappChannelUrl].contains { HrLinks.url(from: $0) != nil }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: venture.name, subtitulo: venture.localTexto.isEmpty ? nil : venture.localTexto)

                ZStack(alignment: .bottomLeading) {
                    VenturePhoto(venture: venture, height: 200)
                    if let unit = venture.unit, !unit.isEmpty {
                        Text(unit)
                            .font(HrFont.itemTitle)
                            .foregroundColor(.white)
                            .padding(HrMetrics.cardPadding)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))

                LazyVGrid(columns: [GridItem(.flexible(), spacing: HrMetrics.cardSpacing), GridItem(.flexible(), spacing: HrMetrics.cardSpacing)], spacing: HrMetrics.cardSpacing) {
                    HrShortcut(icon: "creditcard.fill", titulo: "Financeiro", subtitulo: "Parcelas, boletos e extrato") { router.push(.financeiroEmpreendimento(venture)) }
                    HrShortcut(icon: "photo.on.rectangle", titulo: "Galeria de fotos", subtitulo: "Imagens do projeto") { router.push(.galeria(vm.venture)) }
                    HrShortcut(icon: "play.rectangle.fill", titulo: "Vídeos da obra", subtitulo: "Acompanhamento no YouTube") { router.push(.videosObra(vm.venture)) }
                    HrShortcut(icon: "doc.text.fill", titulo: "Documentos", subtitulo: "Contrato, informe e boletos") { router.push(.documentos(venture)) }
                }

                if temRedes {
                    HrSectionTitle(titulo: "Acompanhe o empreendimento").padding(.top, 8)
                    if let url = HrLinks.url(from: venture.instagramUrl) {
                        HrListRow(icon: "camera.fill", titulo: "Instagram", subtitulo: venture.instagramHandle ?? "Fotos e novidades") { router.open(url) }
                    }
                    if let url = HrLinks.url(from: venture.youtubeUrl) {
                        HrListRow(icon: "play.rectangle.fill", titulo: "Canal no YouTube", subtitulo: "Vídeos e atualizações da obra") { router.open(url) }
                    }
                    if let url = HrLinks.url(from: venture.whatsappChannelUrl) {
                        HrListRow(icon: "message.fill", titulo: "Canal do WhatsApp", subtitulo: "Novidades direto no seu celular") { router.open(url) }
                    }
                }

                if let ultima = vm.updates.first {
                    HrSectionTitle(titulo: "Última atualização").padding(.top, 8)
                    HrCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(ultima.title)
                                .font(HrFont.sectionTitle)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(ultima.date)
                                .font(HrFont.caption)
                                .foregroundColor(.hrGoldLight)
                            let resumo = ultima.description.plainTextFromHTML().trimmingCharacters(in: .whitespacesAndNewlines)
                            if !resumo.isEmpty {
                                Text(resumo)
                                    .font(HrFont.body)
                                    .foregroundColor(.hrTextMuted)
                                    .lineLimit(3)
                            }
                            HrGoldButton(text: "Assistir no YouTube") { router.push(.videosObra(vm.venture)) }
                                .padding(.top, 2)
                        }
                    }
                } else if let video = vm.videosDoBook.first {
                    // Sem atualização cadastrada: destaca o vídeo do book do empreendimento no portal.
                    HrSectionTitle(titulo: "Vídeo do empreendimento").padding(.top, 8)
                    TimelineMarcoItem(update: video, tag: "Vídeo")
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .task { await vm.loadVentureDetails() }
    }
}

// MARK: - Galeria

struct GaleriaView: View {
    let venture: Venture
    @State private var aberta: PhotoBookItem?

    private var fotos: [PhotoBookItem] {
        (venture.photoBook ?? []).filter { $0.mediaType.lowercased() == "image" && !$0.photoUrl.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Galeria de fotos", subtitulo: venture.name)

                if fotos.isEmpty {
                    HrCard {
                        HStack(spacing: 12) {
                            HrIconBox(icon: "photo")
                            Text("Nenhuma foto disponível no momento.")
                                .font(HrFont.caption).foregroundColor(.hrTextMuted)
                        }
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(fotos) { foto in
                            Button { aberta = foto } label: {
                                GaleriaFoto(url: foto.photoUrl)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
                            }
                            .buttonStyle(HrPressStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .fullScreenCover(item: $aberta) { foto in
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                TabView(selection: Binding(get: { foto.id }, set: { id in aberta = fotos.first { $0.id == id } })) {
                    ForEach(fotos) { f in
                        GaleriaFoto(url: f.photoUrl, fill: false).tag(f.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                Button { aberta = nil } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                        .overlay(Circle().stroke(Color.hrGoldBorder, lineWidth: 1))
                }
                .padding(16)
                .accessibilityLabel("Fechar")
            }
        }
    }
}

/// Foto da galeria: mídia do portal com Bearer, demais por AsyncImage.
private struct GaleriaFoto: View {
    let url: String
    var fill = true

    var body: some View {
        ZStack {
            if fill { HrGradient.photoPlaceholder }
            if url.contains("mundoplanalto") {
                Color.clear.overlay(RemoteImageView(urlString: url, useAuth: true)).clipped()
            } else if fill {
                HrPhoto(url: url)
            } else {
                AsyncImage(url: URL(string: url)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        ProgressView().tint(.hrGoldLight)
                    }
                }
            }
        }
    }
}

// MARK: - Documentos

struct DocumentosView: View {
    let venture: Venture
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Documentos", subtitulo: venture.name)
                HrListRow(icon: "doc.richtext.fill", titulo: "Informe de rendimentos", subtitulo: "Acesse seu informe anual") { router.push(.informeRendimentos) }
                HrListRow(icon: "doc.text.fill", titulo: "Segunda via de boleto", subtitulo: "Emita a segunda via da sua parcela") { router.push(.extrato) }
                HrListRow(icon: "list.bullet.rectangle.fill", titulo: "Extrato", subtitulo: "Acompanhe seu histórico de pagamentos") { router.push(.extrato) }
                HrCard {
                    HStack(alignment: .top, spacing: 12) {
                        HrIconBox(icon: "info.circle")
                        Text("O contrato ficará disponível aqui em breve.")
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
        .hrScreen()
    }
}

#Preview {
    NavigationStack { EmpreendimentoHubView(venture: VenturesRepositoryMock.demoVenture) }
        .environmentObject(AppRouter())
}
