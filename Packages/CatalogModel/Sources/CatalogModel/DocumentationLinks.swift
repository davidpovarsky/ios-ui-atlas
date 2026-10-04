import Foundation

/// Builds Apple Developer Documentation and Human Interface Guidelines URLs.
///
/// Apple's documentation paths are lowercase versions of the symbol path. Methods use
/// `name(label:label:)` with `_` for unlabeled parameters. When a nested type collides with a
/// member of the same lowercase name, Apple appends a disambiguation suffix such as
/// `-swift.struct`. Irregular cases are handled by the generator's override table.
public enum DocumentationLinks {
    public static let documentationBase = "https://developer.apple.com/documentation/"
    public static let higBase = "https://developer.apple.com/design/human-interface-guidelines/"

    public static func documentationURL(path: String) -> URL? {
        URL(string: documentationBase + path)
    }

    public static func higURL(path: String) -> URL? {
        URL(string: higBase + path)
    }

    /// Path component for a type or property name.
    public static func component(_ name: String) -> String {
        name.lowercased()
    }

    /// Path component for a function-like symbol, e.g. `sheet(ispresented:ondismiss:content:)`.
    public static func functionComponent(name: String, labels: [String?]) -> String {
        let selector = labels.map { "\($0 ?? "_"):" }.joined()
        return "\(name)(\(selector))".lowercased()
    }

    /// Path component for a member title that is already in Apple form (`addSubview(_:)`).
    public static func memberComponent(title: String) -> String {
        title.lowercased()
    }

    /// Swift kind suffix used by Apple to disambiguate colliding names.
    public static func disambiguationSuffix(for kind: SymbolKind) -> String {
        switch kind {
        case .structure, .view: "-swift.struct"
        case .classType: "-swift.class"
        case .enumeration: "-swift.enum"
        case .protocolType: "-swift.protocol"
        case .typeAlias: "-swift.typealias"
        case .actor: "-swift.actor"
        case .function, .modifier: "-swift.method"
        case .variable: "-swift.property"
        case .macro: "-swift.macro"
        case .extensionType: ""
        }
    }

    /// Generic path builder for a symbol given its framework and qualified name components.
    ///
    /// - Parameters:
    ///   - framework: Owning framework.
    ///   - components: Qualified name components (`["UIButton", "Configuration"]`).
    ///   - collisions: Indexes of components that collide with a same-named member in their
    ///     parent and therefore need a disambiguation suffix.
    ///   - kind: Kind of the final component, used for the suffix.
    public static func typePath(
        framework: Framework,
        components: [String],
        collidingLast: Bool = false,
        kind: SymbolKind = .structure
    ) -> String {
        var parts = [framework.rawValue.lowercased()]
        for (index, component) in components.enumerated() {
            var part = self.component(component)
            if collidingLast, index == components.count - 1 {
                part += disambiguationSuffix(for: kind)
            }
            parts.append(part)
        }
        return parts.joined(separator: "/")
    }

    /// Path for a SwiftUI view modifier (a method on `View`).
    public static func modifierPath(name: String, labels: [String?]) -> String {
        "swiftui/view/" + functionComponent(name: name, labels: labels)
    }

    /// Path for a member of a documented symbol.
    public static func memberPath(parentPath: String, member: CatalogMember) -> String {
        parentPath + "/" + memberComponent(title: member.name)
    }
}
