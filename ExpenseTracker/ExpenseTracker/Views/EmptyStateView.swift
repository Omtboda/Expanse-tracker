import SwiftUI

/// Shown when no transactions exist.
struct EmptyStateView: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(.tertiary)
                .scaleEffect(animate ? 1.05 : 0.95)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: animate
                )
            
            VStack(spacing: 8) {
                Text("No Transactions Yet")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Tap + to add your first income or expense")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .onAppear { animate = true }
    }
}

#Preview {
    EmptyStateView()
}
