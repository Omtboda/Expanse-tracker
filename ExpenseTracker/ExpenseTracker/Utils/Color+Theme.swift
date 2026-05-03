import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// App-wide theme colors with dark mode support.
extension Color {
    
    // MARK: - Semantic Colors
    
    /// Green for income / positive balance
    static let incomeGreen = Color(red: 0.20, green: 0.72, blue: 0.40)
    
    /// Red for expense / negative balance
    static let expenseRed = Color(red: 0.92, green: 0.30, blue: 0.28)
    
    // MARK: - Surface Colors
    
    /// Card background — adapts to dark mode
    static let cardBg = Color("CardBackground", bundle: nil)
    
    /// Subtle background for sections
    #if os(iOS)
    static let subtleBackground = Color(UIColor.systemGray6)
    #elseif os(macOS)
    static let subtleBackground = Color(NSColor.windowBackgroundColor)
    #endif
    
    // MARK: - Text Colors
    
    #if os(iOS)
    /// Primary text
    static let primaryText = Color(UIColor.label)
    
    /// Secondary / light text
    static let secondaryText = Color(UIColor.secondaryLabel)
    
    /// Tertiary text
    static let tertiaryText = Color(UIColor.tertiaryLabel)
    #elseif os(macOS)
    /// Primary text
    static let primaryText = Color(NSColor.labelColor)
    
    /// Secondary / light text
    static let secondaryText = Color(NSColor.secondaryLabelColor)
    
    /// Tertiary text
    static let tertiaryText = Color(NSColor.tertiaryLabelColor)
    #endif
    
    // MARK: - Accent
    
    /// App accent blue — used for today highlight, buttons
    static let accentBlue = Color(red: 0.40, green: 0.60, blue: 0.95)
    
    /// Soft shadow color
    static let softShadow = Color.black.opacity(0.06)
    
    // MARK: - Helpers
    
    /// Returns income green or expense red based on the value
    static func balanceColor(for amount: Double) -> Color {
        if amount > 0 { return .incomeGreen }
        if amount < 0 { return .expenseRed }
        return .primaryText
    }
    
    /// Returns income green or expense red based on isIncome flag
    static func transactionColor(isIncome: Bool) -> Color {
        isIncome ? .incomeGreen : .expenseRed
    }
}

// MARK: - Platform-specific system colors

extension Color {
    #if os(iOS)
    static let systemBg = Color(UIColor.systemBackground)
    static let secondarySystemBg = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBg = Color(UIColor.tertiarySystemBackground)
    #elseif os(macOS)
    static let systemBg = Color(NSColor.windowBackgroundColor)
    static let secondarySystemBg = Color(NSColor.controlBackgroundColor)
    static let tertiarySystemBg = Color(NSColor.underPageBackgroundColor)
    #endif
}
