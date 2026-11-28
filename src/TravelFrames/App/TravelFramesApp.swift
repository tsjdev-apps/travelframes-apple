import SwiftUI

@main
struct TravelFramesApp: App {
    @State private var session = DraftSession()

    var body: some Scene {
        WindowGroup {
            OverviewView(session: session)
                .modifier(TestAppearance())
        }
    }
}

private struct TestAppearance: ViewModifier {
    func body(content: Content) -> some View {
        #if DEBUG
        content
            .preferredColorScheme(testColorScheme)
            .transformEnvironment(\.dynamicTypeSize) { size in
                if ProcessInfo.processInfo.arguments.contains("--ui-testing-large-text") {
                    size = .accessibility1
                }
            }
        #else
        content
        #endif
    }

    #if DEBUG
    private var testColorScheme: ColorScheme? {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--ui-testing-dark") { return .dark }
        if arguments.contains("--ui-testing-light") { return .light }
        return nil
    }
    #endif
}
