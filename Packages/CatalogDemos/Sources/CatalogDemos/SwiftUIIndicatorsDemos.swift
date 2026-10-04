import SwiftUI
import CatalogModel

// MARK: - ProgressView Demo

public struct SwiftUIProgressViewDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.ProgressView"
    public let titleKey = "demo.progressview.title"
    public let familyID = "status"

    public let parameters: [DemoParameter] = [
        .picker(key: "style", titleKey: "param.style", options: ["circular", "linear"], defaultValue: "linear"),
        .slider(key: "progress", titleKey: "param.progress", min: 0.0, max: 1.0, defaultValue: 0.65),
        .boolean(key: "indeterminate", titleKey: "param.indeterminate", defaultValue: false),
        .text(key: "label", titleKey: "param.label", defaultValue: "Downloading assets...")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "linearDeterminate", titleKey: "variant.linear_determinate", stateOverrides: ["style": AnySendable("linear"), "indeterminate": AnySendable(false)]),
        DemoVariant(id: "circularIndeterminate", titleKey: "variant.circular_indeterminate", stateOverrides: ["style": AnySendable("circular"), "indeterminate": AnySendable(true)]),
        DemoVariant(id: "complete", titleKey: "variant.complete", stateOverrides: ["progress": AnySendable(1.0), "indeterminate": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let style = state.string(for: "style", default: "linear")
        let progress = state.double(for: "progress", default: 0.65)
        let indeterminate = state.bool(for: "indeterminate", default: false)
        let label = state.string(for: "label", default: "Downloading assets...")

        return AnyView(
            VStack(spacing: 16) {
                if indeterminate {
                    if style == "circular" {
                        ProgressView(label)
                            .progressViewStyle(.circular)
                    } else {
                        ProgressView(label)
                            .progressViewStyle(.linear)
                    }
                } else {
                    if style == "circular" {
                        ProgressView(value: progress) {
                            Text(label)
                        }
                        .progressViewStyle(.circular)
                    } else {
                        ProgressView(value: progress) {
                            Text(label)
                        }
                        .progressViewStyle(.linear)
                    }
                }
            }
            .frame(maxWidth: 280)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let style = state.string(for: "style", default: "linear")
        let indeterminate = state.bool(for: "indeterminate", default: false)
        let progress = state.double(for: "progress", default: 0.65)
        let label = state.string(for: "label", default: "Downloading assets...")

        if indeterminate {
            return """
            ProgressView("\(label)")
                .progressViewStyle(.\(style))
            """
        } else {
            return """
            ProgressView(value: \(String(format: "%.2f", progress))) {
                Text("\(label)")
            }
            .progressViewStyle(.\(style))
            """
        }
    }

    public func uiKitCode(state: DemoState) -> String? {
        let style = state.string(for: "style", default: "linear")
        if style == "linear" {
            return """
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.progress = 0.65
            """
        } else {
            return """
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.startAnimating()
            """
        }
    }
}

// MARK: - Gauge Demo

public struct SwiftUIGaugeDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Gauge"
    public let titleKey = "demo.gauge.title"
    public let familyID = "status"

    public let parameters: [DemoParameter] = [
        .slider(key: "value", titleKey: "param.value", min: 0.0, max: 100.0, defaultValue: 72.0),
        .picker(key: "style", titleKey: "param.style", options: ["accessoryCircular", "linearCapacity", "accessoryLinear"], defaultValue: "accessoryCircular"),
        .text(key: "label", titleKey: "param.label", defaultValue: "Battery")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "circular", titleKey: "variant.circular", stateOverrides: ["style": AnySendable("accessoryCircular")]),
        DemoVariant(id: "linear", titleKey: "variant.linear", stateOverrides: ["style": AnySendable("accessoryLinear")]),
        DemoVariant(id: "capacity", titleKey: "variant.capacity", stateOverrides: ["style": AnySendable("linearCapacity")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let value = state.double(for: "value", default: 72.0)
        let style = state.string(for: "style", default: "accessoryCircular")
        let label = state.string(for: "label", default: "Battery")

        let gauge = Gauge(value: value, in: 0...100) {
            Text(label)
        } currentValueLabel: {
            Text("\(Int(value))%")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("100")
        }

        return AnyView(
            VStack {
                switch style {
                case "linearCapacity":
                    gauge.gaugeStyle(.linearCapacity)
                case "accessoryLinear":
                    gauge.gaugeStyle(.accessoryLinear)
                default:
                    gauge.gaugeStyle(.accessoryCircular)
                }
            }
            .frame(maxWidth: 240)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let style = state.string(for: "style", default: "accessoryCircular")
        let value = state.double(for: "value", default: 72.0)
        return """
        Gauge(value: \(String(format: "%.1f", value)), in: 0...100) {
            Text("Battery")
        } currentValueLabel: {
            Text("\(Int(value))%")
        }
        .gaugeStyle(.\(style))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        "// Gauge has no direct equivalent in UIKit; typically implemented via custom CoreAnimation CAShapeLayer layers."
    }
}

// MARK: - Label Demo

public struct SwiftUILabelDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Label"
    public let titleKey = "demo.label.title"
    public let familyID = "content"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Favorites"),
        .text(key: "icon", titleKey: "param.icon", defaultValue: "star.fill"),
        .picker(key: "style", titleKey: "param.style", options: ["titleAndIcon", "iconOnly", "titleOnly"], defaultValue: "titleAndIcon")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "both", titleKey: "variant.title_and_icon", stateOverrides: ["style": AnySendable("titleAndIcon")]),
        DemoVariant(id: "iconOnly", titleKey: "variant.icon_only", stateOverrides: ["style": AnySendable("iconOnly")]),
        DemoVariant(id: "titleOnly", titleKey: "variant.title_only", stateOverrides: ["style": AnySendable("titleOnly")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "Favorites")
        let icon = state.string(for: "icon", default: "star.fill")
        let style = state.string(for: "style", default: "titleAndIcon")

        let label = Label(title, systemImage: icon)

        return AnyView(
            VStack {
                switch style {
                case "iconOnly": label.labelStyle(.iconOnly)
                case "titleOnly": label.labelStyle(.titleOnly)
                default: label.labelStyle(.titleAndIcon)
                }
            }
            .font(.title3)
            .foregroundStyle(.primary)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let title = state.string(for: "title", default: "Favorites")
        let icon = state.string(for: "icon", default: "star.fill")
        let style = state.string(for: "style", default: "titleAndIcon")

        var code = "Label(\"\(title)\", systemImage: \"\(icon)\")"
        if style != "titleAndIcon" { code += "\n    .labelStyle(.\(style))" }
        return code
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        var config = UIButton.Configuration.plain()
        config.title = "Favorites"
        config.image = UIImage(systemName: "star.fill")
        config.imagePadding = 6
        """
    }
}

// MARK: - LabeledContent Demo

public struct SwiftUILabeledContentDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.LabeledContent"
    public let titleKey = "demo.labeledcontent.title"
    public let familyID = "content"

    public let parameters: [DemoParameter] = [
        .text(key: "label", titleKey: "param.label", defaultValue: "Storage Used"),
        .text(key: "content", titleKey: "param.content", defaultValue: "42.8 GB")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let label = state.string(for: "label", default: "Storage Used")
        let content = state.string(for: "content", default: "42.8 GB")

        return AnyView(
            LabeledContent(label, value: content)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: 300)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let label = state.string(for: "label", default: "Storage Used")
        let content = state.string(for: "content", default: "42.8 GB")
        return "LabeledContent(\"\(label)\", value: \"\(content)\")"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        var config = UIListContentConfiguration.valueCell()
        config.text = "Storage Used"
        config.secondaryText = "42.8 GB"
        """
    }
}

// MARK: - ContentUnavailableView Demo

public struct SwiftUIContentUnavailableViewDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.ContentUnavailableView"
    public let titleKey = "demo.contentunavailableview.title"
    public let familyID = "status"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "No Results Found"),
        .text(key: "systemImage", titleKey: "param.icon", defaultValue: "magnifyingglass"),
        .text(key: "description", titleKey: "param.description", defaultValue: "Check the spelling or try a different search.")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "search", titleKey: "variant.search", stateOverrides: ["title": AnySendable("No Results"), "systemImage": AnySendable("magnifyingglass")]),
        DemoVariant(id: "connection", titleKey: "variant.connection", stateOverrides: ["title": AnySendable("No Connection"), "systemImage": AnySendable("wifi.slash")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "No Results Found")
        let icon = state.string(for: "systemImage", default: "magnifyingglass")
        let desc = state.string(for: "description", default: "Check the spelling or try a different search.")

        return AnyView(
            ContentUnavailableView(
                title,
                systemImage: icon,
                description: Text(desc)
            )
            .frame(maxHeight: 240)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let title = state.string(for: "title", default: "No Results Found")
        let icon = state.string(for: "systemImage", default: "magnifyingglass")
        let desc = state.string(for: "description", default: "Check the spelling or try a different search.")

        return """
        ContentUnavailableView(
            "\(title)",
            systemImage: "\(icon)",
            description: Text("\(desc)")
        )
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        var config = UIContentUnavailableConfiguration.search()
        config.text = "No Results Found"
        config.secondaryText = "Check the spelling or try a different search."
        view.contentUnavailableConfiguration = config
        """
    }
}

// MARK: - AsyncImage Demo

public struct SwiftUIAsyncImageDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.AsyncImage"
    public let titleKey = "demo.asyncimage.title"
    public let familyID = "content"

    public let parameters: [DemoParameter] = [
        .text(key: "url", titleKey: "param.url", defaultValue: "https://picsum.photos/200")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let urlStr = state.string(for: "url", default: "https://picsum.photos/200")
        let url = URL(string: urlStr)

        return AnyView(
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 120, height: 120)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(width: 120, height: 120)
                @unknown default:
                    EmptyView()
                }
            }
            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        AsyncImage(url: URL(string: "https://example.com/photo.jpg")) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else if phase.error != nil {
                Image(systemName: "exclamationmark.triangle")
            } else {
                ProgressView()
            }
        }
        .frame(width: 120, height: 120)
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        // UIKit requires manual async loading or URLSession:
        let imageView = UIImageView()
        Task {
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let image = UIImage(data: data) {
                imageView.image = image
            }
        }
        """
    }
}
