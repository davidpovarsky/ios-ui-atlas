import Foundation
import CatalogModel

// MARK: - Core SDK Models

public struct SDKParameter: Codable, Hashable, Sendable {
    public var label: String?
    public var name: String
    public var type: String
    public var defaultValue: String?
    public var attributes: [String]
    public var isBinding: Bool
    public var isViewBuilder: Bool
    public var isClosure: Bool

    public init(
        label: String? = nil,
        name: String,
        type: String,
        defaultValue: String? = nil,
        attributes: [String] = [],
        isBinding: Bool = false,
        isViewBuilder: Bool = false,
        isClosure: Bool = false
    ) {
        self.label = label
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.attributes = attributes
        self.isBinding = isBinding
        self.isViewBuilder = isViewBuilder
        self.isClosure = isClosure
    }
}

public struct SDKSignature: Codable, Hashable, Sendable {
    public var declaration: String
    public var parameters: [SDKParameter]
    public var returnType: String?
    public var genericParameters: [String]
    public var isAsync: Bool
    public var isThrowing: Bool
    public var availability: CatalogAvailability
    public var rawAvailability: [String]
    public var attributes: [String]

    public init(
        declaration: String = "",
        parameters: [SDKParameter] = [],
        returnType: String? = nil,
        genericParameters: [String] = [],
        isAsync: Bool = false,
        isThrowing: Bool = false,
        availability: CatalogAvailability = .init(),
        rawAvailability: [String] = [],
        attributes: [String] = []
    ) {
        self.declaration = declaration
        self.parameters = parameters
        self.returnType = returnType
        self.genericParameters = genericParameters
        self.isAsync = isAsync
        self.isThrowing = isThrowing
        self.availability = availability
        self.rawAvailability = rawAvailability
        self.attributes = attributes
    }
}

public struct SDKMember: Codable, Hashable, Sendable {
    public var name: String
    public var kind: MemberKind
    public var declaration: String
    public var availability: CatalogAvailability
    public var rawAvailability: [String]
    public var isRequirement: Bool
    public var objcName: String?

    public init(
        name: String,
        kind: MemberKind,
        declaration: String,
        availability: CatalogAvailability = .init(),
        rawAvailability: [String] = [],
        isRequirement: Bool = false,
        objcName: String? = nil
    ) {
        self.name = name
        self.kind = kind
        self.declaration = declaration
        self.availability = availability
        self.rawAvailability = rawAvailability
        self.isRequirement = isRequirement
        self.objcName = objcName
    }
}

public struct SDKDeclaration: Codable, Hashable, Sendable {
    public var id: String
    public var framework: Framework
    public var module: String
    public var symbol: String
    public var qualifiedName: String
    public var kind: SymbolKind
    public var origin: LanguageOrigin
    public var visibility: SymbolVisibility
    public var availability: CatalogAvailability
    public var rawAvailability: [String]
    public var attributes: [String]
    public var genericParameters: [String]
    public var superclass: String?
    public var conformances: [String]
    public var signatures: [SDKSignature]
    public var members: [SDKMember]
    public var enumCases: [String]
    public var optionSetCases: [String]
    public var preciseIdentifier: String?
    public var documentationPath: String?

    public init(
        id: String,
        framework: Framework,
        module: String,
        symbol: String,
        qualifiedName: String,
        kind: SymbolKind,
        origin: LanguageOrigin = .swift,
        visibility: SymbolVisibility = .public,
        availability: CatalogAvailability = .init(),
        rawAvailability: [String] = [],
        attributes: [String] = [],
        genericParameters: [String] = [],
        superclass: String? = nil,
        conformances: [String] = [],
        signatures: [SDKSignature] = [],
        members: [SDKMember] = [],
        enumCases: [String] = [],
        optionSetCases: [String] = [],
        preciseIdentifier: String? = nil,
        documentationPath: String? = nil
    ) {
        self.id = id
        self.framework = framework
        self.module = module
        self.symbol = symbol
        self.qualifiedName = qualifiedName
        self.kind = kind
        self.origin = origin
        self.visibility = visibility
        self.availability = availability
        self.rawAvailability = rawAvailability
        self.attributes = attributes
        self.genericParameters = genericParameters
        self.superclass = superclass
        self.conformances = conformances
        self.signatures = signatures
        self.members = members
        self.enumCases = enumCases
        self.optionSetCases = optionSetCases
        self.preciseIdentifier = preciseIdentifier
        self.documentationPath = documentationPath
    }
}

public struct SDKSourceFileIdentity: Codable, Hashable, Sendable {
    public var module: String
    public var fileName: String
    public var sha256: String

    public init(module: String, fileName: String, sha256: String) {
        self.module = module
        self.fileName = fileName
        self.sha256 = sha256
    }
}

public struct SDKRawInventory: Codable, Sendable {
    public var schemaVersion: Int
    public var generatorVersion: String
    public var framework: Framework
    public var sdkIdentity: SDKIdentity
    public var sourceFiles: [SDKSourceFileIdentity]
    public var declarations: [SDKDeclaration]

    public init(
        schemaVersion: Int = 1,
        generatorVersion: String,
        framework: Framework,
        sdkIdentity: SDKIdentity,
        sourceFiles: [SDKSourceFileIdentity],
        declarations: [SDKDeclaration]
    ) {
        self.schemaVersion = schemaVersion
        self.generatorVersion = generatorVersion
        self.framework = framework
        self.sdkIdentity = sdkIdentity
        self.sourceFiles = sourceFiles.sorted { $0.module < $1.module }
        self.declarations = declarations.sorted {
            ($0.framework.rawValue, $0.qualifiedName, $0.kind.rawValue) <
            ($1.framework.rawValue, $1.qualifiedName, $1.kind.rawValue)
        }
    }
}
