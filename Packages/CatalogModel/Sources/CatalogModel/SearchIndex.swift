import Foundation

/// Why a symbol matched a query. Ordered by ranking priority.
public enum SearchMatchReason: Int, Sendable, Comparable {
    case exactSymbol = 0
    case exactAlias
    case symbolPrefix
    case componentTitle
    case symbolSubstring
    case relatedMember
    case familyOrTag
    case signatureText

    public static func < (lhs: SearchMatchReason, rhs: SearchMatchReason) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct SearchResult: Sendable, Hashable, Identifiable {
    public var symbolID: String
    public var score: Int
    public var reason: SearchMatchReason
    /// The member that produced the match, when the match came from a member.
    public var matchedMember: String?

    public var id: String { symbolID }
}

public struct SearchOptions: Sendable, Hashable {
    public var frameworks: Set<Framework>
    public var includeInternal: Bool
    public var limit: Int

    public init(frameworks: Set<Framework> = Set(Framework.allCases), includeInternal: Bool = false, limit: Int = 300) {
        self.frameworks = frameworks
        self.includeInternal = includeInternal
        self.limit = limit
    }
}

/// An in-memory, precomputed search index over catalog symbols.
///
/// Building is O(n) and intended to run off the main actor once after loading. Each query is a
/// linear scan over precomputed lowercase strings, which stays well under a frame budget for
/// tens of thousands of entries.
public final class SearchIndex: Sendable {
    struct Entry: Sendable {
        let symbolID: String
        let framework: Framework
        let isInternal: Bool
        let isDeprecated: Bool
        let isVisual: Bool
        let hasDemo: Bool
        let priority: Int
        let name: String
        let qualified: String
        let aliases: [String]
        let terms: [String]
        let members: [(lower: String, display: String)]
        let signatureText: String
    }

    private let entries: [Entry]

    public var count: Int { entries.count }

    /// - Parameters:
    ///   - symbols: Catalog symbols to index.
    ///   - familyTitles: Localized titles for each family ID (all supported languages), so
    ///     searching "Presentation" or its Hebrew equivalent finds family members.
    public init(symbols: [CatalogSymbol], familyTitles: [String: [String]] = [:]) {
        entries = symbols.map { symbol in
            var terms = symbol.tags.map { $0.lowercased() }
            terms.append(symbol.framework.rawValue.lowercased())
            if let family = symbol.family {
                terms.append(family.lowercased())
                terms.append(contentsOf: (familyTitles[family] ?? []).map { $0.lowercased() })
            }
            var members = symbol.members.map { ($0.baseName.lowercased(), $0.name) }
            members.append(contentsOf: symbol.enumCases.map { ($0.lowercased(), $0) })
            members.append(contentsOf: symbol.optionSetCases.map { ($0.lowercased(), $0) })
            let signatureText = symbol.signatures
                .map { $0.declaration }
                .joined(separator: " ")
                .lowercased()
            return Entry(
                symbolID: symbol.id,
                framework: symbol.framework,
                isInternal: symbol.isInternal,
                isDeprecated: symbol.availability.isDeprecated || symbol.availability.isUnavailable,
                isVisual: symbol.category.isVisual,
                hasDemo: symbol.demoID != nil,
                priority: symbol.priority,
                name: symbol.name.lowercased(),
                qualified: symbol.qualifiedName.lowercased(),
                aliases: symbol.aliases.map { $0.lowercased() },
                terms: terms,
                members: members,
                signatureText: signatureText
            )
        }
    }

    /// Normalizes user input: lowercases, trims, drops a leading `.` and trailing `()`.
    public static func normalize(_ query: String) -> String {
        var value = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if value.hasPrefix(".") { value.removeFirst() }
        if value.hasSuffix("()") { value.removeLast(2) }
        if value.hasPrefix("@") { value.removeFirst() }
        return value
    }

    public func search(_ rawQuery: String, options: SearchOptions = .init()) -> [SearchResult] {
        let query = Self.normalize(rawQuery)
        guard !query.isEmpty else { return [] }
        let tokens = query.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        var results: [SearchResult] = []
        results.reserveCapacity(256)
        for entry in entries {
            guard options.frameworks.contains(entry.framework) else { continue }
            if entry.isInternal && !options.includeInternal { continue }
            if let result = score(entry, query: query, tokens: tokens) {
                results.append(result)
            }
        }
        results.sort { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            return lhs.symbolID < rhs.symbolID
        }
        if results.count > options.limit { results.removeSubrange(options.limit...) }
        return results
    }

    private func score(_ entry: Entry, query: String, tokens: [String]) -> SearchResult? {
        if let single = scoreSingle(entry, query: query) { return single }
        guard tokens.count > 1 else { return nil }
        var total = 0
        var best: (SearchMatchReason, String?)?
        for token in tokens {
            guard let match = scoreSingle(entry, query: token) else { return nil }
            total += match.score
            if best == nil || match.reason < best!.0 { best = (match.reason, match.matchedMember) }
        }
        return SearchResult(
            symbolID: entry.symbolID,
            score: total / tokens.count - 50,
            reason: best?.0 ?? .signatureText,
            matchedMember: best?.1
        )
    }

    private func scoreSingle(_ entry: Entry, query: String) -> SearchResult? {
        var reason: SearchMatchReason?
        var base = 0
        var member: String?

        if entry.name == query || entry.qualified == query {
            reason = .exactSymbol; base = 10_000
        } else if entry.aliases.contains(query) {
            reason = .exactAlias; base = 9_000
        } else if entry.name.hasPrefix(query) {
            reason = .symbolPrefix; base = 8_000 - min(entry.name.count - query.count, 400)
        } else if entry.hasDemo && entry.name.contains(query) {
            reason = .componentTitle; base = 7_000 - min(entry.name.count - query.count, 400)
        } else if entry.name.contains(query) || entry.qualified.contains(query) {
            reason = .symbolSubstring; base = 6_000 - min(entry.qualified.count - query.count, 400)
        } else if entry.aliases.contains(where: { $0.contains(query) }) {
            reason = .symbolSubstring; base = 5_500
        } else if let match = entry.members.first(where: { $0.lower == query })
            ?? entry.members.first(where: { $0.lower.hasPrefix(query) }) {
            reason = .relatedMember; base = match.lower == query ? 5_000 : 4_500
            member = match.display
        } else if entry.terms.contains(where: { $0 == query || $0.hasPrefix(query) }) {
            reason = .familyOrTag; base = 3_000
        } else if query.count >= 3, entry.signatureText.contains(query) {
            reason = .signatureText; base = 2_000
        } else if query.count >= 3, let match = entry.members.first(where: { $0.lower.contains(query) }) {
            reason = .relatedMember; base = 1_800
            member = match.display
        }

        guard let reason else { return nil }
        var score = base
        score += min(entry.priority, 99) * 5
        if entry.hasDemo { score += 300 }
        if entry.isVisual { score += 120 }
        if entry.isDeprecated { score -= 700 }
        if entry.isInternal { score -= 1_000 }
        return SearchResult(symbolID: entry.symbolID, score: score, reason: reason, matchedMember: member)
    }
}
