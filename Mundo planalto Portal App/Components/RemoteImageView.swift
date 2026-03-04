//
//  RemoteImageView.swift
//  Mundo planalto Portal App
//
//  Carrega imagem por URL; opcionalmente envia Bearer token (para APIs que exigem auth).
//

import SwiftUI

struct RemoteImageView: View {
    let urlString: String
    var useAuth: Bool = true

    @State private var image: UIImage?
    @State private var failed = false

    private var token: String? {
        useAuth ? PreferencesManager.shared.getAuthToken() : nil
    }

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if failed {
                placeholderView
            } else {
                placeholderView
                    .overlay(ProgressView())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .task(id: urlString) {
            await loadImage()
        }
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Image(systemName: "building.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.5))
            )
    }

    private func loadImage() async {
        guard let url = URL(string: urlString), urlString.hasPrefix("http") else {
            failed = true
            return
        }
        var request = URLRequest(url: url)
        if let t = token, !t.isEmpty {
            request.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200, let uiImage = UIImage(data: data) else {
                await MainActor.run { failed = true }
                return
            }
            await MainActor.run {
                image = uiImage
                failed = false
            }
        } catch {
            await MainActor.run { failed = true }
        }
    }
}
