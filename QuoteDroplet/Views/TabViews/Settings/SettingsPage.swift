//
//  SettingsPage.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 4/25/25.
//


import SwiftUI
import WidgetKit
import Foundation

enum SettingsPage {
    case appearance
    case quotes
}

@available(iOS 16.0, *)
struct SettingsView: View {
    @StateObject var quotesViewModel = QuotesViewModel(localQuotesService: LocalQuotesService(), apiService: APIService())
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @Environment(\.colorScheme) var colorScheme
    @State private var selected: SettingsPage = .appearance
    
    // Appearance variables
    @AppStorage("selectedFontIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var selectedFontIndex = 0
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    // Quotes variables
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                VStack{
                    topNavBar
                    Spacer()
                    
                    if selected == .appearance {
                        appearanceContent
                    } else {
                        quotesContent
                    }
                }
                .padding()
            }
            .modifier(MainScreenBackgroundStyling())
            .onAppear {
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
                
                quotesViewModel.fetchNotificationScheduledTimeInfo()
                quotesViewModel.initializeCounts()
            }
        }
    }
}

@available(iOS 16.0, *)
extension SettingsView {
    private var topNavBar: some View {
        Picker(selection: $selected, label: Text("Picker"), content: {
            Text("Appearance").tag(SettingsPage.appearance)
            Text("Quotes").tag(SettingsPage.quotes)
        })
        .pickerStyle(SegmentedPickerStyle())
    }
    
    // MARK: - Appearance Content
    private var appearanceContent: some View {
        VStack {
            Spacer()
            widgetPreviewSection
            Spacer()
            fontSelector
            Spacer()
            sampleColorSection
            customColorSection
            Spacer()
        }
    }
    
    private var fontSelector: some View {
        HStack {
            Text("Widget Font:")
                .modifier(BasePicker_TextStyling())
            Picker("", selection: $selectedFontIndex) {
                ForEach(0..<availableFonts.count, id: \.self) { index in
                    Text(availableFonts[index])
                        .font(Font.custom(availableFonts[index], size: 16))
                }
            }
            .modifier(BasePicker_PickerStyling())
            .onChange(of: selectedFontIndex) { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
            }
        }
        .modifier(BasePicker_OuterBackgroundStyling())
    }
    
    private var sampleColorSection: some View {
        VStack {
            Text("Sample Colors:")
                .modifier(ColorPaletteTitleStyling())
            sampleColorPickers
        }
        .frame(alignment: .center)
    }
    
    private var sampleColorPickers: some View {
        VStack{
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { paletteIndex in
                    sampleColorPicker(index: paletteIndex)
                }
                sampleColorPicker(index: 4)
            }
            HStack(spacing: 10) {
                ForEach(5..<colorPalettes.count, id: \.self) { paletteIndex in
                    sampleColorPicker(index: paletteIndex)
                }
            }
        }
    }
    
    private func sampleColorPicker(index: Int) -> some View {
        ColorPaletteView(colors: colorPalettes[safe: index] ?? [])
            .modifier(ColorPickerOuterStyling(index: index))
            .onTapGesture {
                sharedVars.colorPaletteIndex = index
                widgetColorPaletteIndex = index
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
            }
    }
    
    private var customColorSection: some View {
        VStack {
            Text("Custom Colors:")
                .modifier(ColorPaletteTitleStyling())
            customColorPickers
        }
        .frame(alignment: .center)
    }
    
    private var customColorPickers: some View {
        HStack(spacing: 10) {
            ForEach(0..<(colorPalettes.last?.count ?? 0), id: \.self) { customIndex in
                if customIndex == 2 {
                    // essentially only padding the last one
                    customColorPicker(index: customIndex)
                        .padding(.trailing, 30)
                } else {
                    customColorPicker(index: customIndex)
                }
                
            }
        }
    }
    
    private func customColorPicker(index: Int) -> some View {
        ColorPicker("",
            selection: Binding(
                get: {
                    colorPalettes[3][index]
                },
                set: { newColor in

                    colorPalettes[3][index] = newColor

                    if (index == 0) {
                        widgetCustomColorPaletteFirstIndex = newColor.hex
                    } else if (index == 1) {
                        widgetCustomColorPaletteSecondIndex = newColor.hex
                    } else if (index == 2) {
                        widgetCustomColorPaletteThirdIndex = newColor.hex
                    } else {
                        // do nothing, idk
                        widgetCustomColorPaletteFirstIndex = newColor.hex
                    }
                    sharedVars.colorPaletteIndex = 3
                    widgetColorPaletteIndex = 3
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
                }
            ),
            supportsOpacity: true
        )
        .modifier(ColorPickerOuterStyling(index: index))
        .onChange(of: colorPalettes) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        }
    }
    
    private var widgetPreviewSection: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("More is lost by indecision than by wrong decision.")
                                .modifier(WidgetPreviewTextStyling(fontSize: 16, selectedFontIndex: selectedFontIndex, colorPaletteIndex: 1))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .frame(maxHeight: .infinity)
                            
                            Text("— Cicero")
                                .modifier(WidgetPreviewTextStyling(fontSize: 14, selectedFontIndex: selectedFontIndex, colorPaletteIndex: 2))
                                .lineLimit(1)
                        }
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 0)
            }
            .frame(width: 150, height: 150)
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Quotes Content
    private var quotesContent: some View {
        VStack {
            Spacer()
            quoteCategoryPickerSection
            Spacer()
            TimeIntervalPicker()
            Spacer()
            notificationSection
            Spacer()
        }
    }
    
    public func getFormattedNotificationTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: quotesViewModel.getNotificationTime())
    }
    
    private var notificationSection: some View {
        Section {
            if quotesViewModel.isTimePickerExpanded {
                Button(action: {
                    quotesViewModel.isTimePickerExpanded.toggle()
                }) {
                    Text("Close")
                        .modifier(RoundedRectangleStyling())
                }
                .padding()
                .sheet(isPresented: $quotesViewModel.isTimePickerExpanded) {
                    notificationTimePicker
                }
            } else {
                Button(action: {
                    quotesViewModel.scheduleNotificationsAction()
                }) {
                    SubmitButtonView(text: "Schedule Notifications", imageSystemName: "calendar.badge.clock")
                }
                .padding()
            }
        }
    }
    
    private var notiTimePickerColor: some View {
        Group {
            if (colorScheme == .light) {
                Group {
                    DatePicker("", selection: $quotesViewModel.notificationTime, displayedComponents: .hourAndMinute)
                        .modifier(DatePickerStyling())
                }
                .colorInvert()
                .colorMultiply(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            } else {
                Group {
                    DatePicker("", selection: $quotesViewModel.notificationTime, displayedComponents: .hourAndMinute)
                        .modifier(DatePickerStyling())
                }
                .colorMultiply(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            }
        }
    }
    
    private var notificationTimePicker: some View {
        VStack {
            Spacer()
            
            VStack {
                Text("Daily Notification Scheduling")
                    .font(.title)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                    .multilineTextAlignment(.center)
                Spacer()
                
                Text(
                    "\(quotesViewModel.notificationScheduledTimeMessage)\(String(describing: getFormattedNotificationTime))"
                )
                .modifier(QuotesPageTextStyling())

                notiTimePickerColor
                Spacer()
            }
            .onAppear() {
                quotesViewModel.fetchNotificationScheduledTimeInfo()
            }
            .padding()
            Spacer()
            Button(action: {
                quotesViewModel.isTimePickerExpanded.toggle()
                NotificationSchedulerService.shared.scheduleNotifications(notificationTime: quotesViewModel.notificationTime,
                                                                          quoteCategory: quoteCategory, defaults: false)

            }) {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .modifier(RoundedRectangleStyling())
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 200, maxWidth: .infinity)
        .background(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
    
    private var renderedPickerOptions: some View {
        ForEach(QuoteCategory.allCases, id: \.self) { category in
            if let categoryCount: Int = quotesViewModel.counts[category.rawValue] {
                let displayNameWithCount: String = "\(category.displayName) (\(categoryCount))"
                Text(displayNameWithCount)
                    .font(.headline)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
        }
    }

    private var quoteCategoryPicker: some View {
        Picker("", selection: $quoteCategory) {
            if quotesViewModel.counts.isEmpty {
                Text("Loading...")
            } else {
                renderedPickerOptions
            }
        }
        .modifier(BasePicker_PickerStyling())
        .onTapGesture {
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        }
    }

    private var quoteCategoryPickerSection: some View {
        HStack {
            Text("Quote Category:")
                .modifier(BasePicker_TextStyling())
            quoteCategoryPicker
        }
        .modifier(BasePicker_OuterBackgroundStyling())
    }
}

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 
