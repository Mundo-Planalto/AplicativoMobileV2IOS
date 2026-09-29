//
//  HTMLTextView.swift
//  Mundo planalto Portal App
//
//  Renderiza conteúdo HTML em SwiftUI sem usar o parser HTML do UIKit
//  (evita SIGABRT por exceções não capturáveis em Swift).
//

import SwiftUI
import UIKit

// MARK: - Parser seguro (sem NSAttributedString HTML)

enum SafeHTMLParser {
    static func plainText(from html: String) -> String {
        var text = html.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return "" }

        text = text.replacingOccurrences(of: "(?i)<br\\s*/?>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "(?i)</p>", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "(?i)</div>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "(?i)</li>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        text = decodeHTMLEntities(text)
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func attributedString(
        from html: String,
        font: UIFont,
        textColor: UIColor,
        linkColor: UIColor
    ) -> NSAttributedString {
        let plain = plainText(from: html)
        guard !plain.isEmpty else {
            return NSAttributedString(string: "")
        }

        let attributed = NSMutableAttributedString(
            string: plain,
            attributes: [
                .font: font,
                .foregroundColor: textColor
            ]
        )

        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return attributed
        }

        let fullRange = NSRange(location: 0, length: (plain as NSString).length)
        detector.enumerateMatches(in: plain, options: [], range: fullRange) { match, _, _ in
            guard let match, match.range.location != NSNotFound,
                  match.range.location + match.range.length <= fullRange.length,
                  let url = match.url else { return }
            attributed.addAttribute(.link, value: url, range: match.range)
            attributed.addAttribute(.foregroundColor, value: linkColor, range: match.range)
            attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
        }

        return attributed
    }

    private static func decodeHTMLEntities(_ text: String) -> String {
        var result = text
        let entities: [(String, String)] = [
            ("&nbsp;", " "),
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&#39;", "'"),
            ("&apos;", "'")
        ]
        for (entity, char) in entities {
            result = result.replacingOccurrences(of: entity, with: char)
        }
        return result
    }
}

// MARK: - UIViewRepresentable

struct HTMLTextView: UIViewRepresentable {
    let html: String
    var textColor: UIColor = .label
    var linkColor: UIColor = .systemBlue
    var font: UIFont = .systemFont(ofSize: 16)
    var isScrollable: Bool = false

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isSelectable = true
        tv.isScrollEnabled = isScrollable
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainer.widthTracksTextView = true
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tv.dataDetectorTypes = []
        tv.adjustsFontForContentSizeCategory = true
        tv.linkTextAttributes = [
            .foregroundColor: linkColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let key = "\(html)|\(font.pointSize)|\(isScrollable)"
        guard context.coordinator.lastRenderKey != key else { return }
        context.coordinator.lastRenderKey = key

        uiView.linkTextAttributes = [
            .foregroundColor: linkColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        uiView.attributedText = SafeHTMLParser.attributedString(
            from: html,
            font: font,
            textColor: textColor,
            linkColor: linkColor
        )
        uiView.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0, width != .infinity else { return nil }
        let fitting = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: max(fitting.height, 1))
    }

    final class Coordinator {
        var lastRenderKey: String?
    }
}

extension String {
    /// Remove tags HTML e retorna texto simples (sem parser HTML do UIKit).
    func plainTextFromHTML() -> String {
        SafeHTMLParser.plainText(from: self)
    }
}
