import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    @AppStorage("strideline_notifyEnabled") private var notifyEnabled = true
    @AppStorage("strideline_compactView") private var compactView = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Reminders", isOn: $notifyEnabled)
                    Toggle("Compact list view", isOn: $compactView)
                }
                Section("Pro") {
                    if purchases.isPro {
                        Label("Strideline Pro active", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button("Upgrade to Strideline Pro") {
                            dismiss()
                        }
                        .accessibilityIdentifier("upgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restoreButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/strideline-app/privacy.html")!)
                    Text("Version 1.0")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("doneButton")
                }
            }
        }
    }
}
