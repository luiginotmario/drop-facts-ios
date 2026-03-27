import Foundation

struct FactDrop: Identifiable, Hashable {
    let id: UUID
    let headline: String
    let body: String
    let locationName: String
    let imageURL: URL?
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let category: FactCategory

    init(
        id: UUID = UUID(),
        headline: String,
        body: String,
        locationName: String,
        imageURL: URL? = nil,
        latitude: Double = 0,
        longitude: Double = 0,
        timestamp: Date = Date(),
        category: FactCategory = .history
    ) {
        self.id = id
        self.headline = headline
        self.body = body
        self.locationName = locationName
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.category = category
    }
}

nonisolated enum FactCategory: String, CaseIterable, Codable, Sendable {
    case history = "History"
    case geology = "Geology"
    case culture = "Culture"
    case nature = "Nature"
    case architecture = "Architecture"
    case science = "Science"

    var iconName: String {
        switch self {
        case .history: "clock.arrow.circlepath"
        case .geology: "mountain.2"
        case .culture: "theatermasks"
        case .nature: "leaf"
        case .architecture: "building.columns"
        case .science: "atom"
        }
    }
}
