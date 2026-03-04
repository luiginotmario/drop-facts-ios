import SwiftUI

struct OnboardingWidgetPreviewView: View {
    @Bindable var viewModel: AppViewModel
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Text("Your drops, always\non your Home Screen")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                widgetPreview
                    .scaleEffect(appeared ? 1 : 0.9)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(duration: 0.6, bounce: 0.3), value: appeared)

                Text("Add the Drop widget to see\nnew facts at a glance.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                viewModel.completeOnboarding()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.rect(cornerRadius: 14))
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color(.systemBackground))
        .onAppear { appeared = true }
    }

    private var widgetPreview: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                smallWidget(
                    headline: "A river flows\nbeneath you",
                    location: "Farringdon",
                    color: Color.blue.opacity(0.12)
                )
                smallWidget(
                    headline: "200M year\nold soil",
                    location: "Cotswolds",
                    color: Color.orange.opacity(0.12)
                )
            }

            mediumWidget
        }
        .padding(.horizontal, 32)
    }

    private func smallWidget(headline: String, location: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "globe.americas.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("Drop")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(headline)
                .font(.system(.subheadline, weight: .semibold))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(location)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .background(color)
        .clipShape(.rect(cornerRadius: 22))
    }

    private var mediumWidget: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "globe.americas.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("Drop")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("A spy ring operated from here")
                    .font(.system(.headline, weight: .semibold))
                    .lineLimit(2)

                Text("Bletchley, England")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Color(.tertiarySystemFill)
                .frame(width: 100)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(.quaternary)
                }
        }
        .padding(14)
        .frame(height: 160)
        .background(Color(.tertiarySystemBackground))
        .clipShape(.rect(cornerRadius: 22))
    }
}
