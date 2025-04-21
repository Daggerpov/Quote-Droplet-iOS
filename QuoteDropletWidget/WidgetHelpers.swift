//
//  WidgetHelpers.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import Foundation
import SwiftUI

// Extension to disable content margins
extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOS 17.0, macCatalyst 17.0, *) {
            return contentMarginsDisabled()
        } else {
            return self
        }
    }
}
