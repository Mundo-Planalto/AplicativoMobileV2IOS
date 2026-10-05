//
//  AppErrorMapper.swift
//  Mundo planalto Portal App
//

import Foundation

enum AppErrorMapper {
    private static let internetErrorCodes: Set<URLError.Code> = [
        .notConnectedToInternet,
        .networkConnectionLost,
        .timedOut,
        .cannotFindHost,
        .cannotConnectToHost,
        .dnsLookupFailed,
        .internationalRoamingOff,
        .callIsActive,
        .dataNotAllowed
    ]

    static func isInternetError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            return internetErrorCodes.contains(urlError.code)
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            let code = URLError.Code(rawValue: nsError.code)
            return internetErrorCodes.contains(code)
        }

        switch error {
        case AuthError.networkError,
             NewsError.networkError,
             EmpreendimentosError.networkError,
             ExtratoError.networkError,
             IncomeTaxError.networkError,
             ProfileError.networkError,
             SupportError.networkError:
            return true
        default:
            return false
        }
    }

    static func userMessage(for error: Error, fallback: String) -> String {
        if isInternetError(error) {
            return "Sem conexão com a internet. Verifique sua rede e tente novamente."
        }
        return fallback
    }
}
