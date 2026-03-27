import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.chatMessages.isEmpty {
                chatEmptyState
            } else {
                messagesList
            }

            chatInputBar
        }
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var chatEmptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("Ask about your drops")
                    .font(.title3.bold())

                Text("Dive deeper into any fact.\nAsk questions, get context, explore.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let drop = viewModel.currentDrop {
                VStack(spacing: 8) {
                    Text("Current drop")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 8) {
                        Image(systemName: drop.category.iconName)
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text(drop.headline)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.capsule)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.chatMessages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isLoadingChat {
                        HStack {
                            TypingIndicator()
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .id("typing")
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: viewModel.chatMessages.count) { _, _ in
                withAnimation {
                    if let last = viewModel.chatMessages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var chatInputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask something...", text: $viewModel.chatInput, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 22))

            Button {
                viewModel.sendChatMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .disabled(viewModel.chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            Text(message.content)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isUser ? Color.blue : Color(.secondarySystemBackground))
                .foregroundStyle(message.isUser ? .white : .primary)
                .clipShape(.rect(cornerRadius: 20))

            if !message.isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 16)
    }
}

struct TypingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(.tertiaryLabel))
                    .frame(width: 7, height: 7)
                    .offset(y: phase == index ? -4 : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 20))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                phase = 2
            }
        }
    }
}
