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
            // Wrap in a ZStack to avoid any NavigationLink related crashes
            ZStack {
                NavigationLink {
                    InfoView()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title)
                        .scaleEffect(1)
                        .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                }
                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to prevent styling issues
            }
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 55)
    }
}
