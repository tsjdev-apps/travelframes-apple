import SwiftUI

struct EditorView: View {
    @Bindable var session: DraftSession
    let draft: CollageDraft
    @State private var inspectorExpanded = true
    @Environment(\.dynamicTypeSize) private var textSize

    init(session: DraftSession, draft: CollageDraft, inspectorExpanded: Bool = true) {
        self.session = session
        self.draft = draft
        _inspectorExpanded = State(initialValue: inspectorExpanded)
    }

    var body: some View {
        GeometryReader { geometry in
            let wide = EditorPresentation.usesInspector(
                width: geometry.size.width, height: geometry.size.height,
                accessibilityText: textSize.isAccessibilitySize
            )
            Group {
                if wide {
                    HStack(spacing: 0) {
                        canvas
                        if inspectorExpanded {
                            Divider()
                            toolPanel.frame(width: 300)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        canvas
                        Divider()
                        toolPanel.frame(maxHeight: geometry.size.height * 0.48)
                    }
                }
            }
            .toolbar {
                if wide {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            inspectorExpanded.toggle()
                        } label: {
                            Label(inspectorExpanded ? "Hide tools" : "Show tools", systemImage: "sidebar.trailing")
                        }
                        .accessibilityIdentifier("toggleInspector")
                    }
                }
            }
        }
        .background(Color("Workspace"))
        .navigationTitle("New Collage")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canvas: some View {
        Color("Canvas")
            .overlay {
                ViewThatFits {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.artframe").font(.largeTitle).accessibilityHidden(true)
                        Text("Your collage starts here").font(.headline)
                        Text("Add photos in a later step.").font(.subheadline)
                    }.padding()
                    Text("Empty canvas").font(.caption).padding(8)
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay(Rectangle().stroke(.primary.opacity(0.2), lineWidth: 1))
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Empty collage canvas")
            .accessibilityValue(Text(verbatim: testDraftIdentity))
            .accessibilityIdentifier("canvas")
            .accessibilitySortPriority(2)
    }

    private var testDraftIdentity: String {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            return draft.id.uuidString
        }
        #endif
        return ""
    }

    private var toolPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top) { toolButtons }
                    VStack(alignment: .leading) { toolButtons }
                }
                Group {
                    switch session.selectedTool {
                    case .layout:
                        Text("Layout tools will appear here when templates are available.")
                    case .photos:
                        Text("Photo import is coming next. No photos have been added.")
                    case .style:
                        Text("Canvas style controls will be available in a later step.")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("toolDescription")
            }
            .padding()
        }
        .background(Color("ToolSurface"))
        .accessibilitySortPriority(1)
    }

    private var toolButtons: some View {
        ForEach(EditorTool.allCases) { tool in
            Button {
                session.selectedTool = tool
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: tool.symbol).accessibilityHidden(true)
                    Text(tool.title)
                    if session.selectedTool == tool {
                        Image(systemName: "checkmark").accessibilityHidden(true)
                    }
                }
                .frame(minWidth: 64, minHeight: 60)
                .padding(4)
            }
            .buttonStyle(.bordered)
            .tint(session.selectedTool == tool ? Color("AccentColor") : .secondary)
            .accessibilityLabel(Text(tool.title))
            .accessibilityAddTraits(session.selectedTool == tool ? .isSelected : [])
            .accessibilityIdentifier("tool.\(tool.rawValue)")
        }
    }
}

private extension EditorTool {
    var title: LocalizedStringKey {
        switch self {
        case .layout: "Layout"
        case .photos: "Photos"
        case .style: "Style"
        }
    }
}

#Preview("Narrow · German · accessibility · dark", traits: .fixedLayout(width: 375, height: 667)) {
    NavigationStack {
        EditorView(session: DraftSession(), draft: previewDraft)
    }
    .environment(\.locale, Locale(identifier: "de"))
    .environment(\.dynamicTypeSize, .accessibility1)
    .preferredColorScheme(.dark)
}

#Preview("Wide inspector", traits: .fixedLayout(width: 1194, height: 834)) {
    NavigationStack { EditorView(session: DraftSession(), draft: previewDraft) }
}

#Preview("Wide collapsed", traits: .fixedLayout(width: 1194, height: 834)) {
    NavigationStack {
        EditorView(session: DraftSession(), draft: previewDraft, inspectorExpanded: false)
    }
}

private let previewDraft = CollageDraft(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
