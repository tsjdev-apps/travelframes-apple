import Foundation
import Observation

struct CollageDraft: Identifiable, Hashable {
    let id: UUID
}

enum EditorTool: String, CaseIterable, Identifiable {
    case layout, photos, style
    var id: Self { self }
    var symbol: String {
        switch self {
        case .layout: "rectangle.split.2x2"
        case .photos: "photo.on.rectangle"
        case .style: "paintpalette"
        }
    }
}

@MainActor @Observable
final class DraftSession {
    private(set) var activeDraft: CollageDraft?
    var selectedTool: EditorTool = .layout
    private let makeID: () -> UUID

    init(makeID: @escaping () -> UUID = UUID.init) {
        self.makeID = makeID
    }

    func createDraft() {
        guard activeDraft == nil else { return }
        selectedTool = .layout
        activeDraft = CollageDraft(id: makeID())
    }

    func closeDraft() { activeDraft = nil }
}

enum EditorPresentation {
    static func usesInspector(width: Double, height: Double, accessibilityText: Bool) -> Bool {
        width >= 1000 && height >= 500 && !accessibilityText
    }
}
