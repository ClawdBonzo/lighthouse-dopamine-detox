import SwiftUI
import SwiftData

struct FocusPresetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FocusPreset.usageCount, order: .reverse) private var presets: [FocusPreset]
    @State private var showAddPreset = false
    var onSelect: ((FocusPreset) -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LHSpacing.lg) {
                    // Quick start
                    if let onSelect {
                        VStack(alignment: .leading, spacing: LHSpacing.md) {
                            Text("Quick Start")
                                .font(LHFont.headline(16))
                                .foregroundStyle(LHColor.textSecondary)

                            HStack(spacing: LHSpacing.md) {
                                quickStartButton("15m", 15)
                                quickStartButton("25m", 25)
                                quickStartButton("45m", 45)
                                quickStartButton("60m", 60)
                            }
                        }
                    }

                    // Saved presets
                    VStack(alignment: .leading, spacing: LHSpacing.md) {
                        HStack {
                            Text("Focus Presets")
                                .font(LHFont.headline(18))
                                .foregroundStyle(LHColor.textPrimary)
                            Spacer()
                            Button {
                                showAddPreset = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(LHColor.teal)
                                    .font(.system(size: 22))
                            }
                        }

                        if presets.isEmpty {
                            seedDefaultPresets()
                        }

                        ForEach(presets, id: \.id) { preset in
                            PresetCard(preset: preset) {
                                preset.usageCount += 1
                                try? modelContext.save()
                                onSelect?(preset)
                            }
                        }
                    }
                }
                .padding(.horizontal, LHSpacing.lg)
                .padding(.top, LHSpacing.md)
            }
            .scrollIndicators(.hidden)
            .background(LHColor.background)
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if onSelect != nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(LHColor.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showAddPreset) {
                AddPresetSheet()
            }
        }
    }

    private func quickStartButton(_ label: String, _ minutes: Int) -> some View {
        Button {
            let preset = FocusPreset(name: "\(minutes)-Minute Focus", durationMinutes: minutes)
            onSelect?(preset)
        } label: {
            Text(label)
                .font(LHFont.headline(15))
                .foregroundStyle(LHColor.teal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(LHColor.teal.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
        }
    }

    @discardableResult
    private func seedDefaultPresets() -> some View {
        Color.clear.onAppear {
            if presets.isEmpty {
                for preset in FocusPreset.defaultPresets {
                    modelContext.insert(preset)
                }
                try? modelContext.save()
            }
        }
    }
}

// MARK: - Preset Card

struct PresetCard: View {
    let preset: FocusPreset
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: LHSpacing.md) {
            Image(systemName: preset.iconName)
                .font(.system(size: 22))
                .foregroundStyle(Color(hex: preset.colorHex))
                .frame(width: 48, height: 48)
                .background(Color(hex: preset.colorHex).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))

            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(LHFont.headline(15))
                    .foregroundStyle(LHColor.textPrimary)
                Text(preset.formattedDuration)
                    .font(LHFont.caption(13))
                    .foregroundStyle(LHColor.textTertiary)
            }

            Spacer()

            Button(action: onStart) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(LHColor.teal)
                    .frame(width: 36, height: 36)
                    .background(LHColor.teal.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .lhCard()
    }
}

// MARK: - Add Preset Sheet

struct AddPresetSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var durationMinutes = 25
    @State private var selectedIcon = "moon.fill"
    @State private var selectedColor = "00D4AA"

    private let icons = ["moon.fill", "brain.head.profile", "book.fill", "timer", "leaf.fill", "figure.run", "music.note", "paintbrush.fill", "laptopcomputer", "cup.and.saucer.fill"]
    private let colors = ["00D4AA", "6C63FF", "FF6B6B", "FFD166", "4ADE80", "F472B6", "818CF8", "FB923C"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LHSpacing.lg) {
                    // Name
                    VStack(alignment: .leading, spacing: LHSpacing.sm) {
                        Text("Name")
                            .font(LHFont.headline(14))
                            .foregroundStyle(LHColor.textSecondary)
                        TextField("e.g. Morning Focus", text: $name)
                            .font(LHFont.body(16))
                            .foregroundStyle(LHColor.textPrimary)
                            .padding(LHSpacing.md)
                            .background(LHColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: LHRadius.md))
                    }

                    // Duration
                    VStack(spacing: LHSpacing.sm) {
                        Text("Duration: \(durationMinutes) min")
                            .font(LHFont.headline(14))
                            .foregroundStyle(LHColor.textSecondary)

                        Slider(value: Binding(
                            get: { Double(durationMinutes) },
                            set: { durationMinutes = Int($0) }
                        ), in: 5...120, step: 5)
                        .tint(Color(hex: selectedColor))
                    }

                    // Icon
                    VStack(alignment: .leading, spacing: LHSpacing.sm) {
                        Text("Icon")
                            .font(LHFont.headline(14))
                            .foregroundStyle(LHColor.textSecondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: LHSpacing.md) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColor) : LHColor.textTertiary)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.15) : LHColor.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: LHRadius.sm))
                                }
                            }
                        }
                    }

                    // Color
                    VStack(alignment: .leading, spacing: LHSpacing.sm) {
                        Text("Color")
                            .font(LHFont.headline(14))
                            .foregroundStyle(LHColor.textSecondary)

                        HStack(spacing: LHSpacing.md) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(LHSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(LHColor.background)
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(LHColor.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let preset = FocusPreset(
                            name: name.isEmpty ? "Custom Focus" : name,
                            durationMinutes: durationMinutes,
                            iconName: selectedIcon,
                            colorHex: selectedColor
                        )
                        modelContext.insert(preset)
                        try? modelContext.save()
                        dismiss()
                    }
                    .foregroundStyle(LHColor.teal)
                }
            }
        }
        .presentationDetents([.large])
    }
}
