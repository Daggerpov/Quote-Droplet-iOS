//
//  AppearanceView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import Foundation

@available(iOS 16.0, *)
struct AppearanceSubview: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0

    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0

    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = defaultCustomPaletteHex[0]

    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = defaultCustomPaletteHex[1]

    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = defaultCustomPaletteHex[2]

    private var palette: AppPalette { sharedVars.palette }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            widgetPreviewSection
            fontSelector
            sampleColorSection
            customColorSection
        }
    }
}

@available(iOS 16.0, *)
extension AppearanceSubview {
    private func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
    }

    private var widgetPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Widget preview")
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(palette.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(palette.hairline, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(palette.isDark ? 0.35 : 0.14), radius: 16, x: 0, y: 8)
                VStack(spacing: 10) {
                    Text("More is lost by indecision than by wrong decision.")
                        .font(Font.custom(availableFonts[safe: selectedFontIndex] ?? "Georgia", size: 19))
                        .foregroundColor(palette.text)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .minimumScaleFactor(0.6)
                    Text("— Cicero")
                        .font(Font.custom(availableFonts[safe: selectedFontIndex] ?? "Georgia", size: 15))
                        .foregroundColor(palette.accent)
                        .lineLimit(1)
                }
                .padding(.horizontal, 26)
            }
            .frame(height: 158)
            .animation(.easeInOut(duration: 0.25), value: sharedVars.colorPaletteIndex)
        }
    }

    private var fontSelector: some View {
        SettingsRowLabel(icon: "textformat", title: "Widget font") {
            Picker("", selection: $selectedFontIndex) {
                ForEach(0..<availableFonts.count, id: \.self) { index in
                    Text(availableFonts[index])
                        .font(Font.custom(availableFonts[index], size: 16))
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(palette.accent)
            .onChange(of: selectedFontIndex) { _ in
                reloadWidgets()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
        .modifier(CardStyling(padding: 0))
    }

    private var sampleColorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Color palette")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 14) {
                ForEach(paletteDisplayOrder, id: \.self) { paletteIndex in
                    sampleColorPicker(index: paletteIndex)
                }
            }
            .modifier(CardStyling(padding: 16))
        }
    }

    private func swatch(for index: Int, size: CGFloat) -> some View {
        let swatchPalette = appPalette(index)
        let isSelected = sharedVars.colorPaletteIndex == index
        return ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(swatchPalette.background)
                .overlay(
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Aa")
                            .font(.system(size: size * 0.3, weight: .semibold, design: .serif))
                            .foregroundColor(swatchPalette.text)
                        Capsule()
                            .fill(swatchPalette.accent)
                            .frame(width: size * 0.36, height: 4)
                    }
                    .padding(10),
                    alignment: .topLeading
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? palette.accent : palette.hairline, lineWidth: isSelected ? 3 : 1)
                )
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(palette.onAccent, palette.accent)
                    .offset(x: 5, y: 5)
            }
        }
        .frame(height: size)
    }

    private func sampleColorPicker(index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                sharedVars.colorPaletteIndex = index
            }
            widgetColorPaletteIndex = index
            reloadWidgets()
        } label: {
            VStack(spacing: 6) {
                swatch(for: index, size: 70)
                Text(paletteNames[safe: index] ?? "")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(sharedVars.colorPaletteIndex == index ? palette.text : palette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("\(paletteNames[safe: index] ?? "") palette")
        .accessibilityAddTraits(sharedVars.colorPaletteIndex == index ? .isSelected : [])
    }

    private var customColorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Custom palette")
            HStack(alignment: .center, spacing: 16) {
                Button {
                    sharedVars.colorPaletteIndex = customPaletteIndex
                    widgetColorPaletteIndex = customPaletteIndex
                    reloadWidgets()
                } label: {
                    swatch(for: customPaletteIndex, size: 70)
                        .frame(width: 70)
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Custom palette")

                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { customIndex in
                        VStack(spacing: 6) {
                            customColorPicker(index: customIndex)
                            Text(["Background", "Text", "Accent"][customIndex])
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(palette.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .modifier(CardStyling(padding: 16))
            Text("Pick any three colors. Your widget and the app both use them.")
                .font(.footnote)
                .foregroundColor(palette.secondaryText)
                .padding(.horizontal, 4)
        }
    }

    private func customColorPicker(index: Int) -> some View {
        ColorPicker("",
            selection: Binding(
                get: {
                    colorPalettes[customPaletteIndex][index]
                },
                set: { newColor in

                    colorPalettes[customPaletteIndex][index] = newColor

                    if (index == 0) {
                        widgetCustomColorPaletteFirstIndex = newColor.hex
                    } else if (index == 1) {
                        widgetCustomColorPaletteSecondIndex = newColor.hex
                    } else if (index == 2) {
                        widgetCustomColorPaletteThirdIndex = newColor.hex
                    }
                    sharedVars.colorPaletteIndex = customPaletteIndex
                    widgetColorPaletteIndex = customPaletteIndex
                    reloadWidgets()
                }
            ),
            supportsOpacity: false
        )
        .labelsHidden()
        .scaleEffect(1.25)
        .frame(width: 40, height: 40)
    }
}
