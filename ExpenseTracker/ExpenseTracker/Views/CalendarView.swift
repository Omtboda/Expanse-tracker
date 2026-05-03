import SwiftUI

/// Custom calendar view showing daily net totals with month navigation.
struct CalendarView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var currentMonth: Date = Date()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var calendar: Calendar { Calendar.current }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Month Navigation
                    monthNavigationHeader
                    
                    // MARK: - Weekday Headers
                    weekdayHeader
                    
                    // MARK: - Day Grid
                    dayGrid
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.subtleBackground)
            .navigationTitle("Calendar")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    // MARK: - Month Navigation Header
    
    private var monthNavigationHeader: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    navigateMonth(by: -1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.secondarySystemBg)
                    )
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(Formatters.monthOnly.string(from: currentMonth))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(yearString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    navigateMonth(by: 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.secondarySystemBg)
                    )
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Weekday Header
    
    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
            }
        }
    }
    
    // MARK: - Day Grid
    
    private var dayGrid: some View {
        let dailyTotals = viewModel.dailyTotals(for: currentMonth)
        let days = generateDays()
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { day in
                if let day = day {
                    let startOfDay = calendar.startOfDay(for: day)
                    let total = dailyTotals[startOfDay]
                    let isToday = calendar.isDateInToday(day)
                    
                    dayCellView(day: day, total: total, isToday: isToday)
                } else {
                    // Empty cell for alignment
                    Color.clear
                        .frame(height: 70)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.systemBg)
                .shadow(color: .softShadow, radius: 12, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    // MARK: - Day Cell
    
    private func dayCellView(day: Date, total: Double?, isToday: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.accentBlue)
                        .frame(width: 32, height: 32)
                }
                
                Text(Formatters.dayOfMonth.string(from: day))
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundStyle(isToday ? .white : .primary)
            }
            .frame(height: 32)
            
            if let total = total, total != 0 {
                Text(Formatters.compact(total))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.balanceColor(for: total))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Text(" ")
                    .font(.system(size: 10))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .contentShape(Rectangle())
    }
    
    // MARK: - Helpers
    
    private var yearString: String {
        let components = calendar.dateComponents([.year], from: currentMonth)
        return "\(components.year ?? 2026)"
    }
    
    private func navigateMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    /// Generate an array of optional Dates for the current month.
    /// nil values represent empty cells before the first day.
    private func generateDays() -> [Date?] {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        // Determine which weekday the month starts on (1 = Sunday)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Leading empty cells
        let leadingEmptyCells = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: leadingEmptyCells)
        
        for day in range {
            var dayComponents = components
            dayComponents.day = day
            if let date = calendar.date(from: dayComponents) {
                days.append(date)
            }
        }
        
        return days
    }
}

#Preview {
    CalendarView()
        .environmentObject(
            TransactionViewModel(
                context: PersistenceController.preview.container.viewContext
            )
        )
}
