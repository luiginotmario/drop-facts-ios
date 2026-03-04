import SwiftUI

struct ProfileSheetView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation: Bool = false
    @State private var showSignOutConfirmation: Bool = false
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    .blue.opacity(0.15), .purple.opacity(0.1), .blue.opacity(0.08),
                    .cyan.opacity(0.1), .white, .purple.opacity(0.08),
                    .blue.opacity(0.05), .cyan.opacity(0.1), .blue.opacity(0.12)
                ]
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.05), value: appeared)

                    avatarPickerSection
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.12), value: appeared)

                    statsGrid
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.2), value: appeared)

                    achievementRow
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.3), value: appeared)

                    actionButtons
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.4), value: appeared)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, 20)
            .padding(.top, 16)
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
            Text("This will permanently delete your account and all your data.")
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            AsyncImage(url: viewModel.selectedAvatarURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 88, height: 88)
                        .overlay {
                            Image(systemName: "face.smiling.inverse")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .frame(width: 88, height: 88)

            VStack(spacing: 4) {
                Text(viewModel.userProfile.displayName)
                    .font(.title2.bold())

                Text("Exploring since \(viewModel.userProfile.joinDate, format: .dateTime.month(.wide).year())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }

    private var avatarPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Your Avatar")
                .font(.headline)
                .padding(.leading, 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(Array(AppViewModel.avatarOptions.enumerated()), id: \.offset) { index, avatar in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectAvatar(at: index)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            AsyncImage(url: URL(string: avatar.imageURL)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Circle()
                                        .fill(Color(.tertiarySystemFill))
                                        .overlay {
                                            ProgressView()
                                                .scaleEffect(0.6)
                                        }
                                }
                            }
                            .frame(width: 54, height: 54)
                            .background(
                                viewModel.selectedAvatarIndex == index
                                    ? .blue.opacity(0.1)
                                    : Color.clear
                            )
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(
                                        viewModel.selectedAvatarIndex == index ? .blue : .clear,
                                        lineWidth: 2.5
                                    )
                            }

                            Text(avatar.label)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(
                                    viewModel.selectedAvatarIndex == index ? .primary : .secondary
                                )
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: viewModel.selectedAvatarIndex)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ProfileStatBubble(
                icon: "flame.fill",
                value: "\(viewModel.userProfile.currentStreak)",
                label: "Day Streak",
                tint: .orange
            )
            ProfileStatBubble(
                icon: "trophy.fill",
                value: "\(viewModel.userProfile.longestStreak)",
                label: "Best Streak",
                tint: .yellow
            )
            ProfileStatBubble(
                icon: "mappin.circle.fill",
                value: "\(viewModel.userProfile.totalDrops)",
                label: "Total Drops",
                tint: .blue
            )
            ProfileStatBubble(
                icon: "globe.americas.fill",
                value: String(format: "%.4f%%", viewModel.userProfile.worldUnlocked),
                label: "World Unlocked",
                tint: .teal
            )
        }
    }

    private var achievementRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AchievementBadge(icon: "star.fill", title: "First Drop", unlocked: viewModel.userProfile.totalDrops > 0)
                    AchievementBadge(icon: "flame.fill", title: "5 Day Streak", unlocked: viewModel.userProfile.longestStreak >= 5)
                    AchievementBadge(icon: "map.fill", title: "10 Places", unlocked: viewModel.userProfile.locationsVisited >= 10)
                    AchievementBadge(icon: "sparkles", title: "Explorer", unlocked: viewModel.userProfile.totalDrops >= 25)
                    AchievementBadge(icon: "globe.europe.africa.fill", title: "Globetrotter", unlocked: false)
                }
            }
            .contentMargins(.horizontal, 4)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                showSignOutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 14))
            }
            .foregroundStyle(.primary)

            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Account")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.red.opacity(0.08))
                .clipShape(.rect(cornerRadius: 14))
            }
            .foregroundStyle(.red)
        }
    }
}

struct ProfileStatBubble: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)

            Text(value)
                .font(.system(.title3, weight: .bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(unlocked ? .blue.opacity(0.12) : Color(.tertiarySystemFill))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(unlocked ? .blue : Color.gray.opacity(0.3))
            }

            Text(title)
                .font(.caption2)
                .foregroundStyle(unlocked ? .primary : .tertiary)
                .lineLimit(1)
        }
        .frame(width: 72)
        .opacity(unlocked ? 1 : 0.5)
    }
}
