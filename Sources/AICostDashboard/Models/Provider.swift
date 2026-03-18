import SwiftUI

public enum Provider: String, CaseIterable, Identifiable, Sendable, Codable {
    case anthropic
    case openai
    case google
    case openRouter
    case bedrock
    case azure
    case vertex

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .anthropic: "Anthropic"
        case .openai: "OpenAI"
        case .google: "Google AI Studio"
        case .openRouter: "OpenRouter"
        case .bedrock: "AWS Bedrock"
        case .azure: "Azure OpenAI"
        case .vertex: "Google Vertex"
        }
    }

    public var shortName: String {
        switch self {
        case .anthropic: "Anthropic"
        case .openai: "OpenAI"
        case .google: "Google"
        case .openRouter: "OpenRouter"
        case .bedrock: "Bedrock"
        case .azure: "Azure"
        case .vertex: "Vertex"
        }
    }

    public var color: Color {
        switch self {
        case .anthropic: Color(red: 0.82, green: 0.55, blue: 0.28)
        case .openai: Color(red: 0.0, green: 0.64, blue: 0.53)
        case .google: Color(red: 0.26, green: 0.52, blue: 0.96)
        case .openRouter: Color(red: 0.58, green: 0.29, blue: 0.95)
        case .bedrock: Color(red: 1.0, green: 0.60, blue: 0.0)
        case .azure: Color(red: 0.0, green: 0.47, blue: 0.84)
        case .vertex: Color(red: 0.20, green: 0.66, blue: 0.33)
        }
    }

    public var isAggregator: Bool {
        switch self {
        case .openRouter, .bedrock, .azure, .vertex: true
        default: false
        }
    }
}
