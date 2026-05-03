import Foundation

/// Centralized formatters for currency and date display.
enum Formatters {
    
    // MARK: - Currency
    
    /// Full INR currency formatter: ₹1,234.56
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }()
    
    /// Compact currency formatter for calendar cells: ₹10.3K
    static let compactCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    /// Formats amount with sign prefix: +₹5,000.00 or -₹500.00
    static func signedCurrency(_ amount: Double, isIncome: Bool) -> String {
        let absAmount = abs(amount)
        let formatted = currency.string(from: NSNumber(value: absAmount)) ?? "₹0.00"
        return isIncome ? "+\(formatted)" : "-\(formatted)"
    }
    
    /// Formats balance value: ₹5,000.00 or ₹-500.00
    static func balanceCurrency(_ amount: Double) -> String {
        let formatted = currency.string(from: NSNumber(value: abs(amount))) ?? "₹0.00"
        return amount < 0 ? "₹-\(formatted.replacingOccurrences(of: "₹", with: ""))" : formatted
    }
    
    /// Compact format for calendar: ₹10.3K, ₹500
    static func compact(_ amount: Double) -> String {
        let absAmount = abs(amount)
        if absAmount >= 100_000 {
            let lakhs = absAmount / 100_000
            return "₹\(String(format: "%.1f", lakhs))L"
        } else if absAmount >= 1_000 {
            let thousands = absAmount / 1_000
            return "₹\(String(format: "%.1f", thousands))K"
        } else {
            return "₹\(Int(absAmount))"
        }
    }
    
    // MARK: - Dates
    
    /// Full date: "14 April 2026"
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.timeZone = .current
        return formatter
    }()
    
    /// Short date: "14 Apr 2026"
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.timeZone = .current
        return formatter
    }()
    
    /// Month year: "April 2026"
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.timeZone = .current
        return formatter
    }()
    
    /// Month only: "May"
    static let monthOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.timeZone = .current
        return formatter
    }()
    
    /// Day of month: "14"
    static let dayOfMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = .current
        return formatter
    }()
}
