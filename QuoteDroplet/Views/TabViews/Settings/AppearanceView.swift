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
struct AppearanceView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                VStack{
                    Spacer()
                    widgetPreviewSection
                    Spacer()
                    fontSelector
                    Spacer()
                    sampleColorSection
                    customColorSection
                    Spacer()
                }
                .padding()
            }
            // only main page view that doesn't have the `.frame(maxWidth: .infinity)`, so I'll keep it that way, instead of applying the `MainScreenBackgroundStyling()` modifier
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        }
    }
}

@available(iOS 16.0, *)
struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}

@available(iOS 16.0, *)
extension AppearanceView {
    private var fontSelector: some View {
        HStack {
            Text("Widget Font:")
                .modifier(BasePicker_TextStyling())
            Picker("", selection: $selectedFontIndex) {
                ForEach(0..<availableFonts.count, id: \.self) { index in
                    Text(availableFonts[index])
                        .font(Font.custom(availableFonts[index], size: 16))
                }
            }
            .modifier(BasePicker_PickerStyling())
            .onChange(of: selectedFontIndex) { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
            }
        }
        .modifier(BasePicker_OuterBackgroundStyling())
    }
    private var sampleColorSection: some View {
        VStack {
            Text("Sample Colors:")
                .modifier(ColorPaletteTitleStyling())
            sampleColorPickers
        }
        .frame(alignment: .center)
    }
    
    private var sampleColorPickers: some View {
        VStack{
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { paletteIndex in
                    sampleColorPicker(index: paletteIndex)
                }
                sampleColorPicker(index: 4)
            }
            HStack(spacing: 10) {
                ForEach(5..<colorPalettes.count, id: \.self) { paletteIndex in
                    sampleColorPicker(index: paletteIndex)
                }
            }
        }
    }
    
    private func sampleColorPicker(index: Int) -> some View {
        ColorPaletteView(colors: colorPalettes[safe: index] ?? [])
            .modifier(ColorPickerOuterStyling(index: index))
            .onTapGesture {
                sharedVars.colorPaletteIndex = index
                widgetColorPaletteIndex = index
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
            }
    }
    
    private var customColorSection: some View {
        VStack {
            Text("Custom Colors:")
                .modifier(ColorPaletteTitleStyling())
            customColorPickers
        }
        .frame(alignment: .center)
    }
    
    private var customColorPickers: some View {
        HStack(spacing: 10) {
            ForEach(0..<(colorPalettes.last?.count ?? 0), id: \.self) { customIndex in
                if customIndex == 2 {
                    // essentially only padding the last one
                    customColorPicker(index: customIndex)
                        .padding(.trailing, 30)
                } else {
                    customColorPicker(index: customIndex)
                }
                
            }
        }
    }
    
    private func customColorPicker(index: Int) -> some View {
        ColorPicker("",
            selection: Binding(
                get: {
                    colorPalettes[3][index]
                },
                set: { newColor in

                    colorPalettes[3][index] = newColor

                    if (index == 0) {
                        widgetCustomColorPaletteFirstIndex = newColor.hex
                    } else if (index == 1) {
                        widgetCustomColorPaletteSecondIndex = newColor.hex
                    } else if (index == 2) {
                        widgetCustomColorPaletteThirdIndex = newColor.hex
                    } else {
                        // do nothing, idk
                    }
                    sharedVars.colorPaletteIndex = 3
                    widgetColorPaletteIndex = 3
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
                }
            ),
            supportsOpacity: true
        )
        .modifier(ColorPickerOuterStyling(index: index))
        .onChange(of: colorPalettes) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        }
    }
    
    private var widgetPreviewSection: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("More is lost by indecision than by wrong decision.")
                                .modifier(WidgetPreviewTextStyling(fontSize: 16, selectedFontIndex: selectedFontIndex, colorPaletteIndex: 1))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .frame(maxHeight: .infinity)
                            
                            Text("— Cicero")
                                .modifier(WidgetPreviewTextStyling(fontSize: 14, selectedFontIndex: selectedFontIndex, colorPaletteIndex: 2))
                                .lineLimit(1)
                        }
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 0) // increased from black opacity of 0.2 and radius of 5
            }
            .frame(width: 150, height: 150)
        }
        .padding(.bottom, 10)
    }
}
