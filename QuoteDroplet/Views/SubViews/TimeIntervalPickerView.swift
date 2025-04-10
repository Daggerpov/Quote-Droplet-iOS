//
//  TimeIntervalPicker.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import Foundation
import SwiftUI
import WidgetKit

@available(iOS 15.0, *)
struct TimeIntervalPicker: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @AppStorage("quoteFrequencySelected", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencySelected: QuoteFrequency = QuoteFrequency.oneDay
    
    private var renderPickerSelections: some View {
        ForEach(QuoteFrequency.allCases, id: \.rawValue) { frequencyOption in
            Text("Every \(frequencyOption.displayName)")
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .tag(frequencyOption)
        }
    }
    
    private var headerText: some View {
        Text("Reload Widget:")
            .modifier(BasePicker_TextStyling())
    }
    
    private var picker: some View {
        Picker("", selection: $quoteFrequencySelected) {
            renderPickerSelections
        }
        .modifier(BasePicker_PickerStyling())
        .onChange(of: quoteFrequencySelected) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        }
    }

    var body: some View {
        HStack {
            headerText
            HStack {
                picker
            }
        }
        .modifier(BasePicker_OuterBackgroundStyling())
    }
}
