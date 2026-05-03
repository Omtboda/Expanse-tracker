import CoreData
// CLOUDKIT_ENABLED: Uncomment the line below when ready to enable CloudKit sync
// import CloudKit

/// Manages Core Data persistence stack.
/// To re-enable CloudKit sync:
///   1. Uncomment all lines marked with "CLOUDKIT_ENABLED"
///   2. Change NSPersistentContainer → NSPersistentCloudKitContainer
///   3. Re-add the entitlements in Xcode (Signing & Capabilities → + iCloud → CloudKit)
///   4. Set your CloudKit container identifier
struct PersistenceController {
    
    // MARK: - Shared Instance
    
    static let shared = PersistenceController()
    
    // MARK: - Preview Instance (in-memory)
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Seed sample data for previews
        let calendar = Calendar.current
        let today = Date()
        
        let sampleData: [(String, Double, Bool, Int)] = [
            ("Salary", 50000, true, 0),
            ("Groceries", 2500, false, 0),
            ("Freelance Work", 15000, true, -1),
            ("Electricity Bill", 1800, false, -2),
            ("Restaurant", 1200, false, -3),
            ("Uber", 350, false, -5),
            ("Domain Renewal", 800, false, -10),
            ("Poker Money", 4000, true, -15),
            ("Pizza", 500, false, -20),
            ("Coffee", 150, false, -22),
        ]
        
        for (index, item) in sampleData.enumerated() {
            let transaction = TransactionItem(context: viewContext)
            transaction.id = UUID()
            transaction.title = item.0
            transaction.amount = item.1
            transaction.isIncome = item.2
            transaction.category = item.2 ? "Income" : "Expense"
            transaction.date = calendar.date(byAdding: .day, value: item.3, to: today) ?? today
            transaction.createdAt = Date().addingTimeInterval(TimeInterval(-index))
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // MARK: - Container
    
    // CLOUDKIT_ENABLED: Change NSPersistentContainer → NSPersistentCloudKitContainer
    let container: NSPersistentContainer
    
    // MARK: - Init
    
    init(inMemory: Bool = false) {
        // CLOUDKIT_ENABLED: Change NSPersistentContainer → NSPersistentCloudKitContainer
        container = NSPersistentContainer(name: "ExpenseTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // CLOUDKIT_ENABLED: Uncomment the block below to configure CloudKit sync
        /*
        else {
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("Failed to retrieve a persistent store description.")
            }
            
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            // Set your own CloudKit container identifier here
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.expensetracker.app"
            )
        }
        */
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try? container.viewContext.setQueryGenerationFrom(.current)
    }
}
