import XCTest
import UIKit
@testable import TravelFrames

@MainActor
final class DraftSessionTests: XCTestCase {
    func testDraftLifecycleRejectsDuplicateCreationAndResetsOnNextDraft() {
        var allocated = 0
        let identities = [
            UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        ]
        let session = DraftSession {
            allocated += 1
            return identities[allocated - 1]
        }
        XCTAssertNil(session.activeDraft)
        session.createDraft()
        let first = session.activeDraft
        session.createDraft()
        XCTAssertEqual(allocated, 1)
        XCTAssertEqual(session.activeDraft, first)
        session.selectedTool = .photos
        for size in [(375.0, 667.0), (1194.0, 834.0), (744.0, 500.0)] {
            _ = EditorPresentation.usesInspector(width: size.0, height: size.1, accessibilityText: false)
            XCTAssertEqual(session.activeDraft, first)
            XCTAssertEqual(session.selectedTool, .photos)
        }
        session.closeDraft()
        XCTAssertNil(session.activeDraft)
        session.createDraft()
        XCTAssertEqual(allocated, 2)
        XCTAssertNotEqual(session.activeDraft, first)
        XCTAssertEqual(session.selectedTool, .layout)
    }

    func testInspectorProtectsNarrowShallowAndAccessibilityLayouts() {
        XCTAssertFalse(EditorPresentation.usesInspector(width: 375, height: 667, accessibilityText: false))
        XCTAssertFalse(EditorPresentation.usesInspector(width: 744, height: 1133, accessibilityText: false))
        XCTAssertFalse(EditorPresentation.usesInspector(width: 1100, height: 400, accessibilityText: false))
        XCTAssertFalse(EditorPresentation.usesInspector(width: 1194, height: 834, accessibilityText: true))
        XCTAssertTrue(EditorPresentation.usesInspector(width: 1133, height: 744, accessibilityText: false))
    }

    func testCompiledWorkSurfacesAndAccentStayOpaqueInBothAppearances() throws {
        for appearance in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: appearance)
            for name in ["Workspace", "ToolSurface", "Canvas", "AccentColor"] {
                let color = try XCTUnwrap(UIColor(named: name)).resolvedColor(with: traits)
                XCTAssertEqual(color.cgColor.alpha, 1, accuracy: 0.001, "\(name) must remain visible")
            }
            let workspace = try XCTUnwrap(UIColor(named: "Workspace")).resolvedColor(with: traits)
            let canvas = try XCTUnwrap(UIColor(named: "Canvas")).resolvedColor(with: traits)
            XCTAssertNotEqual(workspace, canvas)
        }
    }
}
