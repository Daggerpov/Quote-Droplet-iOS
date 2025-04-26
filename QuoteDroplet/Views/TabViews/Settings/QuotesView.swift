//
//  QuotesView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import Foundation
import WidgetKit

@available(iOS 16.0, *)
struct QuotesView: View {
    @ObservedObject var viewModel: QuotesViewModel
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all

    init () {
        viewModel = QuotesViewModel(localQuotesService: LocalQuotesService(), apiService: APIService())
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                HeaderView()
                VStack{
                    Spacer()
                    quoteCategoryPickerSection
                    Spacer()
                    TimeIntervalPicker()
                    Spacer()
                    notificationSection
                    Spacer()
                }
                .padding()
            }
            .modifier(MainScreenBackgroundStyling())
        }
    }
}

@available(iOS 16.0, *)
struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuotesView()
    }
}

@available(iOS 16.0, *)
extension QuotesView {
    public func getFormattedNotificationTime () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"  // Use "h:mm a" for 12-hour format with AM/PM
        return dateFormatter.string(from: viewModel.getNotificationTime())
    }
    
    private var notificationSection: some View {
        Section {
            if viewModel.isTimePickerExpanded {
                Button(action: {
                    viewModel.isTimePickerExpanded.toggle()
                }) {
                    Text("Close")
                        .modifier(RoundedRectangleStyling())
                }
                .padding()
                .sheet(isPresented: $viewModel.isTimePickerExpanded) {
                    notificationTimePicker
                }
            } else {
                Button(action: {
                    viewModel.scheduleNotificationsAction()
                }) {
                    SubmitButtonView(text: "Schedule Notifications", imageSystemName: "calendar.badge.clock")
                }
                .padding()
            }
        }
    }
    
    private var notiTimePickerColor: some View {
        Group{ // bug arises if I don't surround with this `Group{}` 
            if (colorScheme == .light) {
                Group {
                    DatePicker("", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                        .modifier(DatePickerStyling())
                }
                .colorInvert()
                .colorMultiply(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            } else {
                Group {
                    DatePicker("", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                        .modifier(DatePickerStyling())
                }
                // here we didn't do .colorInvert(), since we're on dark mode already
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
                    "\(viewModel.notificationScheduledTimeMessage)\(String(describing: getFormattedNotificationTime))"
                )
                .modifier(QuotesPageTextStyling())

                notiTimePickerColor
                Spacer()
            }
            .onAppear() {
                viewModel.fetchNotificationScheduledTimeInfo()
            }
            .padding()
            Spacer()
            Button(action: {
                viewModel.isTimePickerExpanded.toggle()
                NotificationSchedulerService.shared.scheduleNotifications(notificationTime: viewModel.notificationTime,
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
            if let categoryCount: Int = viewModel.counts[category.rawValue] {
                let displayNameWithCount: String = "\(category.displayName) (\(categoryCount))"
                Text(displayNameWithCount)
                    .font(.headline)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            }
        }
    }

    private var quoteCategoryPicker: some View {
        Picker("", selection: $quoteCategory) {
            if viewModel.counts.isEmpty {
                Text("Loading...")
            } else {
                renderedPickerOptions
            }
        }
        .modifier(BasePicker_PickerStyling())
        .onAppear {
            viewModel.initializeCounts()
        }
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
