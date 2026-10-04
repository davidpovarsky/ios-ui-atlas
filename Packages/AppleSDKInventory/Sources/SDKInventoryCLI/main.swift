import Foundation
import CatalogModel
import AppleSDKInventoryCore

struct CLIArguments {
    var swiftUIInterfaces: [SwiftInterfaceInput] = []
    var uikitSymbolGraphDir: URL?
    var metadataDir: URL?
    var outputDir: URL?
    var xcodeVersion = "Xcode 27.0"
    var xcodeBuild = "27A266a"
    var sdkName = "iphoneos"
    var sdkVersion = "27.0"
    var targetTriple = "arm64e-apple-ios"
    var sdkPath = ""
    var check = false
}

func parseArgs() throws -> CLIArguments {
    var args = CLIArguments()
    var iter = CommandLine.arguments.dropFirst().makeIterator()
    while let arg = iter.next() {
        switch arg {
        case "--swiftui-interface":
            guard let val = iter.next(), let sep = val.firstIndex(of: "=") else {
                throw NSError(domain: "SDKInventoryCLI", code: 1, userInfo: [NSLocalizedDescriptionKey: "--swiftui-interface expects Module=path"])
            }
            let mod = String(val[..<sep])
            let path = String(val[val.index(after: sep)...])
            args.swiftUIInterfaces.append(.init(module: mod, url: URL(fileURLWithPath: path)))
        case "--uikit-symbolgraph-dir":
            args.uikitSymbolGraphDir = iter.next().map { URL(fileURLWithPath: $0) }
        case "--metadata-dir":
            args.metadataDir = iter.next().map { URL(fileURLWithPath: $0) }
        case "--output-dir":
            args.outputDir = iter.next().map { URL(fileURLWithPath: $0) }
        case "--xcode-version":
            args.xcodeVersion = iter.next() ?? args.xcodeVersion
        case "--xcode-build":
            args.xcodeBuild = iter.next() ?? args.xcodeBuild
        case "--sdk-name":
            args.sdkName = iter.next() ?? args.sdkName
        case "--sdk-version":
            args.sdkVersion = iter.next() ?? args.sdkVersion
        case "--target-triple":
            args.targetTriple = iter.next() ?? args.targetTriple
        case "--sdk-path":
            args.sdkPath = iter.next() ?? args.sdkPath
        case "--check":
            args.check = true
        default:
            throw NSError(domain: "SDKInventoryCLI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown option \(arg)"])
        }
    }
    return args
}

do {
    let args = try parseArgs()
    guard let metadataDir = args.metadataDir, let outputDir = args.outputDir else {
        throw NSError(domain: "SDKInventoryCLI", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing required --metadata-dir or --output-dir"])
    }

    let decoder = JSONDecoder()

    // 1. Parse SwiftUI interfaces
    var swiftUIDeclarations: [SDKDeclaration] = []
    var swiftUISourceFiles: [SDKSourceFileIdentity] = []
    for input in args.swiftUIInterfaces.sorted(by: { $0.module < $1.module }) {
        let (fileId, decls) = try SwiftUIInterfaceParser.parse(input)
        swiftUISourceFiles.append(fileId)
        swiftUIDeclarations.append(contentsOf: decls)
    }

    // 2. Parse UIKit symbol graph
    var uiKitDeclarations: [SDKDeclaration] = []
    if let sgDir = args.uikitSymbolGraphDir {
        uiKitDeclarations = try UIKitSymbolGraphExtractor.extract(from: sgDir)
    }

    // 3. Load metadata
    let familiesURL = metadataDir.appendingPathComponent("families.json")
    let families = try decoder.decode([CatalogFamily].self, from: Data(contentsOf: familiesURL))

    let aliasesURL = metadataDir.appendingPathComponent("aliases.json")
    let aliases = (try? decoder.decode([String: [String]].self, from: Data(contentsOf: aliasesURL))) ?? [:]

    let relURL = metadataDir.appendingPathComponent("relationships.json")
    let relationships = (try? decoder.decode([[String: String]].self, from: Data(contentsOf: relURL))) ?? []

    let overridesURL = metadataDir.appendingPathComponent("documentation-overrides.json")
    let docOverrides = (try? decoder.decode([String: String].self, from: Data(contentsOf: overridesURL))) ?? [:]

    let demosURL = metadataDir.appendingPathComponent("demos.json")
    let demos = (try? decoder.decode([DemoMetadata].self, from: Data(contentsOf: demosURL))) ?? []

    let sdkIdentity = SDKIdentity(
        xcodeVersion: args.xcodeVersion,
        xcodeBuild: args.xcodeBuild,
        sdkName: args.sdkName,
        sdkVersion: args.sdkVersion,
        targetTriple: args.targetTriple,
        sdkPath: args.sdkPath
    )

    // 4. Build catalog
    let buildResult = try CatalogBuilder.build(inputs: .init(
        swiftUIDeclarations: swiftUIDeclarations,
        uiKitDeclarations: uiKitDeclarations,
        families: families,
        aliases: aliases,
        relationships: relationships,
        docOverrides: docOverrides,
        demos: demos,
        sdkIdentity: sdkIdentity
    ))

    // 5. Raw inventories
    let rawSwiftUI = SDKRawInventory(
        generatorVersion: "1.0.0",
        framework: .swiftUI,
        sdkIdentity: sdkIdentity,
        sourceFiles: swiftUISourceFiles,
        declarations: swiftUIDeclarations
    )
    let rawUIKit = SDKRawInventory(
        generatorVersion: "1.0.0",
        framework: .uiKit,
        sdkIdentity: sdkIdentity,
        sourceFiles: [],
        declarations: uiKitDeclarations
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

    let catalogDir = outputDir.appendingPathComponent("Catalog")
    let fm = FileManager.default
    let tempDir = fm.temporaryDirectory.appendingPathComponent("sdk-inv-check-\(UUID().uuidString)")

    let targetDir = args.check ? tempDir : outputDir
    let targetCatalogDir = targetDir.appendingPathComponent("Catalog")
    let targetSwiftUIDir = targetDir.appendingPathComponent("SwiftUI")
    let targetUIKitDir = targetDir.appendingPathComponent("UIKit")

    try fm.createDirectory(at: targetCatalogDir, withIntermediateDirectories: true)
    try fm.createDirectory(at: targetSwiftUIDir, withIntermediateDirectories: true)
    try fm.createDirectory(at: targetUIKitDir, withIntermediateDirectories: true)

    func writeNewline(_ data: Data, to url: URL) throws {
        var d = data
        d.append(0x0a)
        try d.write(to: url)
    }

    try writeNewline(encoder.encode(buildResult.manifest), to: targetCatalogDir.appendingPathComponent(CatalogManifest.fileName))
    try writeNewline(encoder.encode(buildResult.swiftUIFile), to: targetCatalogDir.appendingPathComponent(CatalogManifest.frameworkFileName(.swiftUI)))
    try writeNewline(encoder.encode(buildResult.uiKitFile), to: targetCatalogDir.appendingPathComponent(CatalogManifest.frameworkFileName(.uiKit)))

    try writeNewline(encoder.encode(rawSwiftUI), to: targetSwiftUIDir.appendingPathComponent("raw-inventory.json"))
    try writeNewline(encoder.encode(rawUIKit), to: targetUIKitDir.appendingPathComponent("raw-inventory.json"))

    if args.check {
        defer { try? fm.removeItem(at: tempDir) }
        let checkFiles = [
            ("Catalog", CatalogManifest.fileName),
            ("Catalog", CatalogManifest.frameworkFileName(.swiftUI)),
            ("Catalog", CatalogManifest.frameworkFileName(.uiKit)),
            ("SwiftUI", "raw-inventory.json"),
            ("UIKit", "raw-inventory.json"),
        ]
        for (sub, name) in checkFiles {
            let expected = outputDir.appendingPathComponent(sub).appendingPathComponent(name)
            let generated = tempDir.appendingPathComponent(sub).appendingPathComponent(name)
            guard fm.contentsEqual(atPath: expected.path, andPath: generated.path) else {
                throw NSError(domain: "SDKInventoryCLI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Generated output is stale: \(sub)/\(name)"])
            }
        }
        print("SDK inventory check passed byte-for-byte!")
    } else {
        print("Generated SDK inventory:")
        print("  SwiftUI declarations: \(swiftUIDeclarations.count)")
        print("  UIKit declarations:   \(uiKitDeclarations.count)")
        print("  Manifest written to:  \(catalogDir.path)")
    }
} catch {
    fputs("error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
