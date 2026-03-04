import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: AppViewModel
    @State private var appeared: Bool = false

    private let worldImages: [(url: String, size: CGFloat, x: CGFloat, y: CGFloat, rotation: Double)] = [
        ("https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400", 110, 0.12, 0.06, -6),
        ("https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=400", 90, 0.78, 0.03, 8),
        ("https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400", 100, 0.88, 0.14, -4),
        ("https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400", 85, 0.06, 0.18, 5),
        ("https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400", 95, 0.5, 0.08, -3),
        ("https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=400", 80, 0.35, 0.19, 7),
        ("https://images.unsplash.com/photo-1526129318478-62ed807ebdf9?w=400", 75, 0.7, 0.22, -5),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                contentSection
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Drop")
                    .font(.title2.bold())
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showProfileSheet = true
                } label: {
                    Image(systemName: "person.circle")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            }
        }
        .sheet(isPresented: $viewModel.showProfileSheet) {
            ProfileSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                appeared = true
            }
        }
    }

    private var heroSection: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.93, green: 0.95, blue: 1.0),
                        Color(red: 0.96, green: 0.94, blue: 0.98),
                        .white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ForEach(Array(worldImages.enumerated()), id: \.offset) { index, img in
                    FloatingImageBubble(
                        urlString: img.url,
                        size: img.size,
                        rotation: img.rotation
                    )
                    .position(
                        x: geo.size.width * img.x,
                        y: geo.size.height * img.y * 2.8
                    )
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.7).delay(Double(index) * 0.08),
                        value: appeared
                    )
                }

                LinearGradient(
                    colors: [.white.opacity(0), .white],
                    startPoint: .init(x: 0.5, y: 0.65),
                    endPoint: .bottom
                )

                VStack(spacing: 12) {
                    Spacer()

                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.blue, .blue.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.spring(response: 0.6).delay(0.3), value: appeared)

                    Text("Discover the world\nbeneath your feet")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.spring(response: 0.6).delay(0.4), value: appeared)

                    Text("\(viewModel.userProfile.totalDrops) drops collected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6).delay(0.5), value: appeared)
                }
                .padding(.bottom, 28)
            }
        }
        .frame(height: 320)

    }

    private var contentSection: some View {
        VStack(spacing: 24) {
            statsSection
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6).delay(0.5), value: appeared)

            currentDropSection
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6).delay(0.6), value: appeared)

            collectionSection
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6).delay(0.7), value: appeared)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "flame.fill",
                value: "\(viewModel.userProfile.currentStreak)",
                label: "Day Streak",
                tint: .orange
            )
            StatCard(
                icon: "mappin.circle.fill",
                value: "\(viewModel.userProfile.totalDrops)",
                label: "Drops",
                tint: .blue
            )
            StatCard(
                icon: "globe.americas.fill",
                value: String(format: "%.4f%%", viewModel.userProfile.worldUnlocked),
                label: "Unlocked",
                tint: .green
            )
        }
    }

    private var currentDropSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Latest Drop")
                    .font(.headline)
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }

            if let drop = viewModel.currentDrop {
                DropHeroCard(drop: drop)
            }
        }
    }

    private var collectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collection")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(viewModel.collection) { drop in
                    DropCollectionCard(drop: drop) {
                        viewModel.currentDrop = drop
                    }
                }
            }
        }
    }
}

struct FloatingImageBubble: View {
    let urlString: String
    let size: CGFloat
    let rotation: Double

    @State private var floating: Bool = false

    var body: some View {
        Color(.tertiarySystemBackground)
            .frame(width: size, height: size)
            .overlay {
                AsyncImage(url: URL(string: urlString)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                }
            }
            .clipShape(.rect(cornerRadius: size * 0.22))
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            .rotationEffect(.degrees(rotation))
            .offset(y: floating ? -6 : 6)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2.8...3.6))
                    .repeatForever(autoreverses: true)
                ) {
                    floating = true
                }
            }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)

            Text(value)
                .font(.system(.title3, weight: .bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }
}

struct DropHeroCard: View {
    let drop: FactDrop

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(.tertiarySystemBackground)
                .frame(height: 200)
                .overlay {
                    if let url = drop.imageURL {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .allowsHitTesting(false)
                            } else if phase.error != nil {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.quaternary)
                            } else {
                                ProgressView()
                            }
                        }
                    }
                }
                .clipShape(.rect(cornerRadii: .init(topLeading: 20, topTrailing: 20)))
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 4) {
                        Image(systemName: drop.category.iconName)
                            .font(.caption2)
                        Text(drop.category.rawValue)
                            .font(.caption2.weight(.medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(.capsule)
                    .padding(12)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(drop.headline)
                    .font(.title3.bold())

                Text(drop.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                HStack {
                    Image(systemName: "mappin")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(drop.locationName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(drop.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadii: .init(bottomLeading: 20, bottomTrailing: 20)))
        }
    }
}

struct DropCollectionCard: View {
    let drop: FactDrop
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Color(.tertiarySystemBackground)
                    .frame(height: 100)
                    .overlay {
                        if let url = drop.imageURL {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    .clipShape(.rect(cornerRadius: 12))

                Text(drop.headline)
                    .font(.footnote.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 3) {
                    Image(systemName: "mappin")
                        .font(.system(size: 9))
                    Text(drop.locationName)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
