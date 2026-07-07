import Foundation

struct Session: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var activity: String
    var distanceMi: Double
    var minutes: Double
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), activity: String = "", distanceMi: Double = 0, minutes: Double = 0, notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.activity = activity
        self.distanceMi = distanceMi
        self.minutes = minutes
        self.notes = notes
    }
}
