import SwiftUI
import CatalogModel

// MARK: - Parameter and State Models

public enum DemoParameter: Sendable, Identifiable {
    case boolean(key: String, titleKey: String, defaultValue: Bool)
    case picker(key: String, titleKey: String, options: [String], defaultValue: String)
    case stepper(key: String, titleKey: String, min: Int, max: Int, defaultValue: Int)
    case slider(key: String, titleKey: String, min: Double, max: Double, defaultValue: Double)
    case text(key: String, titleKey: String, defaultValue: String)

    public var id: String {
        switch self {
        case .boolean(let key, _, _): key
        case .picker(let key, _, _, _): key
        case .stepper(let key, _, _, _, _): key
        case .slider(let key, _, _, _, _): key
        case .text(let key, _, _): key
        }
    }
}

public struct DemoVariant: Sendable, Identifiable {
    public var id: String
    public var titleKey: String
    public var stateOverrides: [String: AnySendable]

    public init(id: String, titleKey: String, stateOverrides: [String: AnySendable] = [:]) {
        self.id = id
        self.titleKey = titleKey
        self.stateOverrides = stateOverrides
    }
}

public struct AnySendable: Sendable {
    public let boolValue: Bool?
    public let stringValue: String?
    public let intValue: Int?
    public let doubleValue: Double?

    public init(_ bool: Bool) {
        self.boolValue = bool
        self.stringValue = nil
        self.intValue = nil
        self.doubleValue = nil
    }

    public init(_ string: String) {
        self.boolValue = nil
        self.stringValue = string
        self.intValue = nil
        self.doubleValue = nil
    }

    public init(_ int: Int) {
        self.boolValue = nil
        self.stringValue = nil
        self.intValue = int
        self.doubleValue = nil
    }

    public init(_ double: Double) {
        self.boolValue = nil
        self.stringValue = nil
        self.intValue = nil
        self.doubleValue = double
    }
}

@MainActor
public final class DemoState: ObservableObject {
    @Published public var booleans: [String: Bool] = [:]
    @Published public var strings: [String: String] = [:]
    @Published public var ints: [String: Int] = [:]
    @Published public var doubles: [String: Double] = [:]

    public init() {}

    public func reset(from parameters: [DemoParameter]) {
        booleans.removeAll()
        strings.removeAll()
        ints.removeAll()
        doubles.removeAll()
        for p in parameters {
            switch p {
            case .boolean(let k, _, let def): booleans[k] = def
            case .picker(let k, _, _, let def): strings[k] = def
            case .stepper(let k, _, _, _, let def): ints[k] = def
            case .slider(let k, _, _, _, let def): doubles[k] = def
            case .text(let k, _, let def): strings[k] = def
            }
        }
    }

    public func apply(variant: DemoVariant) {
        for (k, val) in variant.stateOverrides {
            if let b = val.boolValue { booleans[k] = b }
            if let s = val.stringValue { strings[k] = s }
            if let i = val.intValue { ints[k] = i }
            if let d = val.doubleValue { doubles[k] = d }
        }
    }

    public func bool(for key: String, default def: Bool = false) -> Bool {
        booleans[key] ?? def
    }

    public func string(for key: String, default def: String = "") -> String {
        strings[key] ?? def
    }

    public func int(for key: String, default def: Int = 0) -> Int {
        ints[key] ?? def
    }

    public func double(for key: String, default def: Double = 0.0) -> Double {
        doubles[key] ?? def
    }
}

// MARK: - Demo Provider Protocol

@MainActor
public protocol CatalogDemoProvider: Sendable {
    var symbolID: String { get }
    var titleKey: String { get }
    var familyID: String { get }
    var parameters: [DemoParameter] { get }
    var variants: [DemoVariant] { get }

    @ViewBuilder
    func makePreview(state: DemoState) -> AnyView

    func swiftUICode(state: DemoState) -> String
    func uiKitCode(state: DemoState) -> String?
}

// MARK: - Registry

@MainActor
public final class CatalogDemoRegistry {
    public static let shared = CatalogDemoRegistry()

    private var providers: [String: CatalogDemoProvider] = [:]

    private init() {
        registerBuiltinDemos()
    }

    public func register(_ provider: CatalogDemoProvider) {
        providers[provider.symbolID] = provider
    }

    public func provider(for symbolID: String) -> CatalogDemoProvider? {
        providers[symbolID]
    }

    public var allDemos: [CatalogDemoProvider] {
        Array(providers.values)
    }

    public var demoMetadataList: [DemoMetadata] {
        providers.values.map {
            DemoMetadata(id: $0.symbolID, symbol: $0.symbolID, family: $0.familyID, priority: 100)
        }.sorted { $0.symbol < $1.symbol }
    }
}
