//
//  QuoteDropletWidgetBundle.swift
//  QuoteDropletWidget
//
//  Created by Daniel Agapov on 2023-08-30.
//

import WidgetKit
import SwiftUI

@available(iOS 16.0, *)
@main
struct QuoteDropletWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Standard widget (non-interactive), all sizes
        QuoteDropletStandardWidget()
        
        // Interactive widget with intents
        QuoteDropletWidgetWithIntents()
        
        // Uncomment when LiveActivity is implemented properly
        // QuoteDropletWidgetLiveActivity()
    }
}
