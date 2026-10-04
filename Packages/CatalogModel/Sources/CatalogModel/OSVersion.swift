import Foundation

/// A dotted operating-system version such as `17.0` or `26.1.2`.
///
/// Encoded as a compact string so generated JSON stays readable and diff-friendly.
public struct OSVersion: Hashable, Comparable, Sendable, Codable, CustomStringConvertible {
    public var major: Int
    public var minor: Int
    public var patch: Int

    public init(_ major: Int, _ minor: Int = 0, _ patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Parses `"17"`, `"17.4"` or `"17.4.1"`. Returns `nil` for anything else.
    public init?(string: String) {
        let parts = string.trimmingCharacters(in: .whitespaces).split(separator: ".")
        guard (1...3).contains(parts.count) else { return nil }
        var numbers: [Int] = []
        for part in parts {
            guard let value = Int(part), value >= 0 else { return nil }
            numbers.append(value)
        }
        while numbers.count < 3 { numbers.append(0) }
        self.init(numbers[0], numbers[1], numbers[2])
    }

    public init?(_ string: String) {
        self.init(string: string)
    }

    public var description: String {
        patch == 0 ? "\(major).\(minor)" : "\(major).\(minor).\(patch)"
    }

    /// Versions such as `100000` are used by Apple to mark *future* deprecations.
    public var isFuturePlaceholder: Bool { major >= 1000 }

    public static func < (lhs: OSVersion, rhs: OSVersion) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let version = OSVersion(string: raw) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid OS version \(raw)")
        }
        self = version
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
