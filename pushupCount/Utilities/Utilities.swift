import Foundation

struct Utilities {
    static func formattedValue(_ value: Double) -> String {
        let roundedValue = round(value * 100) / 100
        return String(format: "%.2f", roundedValue)
    }
}
