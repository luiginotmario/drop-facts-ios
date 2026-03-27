import Foundation

struct UserProfile {
    var displayName: String
    var email: String
    var totalDrops: Int
    var locationsVisited: Int
    var currentStreak: Int
    var longestStreak: Int
    var worldUnlocked: Double
    var joinDate: Date

    static let empty = UserProfile(
        displayName: "",
        email: "",
        totalDrops: 0,
        locationsVisited: 0,
        currentStreak: 0,
        longestStreak: 0,
        worldUnlocked: 0,
        joinDate: Date()
    )

    static let preview = UserProfile(
        displayName: "Alex",
        email: "alex@icloud.com",
        totalDrops: 47,
        locationsVisited: 12,
        currentStreak: 5,
        longestStreak: 14,
        worldUnlocked: 0.00012,
        joinDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
    )
}
