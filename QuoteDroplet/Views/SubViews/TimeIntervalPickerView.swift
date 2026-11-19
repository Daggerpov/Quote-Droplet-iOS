//
//  TimeIntervalPicker.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import Foundation
import SwiftUI
import WidgetKit

/// Settings row for how often the widget switches to a new quote.
@available(iOS 16.0, *)
struct TimeIntervalPicker: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @AppStorage("quoteFrequencySelected", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencySelected: QuoteFrequency = QuoteFrequency.oneDay

    private var picker: some View {
        Picker("", selection: $quoteFrequencySelected) {
            ForEach(QuoteFrequency.allCases, id: \.rawValue) { frequencyOption in
                Text("Every \(frequencyOption.displayName)")
                    .tag(frequencyOption)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .tint(sharedVars.palette.accent)
        .onChange(of: quoteFrequencySelected) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        }
    }

    var body: some View {
        SettingsRowLabel(icon: "arrow.triangle.2.circlepath", title: "New quote") {
            picker
        }
    }
}
