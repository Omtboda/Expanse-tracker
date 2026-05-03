import SwiftUI

/// Main app entry point with Core Data and ViewModel injection.
@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            let context = persistenceController.container.viewContext
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(TransactionViewModel(context: context))
        }
        #if os(macOS)
        .defaultSize(width: 800, height: 600)
        #endif
    }
}
