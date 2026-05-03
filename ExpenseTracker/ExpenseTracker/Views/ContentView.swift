import SwiftUI

/// Root view with tab navigation for Home and Calendar.
struct ContentView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .tint(.accentBlue)
    }
}

#Preview {
    ContentView()
        .environmentObject(
            TransactionViewModel(
                context: PersistenceController.preview.container.viewContext
            )
        )
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
