import SwiftUI

/// Modal sheet for adding or editing a transaction.
struct AddTransactionView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var isIncome: Bool = false
    @State private var showValidationError = false
    
    /// If non-nil, we're editing an existing transaction
    let transaction: TransactionItem?
    
    /// Whether we're in edit mode
    private var isEditing: Bool {
        transaction != nil
    }
    
    // MARK: - Init
    
    init(transaction: TransactionItem? = nil) {
        self.transaction = transaction
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Form Card
                    VStack(spacing: 0) {
                        // Title Field
                        formField {
                            TextField("Title", text: $title)
                                .font(.body)
                                #if os(iOS)
                                .textInputAutocapitalization(.words)
                                #endif
                        }
                        
                        Divider().padding(.leading, 16)
                        
                        // Amount Field
                        formField {
                            TextField("Amount", text: $amountText)
                                .font(.body)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                        }
                        
                        Divider().padding(.leading, 16)
                        
                        // Date Picker
                        formField {
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .font(.body)
                        }
                        
                        Divider().padding(.leading, 16)
                        
                        // Income/Expense Picker
                        formField {
                            Picker("Type", selection: $isIncome) {
                                Text("Income").tag(true)
                                Text("Expense").tag(false)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.systemBg)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .softShadow, radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    // Validation Error
                    if showValidationError {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(Color.expenseRed)
                            Text("Please enter a valid title and amount.")
                                .font(.caption)
                                .foregroundStyle(Color.expenseRed)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, 16)
            }
            .background(Color.subtleBackground)
            .navigationTitle(isEditing ? "Edit Entry" : "Add Entry")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.secondarySystemBg)
                    )
                }
            }
            .onAppear(perform: loadExistingData)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Form Field Helper
    
    private func formField<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }
    
    // MARK: - Actions
    
    private func loadExistingData() {
        guard let tx = transaction else { return }
        title = tx.title ?? ""
        amountText = String(format: "%.2f", tx.amount)
        date = tx.date ?? Date()
        isIncome = tx.isIncome
    }
    
    private func saveTransaction() {
        // Validate
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty,
              let amount = Double(amountText),
              amount > 0 else {
            withAnimation(.spring(response: 0.3)) {
                showValidationError = true
            }
            
            // Auto-hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showValidationError = false }
            }
            return
        }
        
        if let existing = transaction {
            viewModel.updateTransaction(
                existing,
                title: trimmedTitle,
                amount: amount,
                date: date,
                isIncome: isIncome
            )
        } else {
            viewModel.addTransaction(
                title: trimmedTitle,
                amount: amount,
                date: date,
                isIncome: isIncome
            )
        }
        
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(
            TransactionViewModel(
                context: PersistenceController.preview.container.viewContext
            )
        )
}
