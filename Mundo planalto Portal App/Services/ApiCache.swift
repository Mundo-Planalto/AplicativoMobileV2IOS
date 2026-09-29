//
//  ApiCache.swift
//  Mundo planalto Portal App
//
//  Cache simples para respostas da API (memória + disco) com TTL.
//

import Foundation

final class ApiCache {
    static let shared = ApiCache()

    private struct CacheFile: Codable {
        let expiresAt: Date
        let payloadBase64: String
    }

    private final class MemoryBox {
        let expiresAt: Date
        let payload: Data
        init(expiresAt: Date, payload: Data) {
            self.expiresAt = expiresAt
            self.payload = payload
        }
    }

    private let memory = NSCache<NSString, MemoryBox>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        self.cacheDirectory = cachesURL?.appendingPathComponent("ApiResponseCache", isDirectory: true)
            ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ApiResponseCache", isDirectory: true)

        // Melhor esforço: se falhar, continua só com memória.
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func get<T: Codable>(_ type: T.Type, key: String) -> T? {
        let now = Date()
        let nsKey = key as NSString

        if let box = memory.object(forKey: nsKey) {
            guard box.expiresAt > now else {
                memory.removeObject(forKey: nsKey)
                return nil
            }
            return decodePayload(box.payload, as: type)
        }

        let fileURL = fileURLForKey(key)
        guard fileManager.fileExists(atPath: fileURL.path),
              let rawData = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(CacheFile.self, from: rawData)
        else {
            return nil
        }

        guard decoded.expiresAt > now else {
            try? fileManager.removeItem(at: fileURL)
            return nil
        }

        guard let payload = Data(base64Encoded: decoded.payloadBase64) else { return nil }
        memory.setObject(MemoryBox(expiresAt: decoded.expiresAt, payload: payload), forKey: nsKey)
        return decodePayload(payload, as: type)
    }

    func set<T: Codable>(_ value: T, key: String, ttl: TimeInterval) {
        let expiresAt = Date().addingTimeInterval(ttl)
        let encoder = JSONEncoder()
        guard let payload = try? encoder.encode(value) else { return }

        let nsKey = key as NSString
        memory.setObject(MemoryBox(expiresAt: expiresAt, payload: payload), forKey: nsKey)

        let fileURL = fileURLForKey(key)
        let payloadBase64 = payload.base64EncodedString()
        let cacheFile = CacheFile(expiresAt: expiresAt, payloadBase64: payloadBase64)
        guard let raw = try? JSONEncoder().encode(cacheFile) else { return }

        // Melhor esforço: não falha por IO.
        try? raw.write(to: fileURL, options: [.atomic])
    }

    private func decodePayload<T: Codable>(_ payload: Data, as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: payload)
    }

    private func fileURLForKey(_ key: String) -> URL {
        let safeName = key
            .data(using: .utf8)?
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
        let fileName = safeName ?? UUID().uuidString
        return cacheDirectory.appendingPathComponent(fileName).appendingPathExtension("json")
    }
}

