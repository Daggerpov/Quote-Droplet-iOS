//
//  LinkImageBuilder.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
@ViewBuilder func buildLinkImage (urlForImage: String, imageName: String, widthSpecified: CGFloat? = 34) -> some View {
    if let url: URL = URL(string: urlForImage) {
        Link(destination: url) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: widthSpecified, height: 34)
                .frame(width: 54, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
        }
    }
}
