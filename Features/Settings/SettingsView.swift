import SwiftUI

struct SidebarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSettings = false
    @State private var searchText = ""
    @StateObject private var chatHistoryManager = ChatHistoryManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Button {
                        // Create new chat
                        chatHistoryManager.createNewChat()
                        dismiss()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            }
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("Q Search", text: $searchText)
                            .font(.system(size: 16, weight: .regular))
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                
                // Chat history
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(chatHistoryManager.chats) { chat in
                            Button {
                                // Load chat
                                chatHistoryManager.selectChat(chat)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(chat.title)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                
                Spacer()
                
                // Profile section
                VStack(spacing: 0) {
                    Divider()
                    
                    Button {
                        showSettings = true
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Text("C")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            
                            Text("chase")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// Chat History Manager
class ChatHistoryManager: ObservableObject {
    static let shared = ChatHistoryManager()
    
    @Published var chats: [ChatSession] = []
    @Published var currentChat: ChatSession?
    
    private init() {
        loadChats()
    }
    
    func createNewChat() {
        let newChat = ChatSession(
            id: UUID(),
            title: "New Chat",
            messages: [],
            createdAt: Date()
        )
        chats.insert(newChat, at: 0)
        currentChat = newChat
        saveChats()
    }
    
    func selectChat(_ chat: ChatSession) {
        currentChat = chat
    }
    
    func updateChatTitle(_ chatId: UUID, title: String) {
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            chats[index].title = title
            saveChats()
        }
    }
    
    func addMessage(_ message: ChatMessage, to chatId: UUID) {
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            chats[index].messages.append(message)
            
            // Update title if it's the first message
            if chats[index].messages.count == 1 {
                let title = String(message.content.prefix(30))
                chats[index].title = title.isEmpty ? "New Chat" : title
            }
            
            saveChats()
        }
    }
    
    private func loadChats() {
        // Load from UserDefaults or Core Data
        // For now, create a sample chat
        if chats.isEmpty {
            createNewChat()
        }
    }
    
    private func saveChats() {
        // Save to UserDefaults or Core Data
    }
}

struct ChatSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatViewModel()
    @State private var apiKey: String = ""
    @State private var showingKeyField = false
    @State private var showingModelPicker = false
    
    private let provider = OpenRouterProvider.shared
    
    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Email")
                        
                        Spacer()
                        
                        Text("chasemarshall.f@gmail.com")
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        showingKeyField = true
                    } label: {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("API Key")
                            
                            Spacer()
                            
                            if provider.isConfigured {
                                Text("Configured")
                                    .foregroundColor(.green)
                            } else {
                                Text("Add Key")
                                    .foregroundColor(.blue)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("ACCOUNT")
                }
                
                // App Section
                Section {
                    Button {
                        showingModelPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "cpu")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Model")
                            
                            Spacer()
                            
                            Text(viewModel.selectedModel?.displayName ?? "Select")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                    
                    HStack {
                        Image(systemName: "thermometer.medium")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Temperature")
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", viewModel.temperature))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "textformat.123")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Max Tokens")
                        
                        Spacer()
                        
                        Text("\(viewModel.maxTokens)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "curlybraces")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("JSON Mode")
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.jsonMode)
                            .labelsHidden()
                    }
                } header: {
                    Text("APP")
                }
                
                // About Section
                Section {
                    Link(destination: URL(string: "https://openrouter.ai")!) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("OpenRouter")
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("ABOUT")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.saveSettings()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showingKeyField) {
            apiKeySheet
        }
        .sheet(isPresented: $showingModelPicker) {
            modelPickerSheet
        }
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private var apiKeySheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Enter your OpenRouter API key")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.top)
                
                SecureField("API Key", text: $apiKey)
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                Text("Your API key is stored securely in the Keychain and never leaves your device.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if provider.isConfigured {
                    Button("Remove API Key") {
                        provider.setAPIKey("")
                        showingKeyField = false
                    }
                    .foregroundColor(.red)
                    .padding(.top)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingKeyField = false
                        apiKey = ""
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAPIKey()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var modelPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(provider.availableModels(), id: \.id) { model in
                    Button {
                        viewModel.selectedModel = model
                        showingModelPicker = false
                        Haptics.selection()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.displayName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text(model.id)
                                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if viewModel.selectedModel?.id == model.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select Model")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingModelPicker = false
                    }
                }
            }
        }
    }
    
    private func loadCurrentSettings() {
        // Settings are loaded automatically by the view model
    }
    
    private func saveAPIKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }
        
        provider.setAPIKey(trimmedKey)
        showingKeyField = false
        apiKey = ""
        Haptics.lightImpact()
    }
}

#Preview {
    SidebarView()
        .preferredColorScheme(.dark)
}