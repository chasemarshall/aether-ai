# Aether AI

A production-ready SwiftUI iOS app with ultra-minimal OLED-first design and liquid glass effects. Features Bring-Your-Own-Key support for OpenRouter with true token streaming.

**Location**: `~/Documents/aether-ai/`

## Features

- **OLED-First Design**: True black background optimized for OLED displays
- **Liquid Glass Effects**: Tasteful use of SwiftUI Material with blur and highlights
- **True Streaming**: Real-time token streaming via URLSession.bytes and SSE parsing
- **Secure Storage**: API keys stored securely in Keychain
- **Modern Architecture**: SwiftUI + MVVM with Swift Concurrency
- **Haptic Feedback**: Light impact feedback for user interactions

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0

## Architecture

### Core Components

- **LLM Providers**: Abstraction layer with OpenRouter fully implemented
- **Streaming**: SSE parsing with robust error handling
- **Security**: Keychain storage for API keys
- **UI**: Liquid glass design with perfect readability

### Project Structure

```
BYOKApp/
├── App/
│   └── BYOKApp.swift
├── Features/
│   ├── Chat/
│   │   ├── ChatView.swift
│   │   ├── ChatViewModel.swift
│   │   ├── Components/MessageBubble.swift
│   │   └── Models/ChatMessage.swift
│   └── Settings/
│       └── SettingsView.swift
├── LLM/
│   ├── Abstractions/
│   │   ├── LLMProvider.swift
│   │   ├── ModelDescriptor.swift
│   │   ├── ProviderKind.swift
│   │   ├── LLMError.swift
│   │   └── Cancellable.swift
│   ├── Providers/
│   │   ├── OpenRouterProvider.swift
│   │   ├── AnthropicProvider.swift (stub)
│   │   └── OpenAIProvider.swift (stub)
│   └── Streaming/
│       └── SSEStreamDecoder.swift
├── Platform/
│   ├── Keychain/Secrets.swift
│   ├── Networking/HTTPClient.swift
│   └── Haptics/Haptics.swift
└── Resources/
    └── Assets.xcassets
```

## Usage

1. Open the app
2. Tap the settings gear icon
3. Enter your OpenRouter API key
4. Select a model (Llama 3 70B, Qwen 2.5 7B, etc.)
5. Return to chat and start messaging

## Design Philosophy

- **Ultra-minimal**: No unnecessary UI elements
- **OLED-optimized**: True black backgrounds
- **Liquid glass**: Subtle depth without compromising readability
- **Haptic feedback**: Light touches for better UX
- **Accessibility**: High contrast, readable fonts

## Security

- API keys never logged or exposed
- Secure Keychain storage with `kSecAttrAccessibleAfterFirstUnlock`
- Keys persist across app launches
- No on-device model processing

## Streaming Implementation

- Uses `URLSession.bytes(for:)` for true streaming
- Robust SSE parsing handles partial frames
- Supports OpenAI-format delta responses
- Graceful error handling and cancellation

## Models Supported

Via OpenRouter:
- Llama 3 70B Instruct
- Qwen 2.5 7B Instruct  
- Mistral Large
- Claude 3.5 Sonnet
- GPT-4o

## License

MIT License - see LICENSE file for details.
