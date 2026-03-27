import SwiftUI
import AuthenticationServices

struct OnboardingLoginView: View {
    @Bindable var viewModel: AppViewModel
    @State private var appeared: Bool = false

    private let photos: [(url: String, span: (Int, Int))] = [
        ("https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400", (1, 2)),
        ("https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400", (1, 1)),
        ("https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400", (1, 1)),
        ("https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=400", (1, 1)),
        ("https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=400", (1, 2)),
        ("https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400", (1, 1)),
        ("https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400", (1, 1)),
        ("https://images.unsplash.com/photo-1526129318478-62ed807ebdf9?w=400", (1, 1)),
        ("https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400", (1, 1)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            photoMosaic
                .frame(height: 420)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.white.opacity(0), .white.opacity(0.6), .white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                }

            Spacer().frame(height: 8)

            VStack(spacing: 8) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.5), value: appeared)

                Text("Drop")
                    .font(.system(size: 38, weight: .bold))
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.55), value: appeared)

                Text("Discover random facts\nwherever you go")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.6), value: appeared)
            }

            Spacer()

            VStack(spacing: 12) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    viewModel.handleSignIn(result: result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 54)
                .clipShape(.rect(cornerRadius: 14))

                Button {
                    viewModel.continueAsGuest()
                } label: {
                    Text("Continue as guest")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }

                Text("Your data stays private and secure.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6).delay(0.7), value: appeared)
        }
        .background(.white)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }

    private var photoMosaic: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 6
            let columns = 3
            let cellWidth = (geo.size.width - spacing * CGFloat(columns + 1)) / CGFloat(columns)

            ScrollView(.vertical, showsIndicators: false) {
                mosaicGrid(cellWidth: cellWidth, spacing: spacing)
                    .padding(spacing)
            }
            .scrollDisabled(true)
            .allowsHitTesting(false)
        }
    }

    private func mosaicGrid(cellWidth: CGFloat, spacing: CGFloat) -> some View {
        let tallHeight = cellWidth * 1.5
        let shortHeight = cellWidth * 0.9

        return VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                mosaicTile(urlString: photos[0].url, width: cellWidth, height: tallHeight, index: 0)
                VStack(spacing: spacing) {
                    mosaicTile(urlString: photos[1].url, width: cellWidth, height: (tallHeight - spacing) * 0.55, index: 1)
                    mosaicTile(urlString: photos[2].url, width: cellWidth, height: (tallHeight - spacing) * 0.45, index: 2)
                }
                mosaicTile(urlString: photos[3].url, width: cellWidth, height: tallHeight, index: 3)
            }

            HStack(spacing: spacing) {
                mosaicTile(urlString: photos[4].url, width: cellWidth, height: shortHeight, index: 4)
                mosaicTile(urlString: photos[5].url, width: cellWidth, height: shortHeight, index: 5)
                mosaicTile(urlString: photos[6].url, width: cellWidth, height: shortHeight, index: 6)
            }

            HStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    mosaicTile(urlString: photos[7].url, width: cellWidth, height: (tallHeight - spacing) * 0.45, index: 7)
                    mosaicTile(urlString: photos[8].url, width: cellWidth, height: (tallHeight - spacing) * 0.55, index: 8)
                }
                mosaicTile(urlString: photos[0].url, width: cellWidth, height: tallHeight, index: 9)
                mosaicTile(urlString: photos[3].url, width: cellWidth, height: tallHeight, index: 10)
            }
        }
    }

    private func mosaicTile(urlString: String, width: CGFloat, height: CGFloat, index: Int) -> some View {
        Color(red: 0.93, green: 0.95, blue: 0.97)
            .frame(width: width, height: height)
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
            .clipShape(.rect(cornerRadius: 12))
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.85)
            .animation(
                .spring(response: 0.7, dampingFraction: 0.75).delay(Double(index) * 0.05),
                value: appeared
            )
    }
}
