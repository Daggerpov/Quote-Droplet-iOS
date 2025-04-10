//
//  HeaderView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-08-01.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct HeaderView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    var body: some View {
        HStack{
            Spacer()
            // Wrap in a ZStack to avoid any NavigationLink related crashes
            ZStack {
                NavigationLink(destination: InfoView()) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title)
                        .scaleEffect(1)
                        .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                }
                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to prevent styling issues
            }
            Spacer()
        }
        
        // Note that padding definitely shouldn't be added here, but perhaps removed from Home and Quotes Views
        // * Note that now, QuotesView and CommunityView match padding, while DropletsView and AppearanceView
        // are more to the left
        .frame(height: 55)
    }
}
