import SwiftUI
import AuthenticationServices

struct OnboardingLoginView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(.blue)
                    .symbolEffect(.breathe.pulse, options: .repeat(.continuous))

                Text("Drop")
                    .font(.system(size: 44, weight: .bold))

                Text("Discover hidden stories\nwherever you go")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()

            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    viewModel.handleSignIn(result: result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 54)
                .clipShape(.rect(cornerRadius: 14))

                Text("Your data stays private and secure.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color(.systemBackground))
    }
}
