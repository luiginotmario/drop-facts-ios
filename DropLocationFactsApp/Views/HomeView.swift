import SwiftUI
import MapKit

struct HomeView: View {
    @Bindable var viewModel: AppViewModel
    @State private var appeared: Bool = false
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5204, longitude: -0.1050),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                mapHeroSection
                contentSection
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            updateMapForCurrentDrop()
        }
    }

    private var mapHeroSection: some View {
        ZStack(alignment: .bottom) {
            Map(position: $mapPosition, interactionModes: []) {
                if let drop = viewModel.currentDrop {
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: drop.latitude, longitude: drop.longitude)) {
                        AvatarPinView(emoji: viewModel.selectedAvatar)
                    }
                }

                ForEach(viewModel.collection) { drop in
                    if drop.id != viewModel.currentDrop?.id {
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: drop.latitude, longitude: drop.longitude)) {
                            Circle()
                                .fill(.orange.opacity(0.6))
                                .frame(width: 10, height: 10)
                                .overlay {
                                    Circle()
                                        .stroke(.white, lineWidth: 1.5)
                                }
                        }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .frame(height: 300)

            LinearGradient(
                colors: [.clear, .clear, Color(.systemBackground).opacity(0.5), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .allowsHitTesting(false)
        }
        .frame(height: 300)
    }

    private var contentSection: some View {
        VStack(spacing: 24) {
            statsSection
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6).delay(0.1), value: appeared)

            currentDropSection
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6).delay(0.2), value: appeared)

            collectionSection
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6).delay(0.3), value: appeared)
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
                        updateMapForCurrentDrop()
                    }
                }
            }
        }
    }

    private func updateMapForCurrentDrop() {
        if let drop = viewModel.currentDrop {
            withAnimation(.easeInOut(duration: 0.6)) {
                mapPosition = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: drop.latitude, longitude: drop.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
                )
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
            ZStack(alignment: .topLeading) {
                Color(.tertiarySystemBackground)
                    .frame(height: 220)
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
                    .overlay(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.5)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .clipShape(.rect(cornerRadii: .init(topLeading: 20, topTrailing: 20)))
                        .allowsHitTesting(false)
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: drop.category.iconName)
                                    .font(.caption2)
                                Text(drop.category.rawValue)
                                    .font(.caption2.weight(.semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(.capsule)

                            Text(drop.headline)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .lineLimit(2)
                        }
                        .padding(14)
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
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

struct AvatarPinView: View {
    let emoji: String
    @State private var pulsing: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.blue.opacity(0.10))
                .frame(width: 60, height: 60)
                .scaleEffect(pulsing ? 1.4 : 1.0)
                .opacity(pulsing ? 0 : 0.4)

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.3, green: 0.7, blue: 1.0), Color(red: 0.15, green: 0.45, blue: 0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 3)
                        }
                        .shadow(color: .blue.opacity(0.35), radius: 8, y: 4)

                    Text(emoji)
                        .font(.system(size: 26))
                }

                Triangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.15, green: 0.45, blue: 0.95), Color(red: 0.1, green: 0.35, blue: 0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 16, height: 10)
                    .overlay {
                        Triangle()
                            .stroke(.white, lineWidth: 2.5)
                    }
                    .offset(y: -2)
                    .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                pulsing = true
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
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
