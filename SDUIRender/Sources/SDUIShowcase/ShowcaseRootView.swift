import SwiftUI
import SDUIRenderSwift

public struct ShowcaseRootView: View {

    @State private var selectedSampleId: String = ""
    @State private var selectedSection: ShowcaseSection = .layout
    @State private var jsonEditor: String = ""
    @State private var editorDirty: Bool = false
    @State private var showActions: Bool = true
    @State private var showFullScreen: Bool = true
    @State private var forceRTL: Bool = false
    @State private var navigateToPreview: Bool = false

    private var selectedSample: ShowcaseJsonSample? {
        ShowcaseJsonSample(rawValue: selectedSampleId)
    }

    /// Binding that marks the editor dirty only when the user types (not programmatic loads).
    private var jsonEditorBinding: Binding<String> {
        Binding(
            get: { jsonEditor },
            set: { newValue in
                jsonEditor = newValue
                editorDirty = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        )
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                samplePickerSection
                jsonEditorSection
                drawSection
                optionsSection
            }
            .navigationTitle("SDUI showcase")
            .navigationDestination(isPresented: $navigateToPreview) {
                if let json = previewJson {
                    ShowcasePreviewView(
                        title: selectedSample?.label ?? "Custom JSON",
                        json: json,
                        showActions: showActions,
                        showFullScreen: showFullScreen,
                        forceRTL: forceRTL
                    )
                }
            }
        }
    }

    // MARK: - Sections

    private var samplePickerSection: some View {
        Section {
            Picker("Section", selection: $selectedSection) {
                ForEach(ShowcaseSection.allCases) { section in
                    let samples = ShowcaseJsonSample.samples(for: section)
                    if !samples.isEmpty {
                        Text(section.label).tag(section)
                    }
                }
            }
            .onChange(of: selectedSection) { _, _ in
                selectedSampleId = ""
            }

            let samplesInSection = ShowcaseJsonSample.samples(for: selectedSection)
            if !samplesInSection.isEmpty {
                Picker("Sample", selection: $selectedSampleId) {
                    Text("None").tag("")
                    ForEach(samplesInSection) { sample in
                        Text(sample.label).tag(sample.id)
                    }
                }
                .onChange(of: selectedSampleId) { _, newId in
                    guard !newId.isEmpty else { return }
                    loadSelectedIntoEditor()
                }
            }

            if editorDirty {
                Text("Your custom JSON won't be replaced with new selections.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("JSON SELECTION")
        }
    }

    private var jsonEditorSection: some View {
        Section(header: Text("JSON Editor")) {
            TextEditor(text: jsonEditorBinding)
                .frame(minHeight: 160, maxHeight: 240)
                .font(.system(.footnote, design: .monospaced))
            if !jsonEditor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button("Clear JSON", role: .destructive) {
                    jsonEditor = ""
                    editorDirty = false
                }
            }
        }
    }

    private var drawSection: some View {
        Section {
            Button("Draw component") {
                navigateToPreview = true
            }
            .disabled(previewJson == nil)
        }
    }

    private var optionsSection: some View {
        Section(header: Text("Options")) {
            Toggle("Display actions received in an alert", isOn: $showActions)
            Toggle(isOn: $showFullScreen) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show in fullscreen")
                    Text(showFullScreen ? "Show as a standalone view" : "Show among other views")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Toggle("Force RTL layout", isOn: $forceRTL)
        }
    }

    // MARK: - Helpers

    private var previewJson: String? {
        let trimmed = jsonEditor.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return nil
    }

    private func loadSelectedIntoEditor() {
        guard let sample = selectedSample else { return }
        jsonEditor = sample.json   // direct @State mutation — does NOT go through jsonEditorBinding.set
        editorDirty = false
    }
}

#Preview {
    ShowcaseRootView()
}
