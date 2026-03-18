import Foundation

public enum PriceFormatter {
    public static func format(_ price: Double) -> String {
        if price < 0.01 {
            return String(format: "$%.4f", price)
        } else if price < 1 {
            return String(format: "$%.3f", price)
        } else if price < 100 {
            return String(format: "$%.2f", price)
        } else {
            return String(format: "$%.0f", price)
        }
    }

    public static func formatPair(input: Double, output: Double) -> String {
        "\(format(input)) / \(format(output))"
    }

    public static func formatContext(_ tokens: Int) -> String {
        if tokens >= 1_000_000 {
            let m = Double(tokens) / 1_000_000
            return m.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(m))M"
                : String(format: "%.1fM", m)
        } else {
            return "\(tokens / 1000)K"
        }
    }

    public static func formatSpeed(_ tokensPerSec: Double) -> String {
        if tokensPerSec >= 1000 {
            return String(format: "%.0f t/s", tokensPerSec)
        } else if tokensPerSec >= 100 {
            return String(format: "%.0f t/s", tokensPerSec)
        } else {
            return String(format: "%.0f t/s", tokensPerSec)
        }
    }

    public static func formatSavings(_ percent: Double) -> String {
        if percent <= 0 { return "—" }
        return String(format: "↓%.0f%%", percent)
    }
}
