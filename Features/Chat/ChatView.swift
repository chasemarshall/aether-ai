import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Chat messages
                if viewModel.messages.isEmpty {
                    emptyState
                } else {
                    chatContent
                }
                
                // Input area
                inputSection
            }
        }
        .onAppear {
            Haptics.prepare()
        }
        .overlay {
            if let errorMessage = viewModel.errorMessage {
                errorToast(errorMessage)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                // Premium icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 8) {
                    Text("How can I help you today?")
                        .font(.system(size: 28, weight: .medium, design: .default))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Ask me anything and I'll help you find the answers.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var chatContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.messages) { message in
                    MessageBubble(
                        message: message,
                        isStreaming: viewModel.isStreaming && message.id == viewModel.messages.last?.id
                    )
                    .id(message.id)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Subtle divider
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 0.5)
            
            // Input area with premium styling
            HStack(spacing: 12) {
                // Plus button with premium styling
                Button {
                    // Future: Add attachment functionality
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .fill(Color(.secondarySystemBackground))
                                .overlay {
                                    Circle()
                                        .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                                }
                        }
                }
                
                // Premium pill-shaped input
                HStack(spacing: 8) {
                    TextField("Ask anything", text: $viewModel.input)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .textFieldStyle(.plain)
                        .focused($isInputFocused)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                    
                    if !viewModel.input.isEmpty {
                        Button {
                            viewModel.input = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Premium send button
                    Button {
                        if viewModel.isStreaming {
                            viewModel.stop()
                        } else {
                            viewModel.send()
                            isInputFocused = false
                        }
                    } label: {
                        Image(systemName: viewModel.isStreaming ? "stop.fill" : "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background {
                                Circle()
                                    .fill(
                                        canSend ? 
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) : 
                                        LinearGradient(
                                            colors: [Color(.systemGray4), Color(.systemGray4).opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: canSend ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                            }
                    }
                    .disabled(!canSend && !viewModel.isStreaming)
                    .animation(.easeInOut(duration: 0.15), value: viewModel.isStreaming)
                    .animation(.easeInOut(duration: 0.15), value: canSend)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(Color(.secondarySystemBackground))
                        .overlay {
                            Capsule()
                                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: -5)
        )
    }
    
    private var canSend: Bool {
        !viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func errorToast(_ message: String) -> some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Retry") {
                    viewModel.retry()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.blue)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
    .preferredColorScheme(.dark)
}