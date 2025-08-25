import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let isStreaming: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if message.role == .user {
                userBubble
            } else {
                assistantBubble
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: message.content)
    }
    
    private var userBubble: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(message.content)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
            }
        }
    }
    
    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            // AI message content
            if message.content.isEmpty && isStreaming {
                streamingIndicator
            } else {
                Text(message.content)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
                
                if isStreaming {
                    streamingIndicator
                }
            }
            
            // Action buttons (only for non-streaming messages)
            if !message.content.isEmpty && !isStreaming {
                HStack(spacing: 16) {
                    Button {
                        copyToClipboard(message.content)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            }
                    }
                    
                    Button {
                        // Future: Text-to-speech
                    } label: {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            }
                    }
                    
                    Button {
                        // Future: Thumbs up
                    } label: {
                        Image(systemName: "hand.thumbsup")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            }
                    }
                    
                    Button {
                        // Future: Thumbs down
                    } label: {
                        Image(systemName: "hand.thumbsdown")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            }
                    }
                    
                    Button {
                        // Future: Regenerate
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            }
                    }
                    
                    Button {
                        // Future: Share
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background {
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            }
                    }
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
    }
    
    private var streamingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary.opacity(0.6))
                    .frame(width: 4, height: 4)
                    .scaleEffect(isStreaming ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: isStreaming
                    )
            }
            
            Text("Thinking...")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .opacity(0.8)
        }
        .padding(.vertical, 4)
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        Haptics.lightImpact()
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubble(
            message: ChatMessage(
                role: .assistant,
                content: "Hey! How's it going?"
            ),
            isStreaming: false
        )
        
        MessageBubble(
            message: ChatMessage(
                role: .user,
                content: "Hello"
            ),
            isStreaming: false
        )
        
        MessageBubble(
            message: ChatMessage(
                role: .assistant,
                content: ""
            ),
            isStreaming: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}