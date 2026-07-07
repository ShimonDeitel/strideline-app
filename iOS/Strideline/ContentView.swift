import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Session?

    @State private var draftActivity: String = ""
    @State private var draftDistancemi: String = ""
    @State private var draftMinutes: String = ""
    @State private var draftNotes: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            SessionRow(item: item)
                                .listRowBackground(Theme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                    loadDraft(from: item)
                                    showingAdd = true
                                }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Strideline")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            editingItem = nil
                            clearDraft()
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                addEditSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .tint(Theme.accent)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No sessions yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to add your first entry.")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var addEditSheet: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Activity", text: $draftActivity)
                        .accessibilityIdentifier("field_activity")
                        .keyboardType(default)
                    TextField("Distance (mi)", text: $draftDistancemi)
                        .accessibilityIdentifier("field_distanceMi")
                        .keyboardType(decimalPad)
                    TextField("Minutes", text: $draftMinutes)
                        .accessibilityIdentifier("field_minutes")
                        .keyboardType(decimalPad)
                    TextField("Notes", text: $draftNotes)
                        .accessibilityIdentifier("field_notes")
                        .keyboardType(default)
                }
            }
            .navigationTitle(editingItem == nil ? "Add Session" : "Edit Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAdd = false }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func loadDraft(from item: Session) {
        draftActivity = item.activity
        draftDistancemi = String(item.distanceMi)
        draftMinutes = String(item.minutes)
        draftNotes = item.notes
    }

    private func clearDraft() {
        draftActivity = ""
        draftDistancemi = ""
        draftMinutes = ""
        draftNotes = ""
    }

    private func save() {
        if let editing = editingItem {
            var updated = editing
            updated.activity = draftActivity
            updated.distanceMi = Double(draftDistancemi) ?? 0
            updated.minutes = Double(draftMinutes) ?? 0
            updated.notes = draftNotes
            store.update(updated)
        } else {
            let item = Session(activity: draftActivity, distanceMi: Double(draftDistancemi) ?? 0, minutes: Double(draftMinutes) ?? 0, notes: draftNotes)
            store.add(item)
        }
        showingAdd = false
    }
}

struct SessionRow: View {
    let item: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.activity.isEmpty ? "Untitled" : item.activity)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text(item.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
