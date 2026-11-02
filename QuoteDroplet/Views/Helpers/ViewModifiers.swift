//
//  ViewModifiers.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import SwiftUI
import Foundation


struct DatePickerStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .datePickerStyle(WheelDatePickerStyle())
            .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
            .padding()
            .scaleEffect(1.25)
    }
}
struct QuotesPageTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            .padding()
            .frame(alignment: .center)
            .multilineTextAlignment(.center)
    }
}
struct DummyQuoteTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            .padding(.bottom, 2)
            .frame(alignment: .leading)
    }
}

struct DummyQuoteAuthorTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
            .padding(.bottom, 5)
            .frame(alignment: .trailing)
    }
}

struct MainScreenBackgroundStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
    }
}

@available(iOS 15.0, *)
struct QuoteInteractionButtonStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title)
            .scaleEffect(1)
            .foregroundStyle(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
    }
}

@available(iOS 15.0, *)
struct QuotesPageTitleStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            .padding(.bottom, 5)
    }
}

@available(iOS 15.0, *)
struct ColorPaletteTitleStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            .padding(.top, 10)
    }
}

@available(iOS 15.0, *)
struct BasePicker_OuterBackgroundStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                    )
            )
    }
}

@available(iOS 15.0, *)
struct BasePicker_TextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            .padding(.horizontal, 5)
    }
}

@available(iOS 15.0, *)
struct BasePicker_PickerStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
    }
}

@available(iOS 15.0, *)
struct ColorPickerOuterStyling: ViewModifier {
    var index: Int

    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .frame(width: 60, height: 60)
            .border(sharedVars.colorPaletteIndex == index ? Color.blue : Color.clear, width: 2)
            .cornerRadius(8)
    }
}

@available(iOS 15.0, *)
struct WidgetPreviewTextStyling: ViewModifier {
    var fontSize: CGFloat
    var selectedFontIndex: Int
    var colorPaletteIndex: Int

    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(Font.custom(availableFonts[selectedFontIndex], size: fontSize))
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[colorPaletteIndex] ?? .white)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .minimumScaleFactor(0.5)

    }
}

@available(iOS 15.0, *)
struct RoundedRectangleStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
            )
    }
}

@available(iOS 15.0, *)
struct CommunityQuotesTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            .padding(.bottom, 2)
            .frame(alignment: .leading)
    }
}


@available(iOS 15.0, *)
struct CommunityQuotesAuthorTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
            .padding(.bottom, 5)
            .frame(alignment: .trailing)
    }
}

@available(iOS 15.0, *)
struct CommunityQuotesDateTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundColor((colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white).opacity(0.8))
            .padding(.bottom, 5)
            .lineLimit(1)
            .fixedSize()
    }
}

@available(iOS 15.0, *)
struct QuotesSectionOuterStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .padding()
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
            .cornerRadius(20)
            .shadow(radius: 5)
    }
}
