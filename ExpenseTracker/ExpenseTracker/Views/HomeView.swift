import SwiftUI

/// Main home screen showing balance card and grouped transaction list.
struct HomeView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Balance Card
                        balanceCard
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                        
                        // MARK: - Transaction List
                        if viewModel.transactions.isEmpty {
                            EmptyStateView()
                                .padding(.top, 60)
                        } else {
                            transactionList
                        }
                    }
                    .padding(.bottom, 100) // Extra space for undo toast
                }
                .background(Color.subtleBackground)
                
                // MARK: - Undo Toast
                if viewModel.showUndoToast {
                    undoToast
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 16)
                }
            }
            .navigationTitle("Expense Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.editingTransaction = nil
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.secondarySystemBg)
                            )
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddTransactionView(transaction: viewModel.editingTransaction)
                    .environmentObject(viewModel)
            }
        }
    }
    
    // MARK: - Balance Card
    
    private var balanceCard: some View {
        VStack(spacing: 6) {
            Text("Net Balance")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Text(Formatters.balanceCurrency(viewModel.netBalance))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.balanceColor(for: viewModel.netBalance))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4), value: viewModel.netBalance)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.systemBg)
                .shadow(color: .softShadow, radius: 12, x: 0, y: 4)
        )
    }
    
    // MARK: - Transaction List
    
    private var transactionList: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(viewModel.groupedByMonth) { group in
                Section {
                    VStack(spacing: 0) {
                        ForEach(group.transactions, id: \.objectID) { transaction in
                            TransactionRowView(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.editingTransaction = transaction
                                    viewModel.showingAddSheet = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            
                            // Divider between items (not after last)
                            if transaction.objectID != group.transactions.last?.objectID {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.systemBg)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .softShadow, radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                } header: {
                    sectionHeader(title: group.displayName)
                }
            }
        }
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.subtleBackground.opacity(0.95))
    }
    
    // MARK: - Undo Toast
    
    private var undoToast: some View {
        HStack(spacing: 12) {
            Image(systemName: "trash.fill")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            
            Text(viewModel.undoMessage)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button("Undo") {
                viewModel.undoDelete()
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(white: 0.25))
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    HomeView()
        .environmentObject(
            TransactionViewModel(
                context: PersistenceController.preview.container.viewContext
            )
        )
}
