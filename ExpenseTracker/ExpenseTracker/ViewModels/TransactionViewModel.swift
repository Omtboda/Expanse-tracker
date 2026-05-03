import Foundation
import CoreData
import SwiftUI

/// Represents a group of transactions for a specific month.
struct MonthGroup: Identifiable {
    let id: String  // "2026-04" format
    let displayName: String  // "April 2026"
    let transactions: [TransactionItem]
}

/// Main ViewModel managing all transaction operations with MVVM pattern.
final class TransactionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var transactions: [TransactionItem] = []
    @Published var showingAddSheet = false
    @Published var editingTransaction: TransactionItem?
    @Published var showUndoToast = false
    @Published var undoMessage = ""
    
    // MARK: - Private
    
    private let viewContext: NSManagedObjectContext
    private var deletedTransactionData: DeletedTransactionData?
    
    /// Temporarily stores deleted transaction data for undo
    private struct DeletedTransactionData {
        let title: String
        let amount: Double
        let date: Date
        let isIncome: Bool
        let category: String
        let createdAt: Date
    }
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTransactions()
        
        // Listen for Core Data changes (e.g. from CloudKit sync)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidChange),
            name: .NSManagedObjectContextObjectsDidChange,
            object: context
        )
    }
    
    @objc private func contextDidChange(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.fetchTransactions()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Net balance across all transactions
    var netBalance: Double {
        transactions.reduce(0) { sum, tx in
            sum + (tx.isIncome ? tx.amount : -tx.amount)
        }
    }
    
    /// Transactions grouped by month, sorted by date descending
    var groupedByMonth: [MonthGroup] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: transactions) { (tx: TransactionItem) -> String in
            let components = calendar.dateComponents(in: .current, from: tx.date ?? Date())
            let year = components.year ?? 2026
            let month = components.month ?? 1
            return String(format: "%04d-%02d", year, month)
        }
        
        return grouped
            .map { key, txns in
                // Parse key to create display name
                let parts = key.split(separator: "-")
                let year = Int(parts[0]) ?? 2026
                let month = Int(parts[1]) ?? 1
                
                var dateComponents = DateComponents()
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = 1
                let date = calendar.date(from: dateComponents) ?? Date()
                let displayName = Formatters.monthYear.string(from: date)
                
                // Sort within group: date desc → amount desc → createdAt desc
                let sorted = txns.sorted { a, b in
                    let dateA = a.date ?? Date.distantPast
                    let dateB = b.date ?? Date.distantPast
                    
                    if !calendar.isDate(dateA, inSameDayAs: dateB) {
                        return dateA > dateB
                    }
                    if a.amount != b.amount {
                        return a.amount > b.amount
                    }
                    return (a.createdAt ?? Date.distantPast) > (b.createdAt ?? Date.distantPast)
                }
                
                return MonthGroup(id: key, displayName: displayName, transactions: sorted)
            }
            .sorted { $0.id > $1.id }
    }
    
    /// Daily net totals for a given month — used by calendar view
    func dailyTotals(for date: Date) -> [Date: Double] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return [:]
        }
        
        var totals: [Date: Double] = [:]
        
        for tx in transactions {
            guard let txDate = tx.date else { continue }
            let txDay = calendar.startOfDay(for: txDate)
            
            if txDay >= calendar.startOfDay(for: startOfMonth) &&
               txDay <= calendar.startOfDay(for: endOfMonth) {
                let amount = tx.isIncome ? tx.amount : -tx.amount
                totals[txDay, default: 0] += amount
            }
        }
        
        return totals
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all transactions with proper sorting
    func fetchTransactions() {
        let request: NSFetchRequest<TransactionItem> = TransactionItem.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TransactionItem.date, ascending: false),
            NSSortDescriptor(keyPath: \TransactionItem.amount, ascending: false),
            NSSortDescriptor(keyPath: \TransactionItem.createdAt, ascending: false)
        ]
        
        do {
            transactions = try viewContext.fetch(request)
        } catch {
            print("Error fetching transactions: \(error.localizedDescription)")
        }
    }
    
    /// Add a new transaction
    func addTransaction(
        title: String,
        amount: Double,
        date: Date,
        isIncome: Bool,
        category: String = "General"
    ) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            let transaction = TransactionItem(context: viewContext)
            transaction.id = UUID()
            transaction.title = title
            transaction.amount = amount
            transaction.date = date
            transaction.isIncome = isIncome
            transaction.category = category
            transaction.createdAt = Date()
            
            saveContext()
            fetchTransactions()
        }
        
        triggerHaptic()
    }
    
    /// Update an existing transaction
    func updateTransaction(
        _ transaction: TransactionItem,
        title: String,
        amount: Double,
        date: Date,
        isIncome: Bool,
        category: String = "General"
    ) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            transaction.title = title
            transaction.amount = amount
            transaction.date = date
            transaction.isIncome = isIncome
            transaction.category = category
            
            saveContext()
            fetchTransactions()
        }
        
        triggerHaptic()
    }
    
    /// Delete a transaction with undo support
    func deleteTransaction(_ transaction: TransactionItem) {
        // Store data for undo
        deletedTransactionData = DeletedTransactionData(
            title: transaction.title ?? "",
            amount: transaction.amount,
            date: transaction.date ?? Date(),
            isIncome: transaction.isIncome,
            category: transaction.category ?? "General",
            createdAt: transaction.createdAt ?? Date()
        )
        
        undoMessage = "Deleted \"\(transaction.title ?? "Transaction")\""
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewContext.delete(transaction)
            saveContext()
            fetchTransactions()
            showUndoToast = true
        }
        
        // Auto-dismiss undo toast after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            withAnimation {
                self?.showUndoToast = false
                self?.deletedTransactionData = nil
            }
        }
    }
    
    /// Undo the last deletion
    func undoDelete() {
        guard let data = deletedTransactionData else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            let transaction = TransactionItem(context: viewContext)
            transaction.id = UUID()
            transaction.title = data.title
            transaction.amount = data.amount
            transaction.date = data.date
            transaction.isIncome = data.isIncome
            transaction.category = data.category
            transaction.createdAt = data.createdAt
            
            saveContext()
            fetchTransactions()
            
            showUndoToast = false
            deletedTransactionData = nil
        }
        
        triggerHaptic()
    }
    
    // MARK: - Private Helpers
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func triggerHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}
