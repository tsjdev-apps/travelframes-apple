import SwiftUI

struct OverviewView: View {
    @Bindable var session: DraftSession
    @AccessibilityFocusState private var creationFocused: Bool

    private var path: Binding<[CollageDraft]> {
        Binding(
            get: { session.activeDraft.map { [$0] } ?? [] },
            set: { if $0.isEmpty { session.closeDraft() } }
        )
    }

    var body: some View {
        NavigationStack(path: path) {
            VStack(spacing: 24) {
                Spacer(minLength: 0)
                ContentUnavailableView {
                    Label("Your next story", systemImage: "rectangle.stack")
                } description: {
                    Text("Create a collage to start arranging your travel memories.")
                }
                .accessibilityIdentifier("overview")
                Spacer(minLength: 0)
                Button(action: session.createDraft) {
                    Label("New Collage", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("newCollage")
                .accessibilityFocused($creationFocused)
            }
            .padding()
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
            .background(Color("Workspace"))
            .navigationTitle("TravelFrames")
            .navigationDestination(for: CollageDraft.self) { draft in
                EditorView(session: session, draft: draft)
            }
        }
        .tint(Color("AccentColor"))
        .onChange(of: session.activeDraft) { previous, current in
            if previous != nil && current == nil { creationFocused = true }
        }
    }
}

#Preview("Empty overview · German") {
    OverviewView(session: DraftSession())
        .environment(\.locale, Locale(identifier: "de"))
}
