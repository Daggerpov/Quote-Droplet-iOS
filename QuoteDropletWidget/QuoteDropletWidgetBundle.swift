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
        // Standard widgets (non-interactive)
        QuoteDropletWidgetSmall()
        QuoteDropletWidgetMedium()
        QuoteDropletWidgetLarge()
        QuoteDropletWidgetExtraLarge()
        
        // Interactive widgets with intents
        QuoteDropletWidgetWithIntentsMedium()
        QuoteDropletWidgetWithIntentsLarge()
        QuoteDropletWidgetWithIntentsExtraLarge()
        
        // Uncomment when LiveActivity is implemented properly
        // QuoteDropletWidgetLiveActivity()
    }
}
