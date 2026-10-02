//
//  VenturesRepository.swift
//  Mundo Planalto
//
//  Empreendimentos do cliente (GET ventures, com redes sociais) e atualizações da obra
//  (GET ventureupdates/venture/{id}). Remote usa os serviços que o app já tinha.
//

import Foundation

protocol VenturesRepository {
    func ventures(forceRefresh: Bool) async throws -> [Venture]
    func updates(venture: Venture) async throws -> [VentureUpdate]
}

// MARK: - Mock (docs/telas.md: Hard Rock Hotel Gramado)

final class VenturesRepositoryMock: VenturesRepository {
    static let shared = VenturesRepositoryMock()

    /// Empreendimento do usuário de demonstração. Links de exemplo (docs/PENDENCIAS.md).
    static let demoVenture = Venture(
        id: "1",
        name: "Hard Rock Hotel Gramado",
        imageUrl: FinanceiroRepositoryMock.imagemGramado,
        progress: 0,
        lastUpdate: "",
        photoBook: [
            PhotoBookItem(id: 1, photoUrl: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800", mediaType: "image", youtubeUrl: nil, createdAt: nil),
            PhotoBookItem(id: 2, photoUrl: "https://images.unsplash.com/photo-1483921020237-2ff51e8e4b22?w=800", mediaType: "image", youtubeUrl: nil, createdAt: nil),
            PhotoBookItem(id: 3, photoUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800", mediaType: "image", youtubeUrl: nil, createdAt: nil),
            PhotoBookItem(id: 4, photoUrl: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800", mediaType: "image", youtubeUrl: nil, createdAt: nil)
        ],
        unit: "Unidade 1208 • Torre A",
        city: "Gramado",
        state: "RS",
        instagramUrl: "https://www.instagram.com/hardrockhotelgramado",
        instagramHandle: "@hardrockhotelgramado",
        youtubeUrl: "https://www.youtube.com/@mundoplanalto",
        whatsappChannelUrl: "https://whatsapp.com/channel/"
    )

    func ventures(forceRefresh: Bool) async throws -> [Venture] { [Self.demoVenture] }

    func updates(venture: Venture) async throws -> [VentureUpdate] {
        // Vídeo de demonstração: URL provisória até a diretoria indicar o vídeo oficial (docs/PENDENCIAS.md).
        [
            VentureUpdate(
                id: "demo-1",
                date: "Setembro de 2026",
                title: "Diário de Obras | Hard Rock Hotel Gramado — Setembro/2026",
                description: "Acompanhe o andamento das obras do Hard Rock Hotel Gramado no vídeo desta atualização.",
                images: [],
                imageUrl: nil,
                videoUrl: nil,
                youtubeUrl: "https://www.youtube.com/watch?v=jNQXAC9IVRw",
                isCompleted: false
            )
        ]
    }
}

// MARK: - Remote (API existente do portal)

final class VenturesRepositoryRemote: VenturesRepository {
    func ventures(forceRefresh: Bool) async throws -> [Venture] {
        try await EmpreendimentosService.shared.getEmpreendimentos(useCache: !forceRefresh, forceRefresh: forceRefresh).empreendimentos
    }

    func updates(venture: Venture) async throws -> [VentureUpdate] {
        let dtos = try await EmpreendimentosService.shared.getVentureUpdates(ventureId: Int(venture.id) ?? 0)
        func media(_ s: String?) -> String? {
            guard let s else { return nil }
            let full = EmpreendimentosService.mediaURL(for: s)
            return full.isEmpty ? nil : full
        }
        return dtos.map { dto in
            let img = media(dto.imageUrl)
            return VentureUpdate(
                id: "\(dto.id)",
                date: HrFormat.dayMonthYear(dto.postDate),
                title: dto.title,
                description: dto.content,
                images: img.map { [$0] } ?? [],
                imageUrl: img,
                videoUrl: media(dto.videoUrl),
                youtubeUrl: media(dto.youtubeUrl),
                isCompleted: false
            )
        }
    }
}
