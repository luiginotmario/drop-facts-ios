import SwiftUI
import AuthenticationServices

@Observable
final class AppViewModel {
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool = false
    var userProfile: UserProfile = .preview
    var currentDrop: FactDrop? = nil
    var collection: [FactDrop] = []
    var chatMessages: [ChatMessage] = []
    var chatInput: String = ""
    var isLoadingChat: Bool = false
    var showProfileSheet: Bool = false

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if isAuthenticated {
            loadSampleData()
        }
    }

    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let name = [credential.fullName?.givenName, credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                userProfile.displayName = name.isEmpty ? "Explorer" : name
                userProfile.email = credential.email ?? ""
            }
            isAuthenticated = true
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            loadSampleData()
        case .failure:
            break
        }
    }

    func continueAsGuest() {
        userProfile.displayName = "Explorer"
        isAuthenticated = true
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        loadSampleData()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func signOut() {
        isAuthenticated = false
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        collection = []
        chatMessages = []
        currentDrop = nil
    }

    func deleteAccount() {
        signOut()
    }

    func sendChatMessage() {
        let text = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        chatMessages.append(ChatMessage(content: text, isUser: true))
        chatInput = ""
        isLoadingChat = true

        Task {
            try? await Task.sleep(for: .seconds(1.2))
            let response = generateChatResponse(for: text)
            chatMessages.append(ChatMessage(content: response, isUser: false))
            isLoadingChat = false
        }
    }

    private func generateChatResponse(for query: String) -> String {
        guard let drop = currentDrop else {
            return "Select a drop first, then ask me anything about it."
        }
        return "Great question about \(drop.locationName)! \(drop.body) There's actually much more to discover about this area — the history here goes back centuries."
    }

    private func loadSampleData() {
        let drops = [
            FactDrop(
                headline: "A river flows beneath you",
                body: "The Fleet River, one of London's largest subterranean rivers, runs directly beneath this street. Enclosed in the 18th century, it now serves as part of the city's sewer system, hidden from the millions who walk above it daily.",
                locationName: "Farringdon, London",
                imageURL: URL(string: "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800"),
                latitude: 51.5204,
                longitude: -0.1050,
                category: .history
            ),
            FactDrop(
                headline: "This soil is 200 million years old",
                body: "The ground beneath your feet contains Jurassic-era limestone formations. These rocks formed when this entire region was submerged under a shallow tropical sea, teeming with ammonites and marine reptiles.",
                locationName: "Cotswolds, England",
                imageURL: URL(string: "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800"),
                latitude: 51.8330,
                longitude: -1.8433,
                category: .geology
            ),
            FactDrop(
                headline: "A spy ring operated from here",
                body: "During World War II, this quiet neighborhood housed a covert intelligence operation. Agents would pass encrypted messages through a network of seemingly ordinary shops and cafés, helping turn the tide of the war.",
                locationName: "Bletchley, England",
                imageURL: URL(string: "https://images.unsplash.com/photo-1548092372-0d1bd40894a3?w=800"),
                latitude: 51.9935,
                longitude: -0.7313,
                category: .history
            ),
            FactDrop(
                headline: "Trees here communicate underground",
                body: "The ancient woodland surrounding this area contains a vast mycorrhizal network — a fungal internet connecting tree roots. Trees share nutrients and chemical warning signals through this underground web, protecting the entire forest ecosystem.",
                locationName: "Epping Forest",
                imageURL: URL(string: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800"),
                latitude: 51.6500,
                longitude: 0.0500,
                category: .nature
            ),
            FactDrop(
                headline: "This building defied physics",
                body: "The architects of this structure used a revolutionary cantilever system that was considered impossible at the time. The building extends 12 meters beyond its support base, appearing to float in mid-air — a feat of engineering that still impresses today.",
                locationName: "South Bank, London",
                imageURL: URL(string: "https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800"),
                latitude: 51.5074,
                longitude: -0.1160,
                category: .architecture
            ),
        ]

        collection = drops
        currentDrop = drops.first
        userProfile.totalDrops = drops.count
        userProfile.locationsVisited = drops.count
        userProfile.currentStreak = 5
    }
}
