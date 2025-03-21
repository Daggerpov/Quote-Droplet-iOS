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
        QuoteDropletWidgetSmall()
        QuoteDropletWidgetWithIntentsMedium()
        QuoteDropletWidgetWithIntentsLarge()
        QuoteDropletWidgetMedium()
        QuoteDropletWidgetWithIntentsExtraLarge()
        QuoteDropletWidgetLarge()
        QuoteDropletWidgetExtraLarge()
        //        QuoteDropletWidgetLiveActivity()
    }
}
