import Foundation

enum AIProvider: String, Sendable {
    case glm
    case openRouterFree
    case openRouterBedrock
}

enum AppConfig {
    /// Resolved from AI_PROVIDER in Secrets.xcconfig. Falls back to openRouterFree.
    static var aiProvider: AIProvider {
        let raw = (Bundle.main.object(forInfoDictionaryKey: "AI_PROVIDER") as? String)
            ?? ProcessInfo.processInfo.environment["AI_PROVIDER"]
            ?? ""
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "glm":               return .glm
        case "openrouter_bedrock": return .openRouterBedrock
        default:                  return .openRouterFree
        }
    }

    // MARK: - OpenRouter: free tier
    static let openRouterFreeModel = "openrouter/free"
    static let openRouterFreeProviderOnly: [String]? = nil
    static let openRouterFreeAllowFallbacks = true

    // MARK: - OpenRouter: AWS Bedrock BYOK
    static let openRouterBedrockModel = "amazon/nova-micro-v1"
    static let openRouterBedrockProviderOnly: [String]? = ["amazon-bedrock"]
    static let openRouterBedrockAllowFallbacks = false

    // MARK: - Convenience accessors (resolved from aiProvider)
    static var openRouterModel: String {
        aiProvider == .openRouterBedrock ? openRouterBedrockModel : openRouterFreeModel
    }

    static var openRouterProviderOnly: [String]? {
        aiProvider == .openRouterBedrock ? openRouterBedrockProviderOnly : openRouterFreeProviderOnly
    }

    static var openRouterAllowFallbacks: Bool {
        aiProvider == .openRouterBedrock ? openRouterBedrockAllowFallbacks : openRouterFreeAllowFallbacks
    }

    static let openRouterReferer = "https://github.com/pahlavan/HealthLongi"
    static let openRouterAppTitle = "Vitals & Mind"

    static var glmAPIKey: String? {
        validatedKey(Bundle.main.object(forInfoDictionaryKey: "GLM_API_KEY") as? String)
            ?? validatedKey(ProcessInfo.processInfo.environment["GLM_API_KEY"])
    }

    static var openRouterAPIKey: String? {
        validatedKey(Bundle.main.object(forInfoDictionaryKey: "OPENROUTER_API_KEY") as? String)
            ?? validatedKey(ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"])
    }

    private static func validatedKey(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return nil }
        guard key != "your_key_here", key != "api_key" else { return nil }
        guard key != "your_openrouter_key_here" else { return nil }
        guard !key.hasPrefix("$(") else { return nil }
        return key
    }
}
