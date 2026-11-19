//
//  HeaderView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-08-01.
//

import Foundation
import SwiftUI

/// Title row of a tab; its droplet button opens App Info (the old ☰ button).
@available(iOS 16.0, *)
struct HeaderView: View {
    var title: String
    var subtitle: String? = nil

    var body: some View {
        ScreenHeader(title: title, subtitle: subtitle)
    }
}
