import Foundation

// MARK: - Enumerations

/// The UI frameworks covered by the atlas.
public enum Framework: String, Codable, CaseIterable, Sendable, Identifiable, Comparable {
    case swiftUI = "SwiftUI"
    case uiKit = "UIKit"

    public var id: String { rawValue }

    public static func < (lhs: Framework, rhs: Framework) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    private var sortOrder: Int { self == .swiftUI ? 0 : 1 }
}

/// Declaration kind as presented by the catalog.
public enum SymbolKind: String, Codable, CaseIterable, Sendable {
    case view
    case modifier
    case structure = "struct"
    case classType = "class"
    case enumeration = "enum"
    case actor
    case protocolType = "protocol"
    case typeAlias = "typealias"
    case function
    case variable
    case macro
    case extensionType = "extension"

    public var isType: Bool {
        switch self {
        case .view, .structure, .classType, .enumeration, .actor, .protocolType, .typeAlias, .extensionType: true
        case .modifier, .function, .variable, .macro: false
        }
    }
}

/// Catalog-oriented classification. Exactly one primary category per symbol.
public enum CatalogCategory: String, Codable, CaseIterable, Sendable {
    case visualComponent = "visual-component"
    case visualModifier = "visual-modifier"
    case structuralContainer = "structural-container"
    case presentation
    case navigation
    case input
    case interaction
    case accessibility
    case styling
    case referenceOnly = "reference-only"
    case nonvisual
    case lifecycle
    case unavailable
    case deprecated
    case `internal`

    /// Categories that represent visual / interactive surface.
    public var isVisual: Bool {
        switch self {
        case .visualComponent, .visualModifier, .structuralContainer, .presentation, .navigation,
             .input, .interaction, .accessibility, .styling: true
        case .referenceOnly, .nonvisual, .lifecycle, .unavailable, .deprecated, .internal: false
        }
    }
}

public enum SymbolVisibility: String, Codable, Sendable {
    case `public`
    case underscored
    case spi
}

public enum LanguageOrigin: String, Codable, Sendable {
    case swift
    case objectiveC = "objc"
}

public enum MemberKind: String, Codable, CaseIterable, Sendable {
    case initializer
    case method
    case property
    case typeMethod
    case typeProperty
    case `subscript`
    case enumCase = "case"
    case associatedType
    case typeAlias
    case `operator`
}

public enum RelationKind: String, Codable, Sendable {
    /// Conceptual counterpart in the other framework. Never claimed to be identical.
    case relatedSwiftUI
    case relatedUIKit
    /// Same-framework "see also".
    case seeAlso
}

// MARK: - Availability

public struct CatalogAvailability: Hashable, Sendable, Codable {
    public var introduced: OSVersion?
    public var deprecated: OSVersion?
    public var obsoleted: OSVersion?
    public var isDeprecated: Bool
    public var isUnavailable: Bool
    public var message: String?
    public var renamed: String?

    public init(
        introduced: OSVersion? = nil,
        deprecated: OSVersion? = nil,
        obsoleted: OSVersion? = nil,
        isDeprecated: Bool = false,
        isUnavailable: Bool = false,
        message: String? = nil,
        renamed: String? = nil
    ) {
        self.introduced = introduced
        self.deprecated = deprecated
        self.obsoleted = obsoleted
        self.isDeprecated = isDeprecated
        self.isUnavailable = isUnavailable
        self.message = message
        self.renamed = renamed
    }

    public var isEmpty: Bool { self == CatalogAvailability() }

    private enum CodingKeys: String, CodingKey {
        case introduced, deprecated, obsoleted, isDeprecated, isUnavailable, message, renamed
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        introduced = try c.decodeIfPresent(OSVersion.self, forKey: .introduced)
        deprecated = try c.decodeIfPresent(OSVersion.self, forKey: .deprecated)
        obsoleted = try c.decodeIfPresent(OSVersion.self, forKey: .obsoleted)
        isDeprecated = try c.decodeIfPresent(Bool.self, forKey: .isDeprecated) ?? false
        isUnavailable = try c.decodeIfPresent(Bool.self, forKey: .isUnavailable) ?? false
        message = try c.decodeIfPresent(String.self, forKey: .message)
        renamed = try c.decodeIfPresent(String.self, forKey: .renamed)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(introduced, forKey: .introduced)
        try c.encodeIfPresent(deprecated, forKey: .deprecated)
        try c.encodeIfPresent(obsoleted, forKey: .obsoleted)
        if isDeprecated { try c.encode(true, forKey: .isDeprecated) }
        if isUnavailable { try c.encode(true, forKey: .isUnavailable) }
        try c.encodeIfPresent(message, forKey: .message)
        try c.encodeIfPresent(renamed, forKey: .renamed)
    }
}

// MARK: - Signatures and members

public struct CatalogParameter: Hashable, Sendable, Codable {
    /// External argument label; `nil` when the parameter is unlabeled (`_`).
    public var label: String?
    public var name: String
    public var type: String
    public var defaultValue: String?

    public init(label: String?, name: String, type: String, defaultValue: String? = nil) {
        self.label = label
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
}

public struct CatalogSignature: Hashable, Sendable, Codable {
    /// The full declaration as written in the SDK (attributes stripped).
    public var declaration: String
    public var parameters: [CatalogParameter]
    public var returnType: String?
    public var availability: CatalogAvailability
    public var isAsync: Bool
    public var isThrowing: Bool

    public init(
        declaration: String,
        parameters: [CatalogParameter] = [],
        returnType: String? = nil,
        availability: CatalogAvailability = .init(),
        isAsync: Bool = false,
        isThrowing: Bool = false
    ) {
        self.declaration = declaration
        self.parameters = parameters
        self.returnType = returnType
        self.availability = availability
        self.isAsync = isAsync
        self.isThrowing = isThrowing
    }

    private enum CodingKeys: String, CodingKey {
        case declaration, parameters, returnType, availability, isAsync, isThrowing
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        declaration = try c.decode(String.self, forKey: .declaration)
        parameters = try c.decodeIfPresent([CatalogParameter].self, forKey: .parameters) ?? []
        returnType = try c.decodeIfPresent(String.self, forKey: .returnType)
        availability = try c.decodeIfPresent(CatalogAvailability.self, forKey: .availability) ?? .init()
        isAsync = try c.decodeIfPresent(Bool.self, forKey: .isAsync) ?? false
        isThrowing = try c.decodeIfPresent(Bool.self, forKey: .isThrowing) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(declaration, forKey: .declaration)
        if !parameters.isEmpty { try c.encode(parameters, forKey: .parameters) }
        try c.encodeIfPresent(returnType, forKey: .returnType)
        if !availability.isEmpty { try c.encode(availability, forKey: .availability) }
        if isAsync { try c.encode(true, forKey: .isAsync) }
        if isThrowing { try c.encode(true, forKey: .isThrowing) }
    }

    /// Argument labels in Apple documentation style, e.g. `isPresented:onDismiss:content:`.
    public var labelSelector: String {
        parameters.map { "\($0.label ?? "_"):" }.joined()
    }
}

public struct CatalogMember: Hashable, Sendable, Codable, Identifiable {
    /// Display title, e.g. `addSubview(_:)`, `backgroundColor`, `init(frame:)`.
    public var name: String
    public var kind: MemberKind
    public var declaration: String
    public var availability: CatalogAvailability
    public var isRequirement: Bool
    public var objcName: String?

    public var id: String { "\(kind.rawValue):\(name):\(declaration)" }

    public init(
        name: String,
        kind: MemberKind,
        declaration: String,
        availability: CatalogAvailability = .init(),
        isRequirement: Bool = false,
        objcName: String? = nil
    ) {
        self.name = name
        self.kind = kind
        self.declaration = declaration
        self.availability = availability
        self.isRequirement = isRequirement
        self.objcName = objcName
    }

    private enum CodingKeys: String, CodingKey {
        case name, kind, declaration, availability, isRequirement, objcName
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        kind = try c.decode(MemberKind.self, forKey: .kind)
        declaration = try c.decode(String.self, forKey: .declaration)
        availability = try c.decodeIfPresent(CatalogAvailability.self, forKey: .availability) ?? .init()
        isRequirement = try c.decodeIfPresent(Bool.self, forKey: .isRequirement) ?? false
        objcName = try c.decodeIfPresent(String.self, forKey: .objcName)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(kind, forKey: .kind)
        try c.encode(declaration, forKey: .declaration)
        if !availability.isEmpty { try c.encode(availability, forKey: .availability) }
        if isRequirement { try c.encode(true, forKey: .isRequirement) }
        try c.encodeIfPresent(objcName, forKey: .objcName)
    }

    /// The bare name without the argument list (`addSubview` for `addSubview(_:)`).
    public var baseName: String {
        if let index = name.firstIndex(of: "(") { return String(name[..<index]) }
        return name
    }
}

public struct CatalogRelation: Hashable, Sendable, Codable {
    public var kind: RelationKind
    public var target: String
    /// Optional localization key explaining the relationship (e.g. "conceptually similar").
    public var noteKey: String?

    public init(kind: RelationKind, target: String, noteKey: String? = nil) {
        self.kind = kind
        self.target = target
        self.noteKey = noteKey
    }
}

// MARK: - Symbol

/// One browsable reference entry. Members (methods, properties…) live inside their parent.
public struct CatalogSymbol: Hashable, Sendable, Codable, Identifiable {
    /// Stable identifier: `<Framework>.<QualifiedName>`, e.g. `SwiftUI.Button`,
    /// `SwiftUI.View.sheet`, `UIKit.UIButton.Configuration`.
    public var id: String
    public var framework: Framework
    public var modules: [String]
    public var name: String
    public var qualifiedName: String
    public var kind: SymbolKind
    public var category: CatalogCategory
    public var family: String?
    public var tags: [String]
    public var aliases: [String]
    public var availability: CatalogAvailability
    public var visibility: SymbolVisibility
    public var origin: LanguageOrigin
    public var objcName: String?
    public var genericParameters: [String]
    public var superclass: String?
    public var conformances: [String]
    public var signatures: [CatalogSignature]
    public var members: [CatalogMember]
    public var enumCases: [String]
    public var optionSetCases: [String]
    /// Path below `https://developer.apple.com/documentation/`.
    public var documentationPath: String?
    /// Path below `https://developer.apple.com/design/human-interface-guidelines/`.
    public var higPath: String?
    public var related: [CatalogRelation]
    public var demoID: String?
    public var summaryKey: String?
    public var priority: Int
    public var parentID: String?

    public init(
        id: String,
        framework: Framework,
        modules: [String],
        name: String,
        qualifiedName: String,
        kind: SymbolKind,
        category: CatalogCategory,
        family: String? = nil,
        tags: [String] = [],
        aliases: [String] = [],
        availability: CatalogAvailability = .init(),
        visibility: SymbolVisibility = .public,
        origin: LanguageOrigin = .swift,
        objcName: String? = nil,
        genericParameters: [String] = [],
        superclass: String? = nil,
        conformances: [String] = [],
        signatures: [CatalogSignature] = [],
        members: [CatalogMember] = [],
        enumCases: [String] = [],
        optionSetCases: [String] = [],
        documentationPath: String? = nil,
        higPath: String? = nil,
        related: [CatalogRelation] = [],
        demoID: String? = nil,
        summaryKey: String? = nil,
        priority: Int = 0,
        parentID: String? = nil
    ) {
        self.id = id
        self.framework = framework
        self.modules = modules
        self.name = name
        self.qualifiedName = qualifiedName
        self.kind = kind
        self.category = category
        self.family = family
        self.tags = tags
        self.aliases = aliases
        self.availability = availability
        self.visibility = visibility
        self.origin = origin
        self.objcName = objcName
        self.genericParameters = genericParameters
        self.superclass = superclass
        self.conformances = conformances
        self.signatures = signatures
        self.members = members
        self.enumCases = enumCases
        self.optionSetCases = optionSetCases
        self.documentationPath = documentationPath
        self.higPath = higPath
        self.related = related
        self.demoID = demoID
        self.summaryKey = summaryKey
        self.priority = priority
        self.parentID = parentID
    }

    public var isInternal: Bool { visibility != .public }
    public var hasLiveDemo: Bool { demoID != nil }

    private enum CodingKeys: String, CodingKey {
        case id, framework, modules, name, qualifiedName, kind, category, family, tags, aliases
        case availability, visibility, origin, objcName, genericParameters, superclass, conformances
        case signatures, members, enumCases, optionSetCases, documentationPath, higPath, related
        case demoID, summaryKey, priority, parentID
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        framework = try c.decode(Framework.self, forKey: .framework)
        modules = try c.decodeIfPresent([String].self, forKey: .modules) ?? []
        name = try c.decode(String.self, forKey: .name)
        qualifiedName = try c.decode(String.self, forKey: .qualifiedName)
        kind = try c.decode(SymbolKind.self, forKey: .kind)
        category = try c.decode(CatalogCategory.self, forKey: .category)
        family = try c.decodeIfPresent(String.self, forKey: .family)
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        aliases = try c.decodeIfPresent([String].self, forKey: .aliases) ?? []
        availability = try c.decodeIfPresent(CatalogAvailability.self, forKey: .availability) ?? .init()
        visibility = try c.decodeIfPresent(SymbolVisibility.self, forKey: .visibility) ?? .public
        origin = try c.decodeIfPresent(LanguageOrigin.self, forKey: .origin) ?? .swift
        objcName = try c.decodeIfPresent(String.self, forKey: .objcName)
        genericParameters = try c.decodeIfPresent([String].self, forKey: .genericParameters) ?? []
        superclass = try c.decodeIfPresent(String.self, forKey: .superclass)
        conformances = try c.decodeIfPresent([String].self, forKey: .conformances) ?? []
        signatures = try c.decodeIfPresent([CatalogSignature].self, forKey: .signatures) ?? []
        members = try c.decodeIfPresent([CatalogMember].self, forKey: .members) ?? []
        enumCases = try c.decodeIfPresent([String].self, forKey: .enumCases) ?? []
        optionSetCases = try c.decodeIfPresent([String].self, forKey: .optionSetCases) ?? []
        documentationPath = try c.decodeIfPresent(String.self, forKey: .documentationPath)
        higPath = try c.decodeIfPresent(String.self, forKey: .higPath)
        related = try c.decodeIfPresent([CatalogRelation].self, forKey: .related) ?? []
        demoID = try c.decodeIfPresent(String.self, forKey: .demoID)
        summaryKey = try c.decodeIfPresent(String.self, forKey: .summaryKey)
        priority = try c.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        parentID = try c.decodeIfPresent(String.self, forKey: .parentID)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(framework, forKey: .framework)
        if !modules.isEmpty { try c.encode(modules, forKey: .modules) }
        try c.encode(name, forKey: .name)
        try c.encode(qualifiedName, forKey: .qualifiedName)
        try c.encode(kind, forKey: .kind)
        try c.encode(category, forKey: .category)
        try c.encodeIfPresent(family, forKey: .family)
        if !tags.isEmpty { try c.encode(tags, forKey: .tags) }
        if !aliases.isEmpty { try c.encode(aliases, forKey: .aliases) }
        if !availability.isEmpty { try c.encode(availability, forKey: .availability) }
        if visibility != .public { try c.encode(visibility, forKey: .visibility) }
        if origin != .swift { try c.encode(origin, forKey: .origin) }
        try c.encodeIfPresent(objcName, forKey: .objcName)
        if !genericParameters.isEmpty { try c.encode(genericParameters, forKey: .genericParameters) }
        try c.encodeIfPresent(superclass, forKey: .superclass)
        if !conformances.isEmpty { try c.encode(conformances, forKey: .conformances) }
        if !signatures.isEmpty { try c.encode(signatures, forKey: .signatures) }
        if !members.isEmpty { try c.encode(members, forKey: .members) }
        if !enumCases.isEmpty { try c.encode(enumCases, forKey: .enumCases) }
        if !optionSetCases.isEmpty { try c.encode(optionSetCases, forKey: .optionSetCases) }
        try c.encodeIfPresent(documentationPath, forKey: .documentationPath)
        try c.encodeIfPresent(higPath, forKey: .higPath)
        if !related.isEmpty { try c.encode(related, forKey: .related) }
        try c.encodeIfPresent(demoID, forKey: .demoID)
        try c.encodeIfPresent(summaryKey, forKey: .summaryKey)
        if priority != 0 { try c.encode(priority, forKey: .priority) }
        try c.encodeIfPresent(parentID, forKey: .parentID)
    }
}

// MARK: - Families, demos and manifest

public enum FamilyGroup: String, Codable, Sendable {
    /// Mirrors a Human Interface Guidelines component group.
    case hig
    /// Developer-oriented grouping added by the atlas.
    case developer
}

public struct CatalogFamily: Hashable, Sendable, Codable, Identifiable {
    public var id: String
    /// Localization key for the family title (e.g. `family.content`).
    public var titleKey: String
    public var systemImage: String
    public var group: FamilyGroup
    public var higPath: String?
    public var order: Int

    public init(id: String, titleKey: String, systemImage: String, group: FamilyGroup, higPath: String? = nil, order: Int) {
        self.id = id
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.group = group
        self.higPath = higPath
        self.order = order
    }
}

/// Curated demo metadata, validated by the generator against the SDK inventory.
public struct DemoMetadata: Hashable, Sendable, Codable, Identifiable {
    public var id: String
    public var symbol: String
    public var family: String
    public var priority: Int

    public init(id: String, symbol: String, family: String, priority: Int = 0) {
        self.id = id
        self.symbol = symbol
        self.family = family
        self.priority = priority
    }
}

public struct SDKIdentity: Hashable, Sendable, Codable {
    public var xcodeVersion: String
    public var xcodeBuild: String
    public var sdkName: String
    public var sdkVersion: String
    public var sdkBuild: String?
    public var targetTriple: String
    public var sdkPath: String

    public init(
        xcodeVersion: String,
        xcodeBuild: String,
        sdkName: String,
        sdkVersion: String,
        sdkBuild: String? = nil,
        targetTriple: String,
        sdkPath: String
    ) {
        self.xcodeVersion = xcodeVersion
        self.xcodeBuild = xcodeBuild
        self.sdkName = sdkName
        self.sdkVersion = sdkVersion
        self.sdkBuild = sdkBuild
        self.targetTriple = targetTriple
        self.sdkPath = sdkPath
    }

    public var osVersion: OSVersion? { OSVersion(string: sdkVersion) }
}

public struct CatalogFrameworkSummary: Hashable, Sendable, Codable {
    public var framework: Framework
    public var file: String
    public var counts: [String: Int]

    public init(framework: Framework, file: String, counts: [String: Int]) {
        self.framework = framework
        self.file = file
        self.counts = counts
    }
}

/// Result of comparing two SDK snapshots, expressed in catalog symbol IDs.
public struct CatalogDiff: Hashable, Sendable, Codable {
    public var fromSDK: String
    public var toSDK: String
    public var added: [String]
    public var removed: [String]
    public var changed: [String]
    public var deprecated: [String]

    public init(fromSDK: String, toSDK: String, added: [String] = [], removed: [String] = [], changed: [String] = [], deprecated: [String] = []) {
        self.fromSDK = fromSDK
        self.toSDK = toSDK
        self.added = added
        self.removed = removed
        self.changed = changed
        self.deprecated = deprecated
    }
}

public struct CatalogManifest: Hashable, Sendable, Codable {
    public var schemaVersion: Int
    public var generatorVersion: String
    public var sdk: SDKIdentity
    public var frameworks: [CatalogFrameworkSummary]
    public var families: [CatalogFamily]
    public var demos: [DemoMetadata]
    public var diff: CatalogDiff?

    public init(
        schemaVersion: Int,
        generatorVersion: String,
        sdk: SDKIdentity,
        frameworks: [CatalogFrameworkSummary],
        families: [CatalogFamily],
        demos: [DemoMetadata],
        diff: CatalogDiff? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.generatorVersion = generatorVersion
        self.sdk = sdk
        self.frameworks = frameworks
        self.families = families
        self.demos = demos
        self.diff = diff
    }

    public static let currentSchemaVersion = 1
    public static let fileName = "catalog-manifest.json"

    public static func frameworkFileName(_ framework: Framework) -> String {
        "catalog-\(framework.rawValue.lowercased()).json"
    }
}

/// The per-framework symbol file.
public struct CatalogFrameworkFile: Sendable, Codable {
    public var framework: Framework
    public var symbols: [CatalogSymbol]

    public init(framework: Framework, symbols: [CatalogSymbol]) {
        self.framework = framework
        self.symbols = symbols
    }
}
