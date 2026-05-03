import SwiftUI

/// A single transaction row showing title, date, and colored amount.
struct TransactionRowView: View {
    let transaction: TransactionItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // MARK: - Left: Title and Date
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title ?? "Untitled")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(Formatters.fullDate.string(from: transaction.date ?? Date()))
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // MARK: - Right: Amount
            Text(Formatters.signedCurrency(transaction.amount, isIncome: transaction.isIncome))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(Color.transactionColor(isIncome: transaction.isIncome))
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    VStack(spacing: 0) {
        let context = PersistenceController.preview.container.viewContext
        let income = TransactionItem(context: context)
        let expense = TransactionItem(context: context)
        
        let _ = {
            income.title = "Freelance Work"
            income.amount = 15000
            income.date = Date()
            income.isIncome = true
            income.createdAt = Date()
            
            expense.title = "Grocery Shopping"
            expense.amount = 2500
            expense.date = Date()
            expense.isIncome = false
            expense.createdAt = Date()
        }()
        
        TransactionRowView(transaction: income)
        Divider().padding(.leading, 16)
        TransactionRowView(transaction: expense)
    }
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.systemBg)
    )
    .padding()
}
