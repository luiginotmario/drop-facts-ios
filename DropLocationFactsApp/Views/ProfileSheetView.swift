import SwiftUI

struct ProfileSheetView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation: Bool = false
    @State private var showSignOutConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.userProfile.displayName)
                                .font(.headline)
                            Text("Member since \(viewModel.userProfile.joinDate, format: .dateTime.month(.wide).year())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Stats") {
                    StatRow(icon: "flame.fill", tint: .orange, label: "Current Streak", value: "\(viewModel.userProfile.currentStreak) days")
                    StatRow(icon: "trophy.fill", tint: .yellow, label: "Longest Streak", value: "\(viewModel.userProfile.longestStreak) days")
                    StatRow(icon: "mappin.circle.fill", tint: .blue, label: "Total Drops", value: "\(viewModel.userProfile.totalDrops)")
                    StatRow(icon: "map.fill", tint: .green, label: "Locations Visited", value: "\(viewModel.userProfile.locationsVisited)")
                    StatRow(icon: "globe.americas.fill", tint: .teal, label: "World Unlocked", value: String(format: "%.5f%%", viewModel.userProfile.worldUnlocked))
                }

                Section {
                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.signOut()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need to sign in again to access your drops.")
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.deleteAccount()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all your data. This action cannot be undone.")
            }
        }
    }
}

struct StatRow: View {
    let icon: String
    let tint: Color
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
