//
//  SubmitButtonView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

import SwiftUI

/// Label for the app's call-to-action buttons: filled with the accent (primary) or a card (secondary).
@available(iOS 15.0, *)
struct SubmitButtonView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var text: String
    var imageSystemName: String
    var isPrimary: Bool = true

    var body: some View {
        let palette = sharedVars.palette
        HStack(spacing: 8) {
            Image(systemName: imageSystemName)
                .font(.system(size: 16, weight: .semibold))
            Text(text)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(isPrimary ? palette.onAccent : palette.text)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                .fill(isPrimary ? palette.accent : palette.raised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                .stroke(isPrimary ? Color.clear : palette.hairline, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}
