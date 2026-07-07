import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Session] = []
    @Published var isPro: Bool = false

    static let freeLimit = 40

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("strideline_items.json")
        load()
    }

    var canAddMore: Bool { isPro || items.count < Store.freeLimit }

    func add(_ item: Session) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Session) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Session) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Session].self, from: data) {
            items = decoded
        } else {
            items = [
        Session(activity: "Run", distanceMi: 3.1, minutes: 28, notes: ""),
        Session(activity: "Walk", distanceMi: 2.0, minutes: 35, notes: "")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
