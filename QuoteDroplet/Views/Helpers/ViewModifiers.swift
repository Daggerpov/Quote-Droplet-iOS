//
//  ViewModifiers.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//
//  The app's small design system. Everything takes its colors from the selected palette
//  (`sharedVars.palette`): screens use the background gradient, content sits on cards,
//  quotes are set in the serif face and the accent marks authors, selection and actions.
//

import SwiftUI
import Foundation

enum AppFont {
    static let quote = Font.system(.title3, design: .serif)
    static let quoteLarge = Font.system(.title2, design: .serif)
    static let author = Font.subheadline.weight(.semibold)
    static let screenTitle = Font.system(size: 34, weight: .bold, design: .serif)
    static let sectionTitle = Font.system(.title3, design: .serif).weight(.semibold)
    static let eyebrow = Font.caption.weight(.semibold)
}

enum AppMetrics {
    static let cardRadius: CGFloat = 22
    static let controlRadius: CGFloat = 16
    static let screenPadding: CGFloat = 20
}

// MARK: - Screen background

/// Fills the screen with the palette's background gradient and tints controls with the accent.
struct MainScreenBackgroundStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        let palette = sharedVars.palette
        content
            // Keeps cards a readable width on iPad
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(palette.backgroundGradient.ignoresSafeArea())
            .tint(palette.accent)
    }
}

@available(iOS 16.0, *)
struct TabBarStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        let palette = sharedVars.palette
        content
            .toolbarBackground(palette.background.mixed(with: .black, amount: palette.isDark ? 0.22 : 0.06), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(palette.colorScheme, for: .tabBar)
    }
}

// MARK: - Cards

/// The rounded surface every quote and settings group sits on.
struct CardStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var padding: CGFloat = 18
    func body(content: Content) -> some View {
        let palette = sharedVars.palette
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .fill(palette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .stroke(palette.hairline, lineWidth: 1)
            )
            .shadow(color: palette.shadow, radius: 14, x: 0, y: 6)
    }
}

/// Kept under its old name: quote sections are cards now.
struct QuotesSectionOuterStyling: ViewModifier {
    func body(content: Content) -> some View {
        content.modifier(CardStyling())
    }
}

// MARK: - Text

struct QuotesPageTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(sharedVars.palette.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
    }
}

struct QuoteTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var font: Font = AppFont.quote
    func body(content: Content) -> some View {
        content
            .font(font)
            .lineSpacing(4)
            .foregroundColor(sharedVars.palette.text)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct AuthorTextStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    // Long attributions (e.g. "Lord Krishna, Bhagavad Gita") wrap instead of being cut off
    var alignment: TextAlignment = .trailing
    func body(content: Content) -> some View {
        content
            .font(AppFont.author)
            .foregroundColor(sharedVars.palette.accent)
            .lineLimit(3)
            .multilineTextAlignment(alignment)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// Small uppercase label above a group of settings or a list.
struct SectionLabel: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var text: String
    var body: some View {
        Text(text.uppercased())
            .font(AppFont.eyebrow)
            .tracking(1.2)
            .foregroundColor(sharedVars.palette.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}

// MARK: - Header

/// The title row at the top of each tab, with the button that opens App Info.
@available(iOS 16.0, *)
struct ScreenHeader: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var title: String
    var subtitle: String? = nil
    var showsInfoButton: Bool = true

    var body: some View {
        let palette = sharedVars.palette
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                if let subtitle {
                    Text(subtitle.uppercased())
                        .font(AppFont.eyebrow)
                        .tracking(1.4)
                        .foregroundColor(palette.accent)
                }
                Text(title)
                    .font(AppFont.screenTitle)
                    .foregroundColor(palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            if showsInfoButton {
                NavigationLink {
                    InfoView()
                } label: {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(palette.accent)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(palette.card))
                        .overlay(Circle().stroke(palette.hairline, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("App info")
            }
        }
        .padding(.horizontal, AppMetrics.screenPadding)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    var palette: AppPalette
    var fullWidth: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(palette.onAccent)
            .padding(.vertical, 15)
            .padding(.horizontal, 22)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                    .fill(palette.accent)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var palette: AppPalette
    var fullWidth: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(palette.text)
            .padding(.vertical, 15)
            .padding(.horizontal, 22)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                    .fill(palette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                    .stroke(palette.hairline, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Fades and shrinks slightly while pressed; for icon buttons and rows.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Segmented control

/// A pill-shaped segmented control in the palette's colors (the system one is gray on every palette).
@available(iOS 16.0, *)
struct PillSegmentedControl<Value: Hashable>: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var options: [(value: Value, title: String)]
    @Binding var selection: Value
    @Namespace private var pill

    var body: some View {
        let palette = sharedVars.palette
        HStack(spacing: 4) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                let isSelected = option.value == selection
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        selection = option.value
                    }
                } label: {
                    Text(option.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isSelected ? palette.onAccent : palette.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(palette.accent)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(palette.card))
        .overlay(Capsule().stroke(palette.hairline, lineWidth: 1))
    }
}

// MARK: - Chips

@available(iOS 16.0, *)
struct ChipLabel: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var title: String
    var isSelected: Bool

    var body: some View {
        let palette = sharedVars.palette
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(isSelected ? palette.onAccent : palette.text)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Capsule().fill(isSelected ? palette.accent : palette.card))
            .overlay(Capsule().stroke(isSelected ? Color.clear : palette.hairline, lineWidth: 1))
    }
}

/// A horizontally scrolling row of category chips.
@available(iOS 16.0, *)
struct CategoryChips: View {
    var categories: [QuoteCategory]
    @Binding var selection: QuoteCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selection = category
                        }
                    } label: {
                        ChipLabel(title: category.displayName, isSelected: selection == category)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, AppMetrics.screenPadding)
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Settings rows

/// An icon tile + title row, used inside settings and info cards.
@available(iOS 16.0, *)
struct SettingsRowLabel<Trailing: View>: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var icon: String
    var title: String
    var subtitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        let palette = sharedVars.palette
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(palette.accent)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(palette.accent.opacity(0.16))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(palette.text)
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(palette.secondaryText)
                }
            }
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

@available(iOS 16.0, *)
extension SettingsRowLabel where Trailing == EmptyView {
    init(icon: String, title: String, subtitle: String? = nil) {
        self.init(icon: icon, title: title, subtitle: subtitle, trailing: { EmptyView() })
    }
}

struct RowDivider: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var body: some View {
        Rectangle()
            .fill(sharedVars.palette.hairline)
            .frame(height: 1)
            .padding(.leading, 48)
    }
}

/// The chevron at the end of a row that navigates or opens something.
struct RowChevron: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    var systemName: String = "chevron.right"
    var body: some View {
        Image(systemName: systemName)
            .font(.footnote.weight(.semibold))
            .foregroundColor(sharedVars.palette.secondaryText)
    }
}

// MARK: - Forms in sheets

/// Themes a Form (submit a quote, feedback) to the palette instead of system gray.
@available(iOS 16.0, *)
struct PaletteFormStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        let palette = sharedVars.palette
        content
            .scrollContentBackground(.hidden)
            .background(palette.backgroundGradient.ignoresSafeArea())
            .tint(palette.accent)
            .foregroundColor(palette.text)
    }
}

@available(iOS 16.0, *)
struct PaletteFormRowStyling: ViewModifier {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    func body(content: Content) -> some View {
        content.listRowBackground(sharedVars.palette.card)
    }
}
