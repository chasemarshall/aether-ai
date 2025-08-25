import SwiftUI

@main
struct BYOKApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @State private var showSidebar = false
    
    var body: some View {
        NavigationStack {
            ChatView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showSidebar.toggle()
                        } label: {
                            Image(systemName: "sidebar.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Aether AI")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                    }
                }
        }
        .sheet(isPresented: $showSidebar) {
            SidebarView()
        }
    }
}