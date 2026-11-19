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
struct QuotesSubview: View {
    @ObservedObject var viewModel: QuotesViewModel
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all

    private var palette: AppPalette { sharedVars.palette }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(text: "Widget")
                VStack(spacing: 0) {
                    quoteCategoryPickerSection
                    RowDivider()
                    TimeIntervalPicker()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
                .modifier(CardStyling(padding: 0))
                Text("The category also picks which quotes your notifications show.")
                    .font(.footnote)
                    .foregroundColor(palette.secondaryText)
                    .padding(.horizontal, 4)
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(text: "Notifications")
                notificationSection
            }
        }
        .sheet(isPresented: $viewModel.isTimePickerExpanded) {
            notificationTimePicker
                .environmentObject(sharedVars)
                .presentationDetents([.height(560), .large])
                .preferredColorScheme(palette.colorScheme)
        }
    }
}

@available(iOS 16.0, *)
extension QuotesSubview {
    public func getFormattedNotificationTime () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"  // Use "h:mm a" for 12-hour format with AM/PM
        return dateFormatter.string(from: viewModel.getNotificationTime())
    }

    private var notificationSection: some View {
        Button(action: {
            viewModel.scheduleNotificationsAction()
        }) {
            SettingsRowLabel(
                icon: "bell.badge.fill",
                title: "Daily quote notification",
                subtitle: "Every day at \(getFormattedNotificationTime())"
            ) {
                RowChevron()
            }
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
        .modifier(CardStyling(padding: 0))
    }

    private var notificationTimePicker: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(palette.hairline)
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(palette.accent)
                .frame(width: 56, height: 56)
                .background(Circle().fill(palette.accent.opacity(0.16)))
                .padding(.top, 6)
            Text("Daily Notification")
                .font(AppFont.sectionTitle)
                .foregroundColor(palette.text)
            Text("\(viewModel.notificationScheduledTimeMessage)\(getFormattedNotificationTime())")
                .font(.subheadline)
                .foregroundColor(palette.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)

            DatePicker("", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(palette.colorScheme)
                .frame(maxHeight: 150)
                .clipped()

            Spacer(minLength: 0)
            Button(action: {
                viewModel.isTimePickerExpanded.toggle()
                NotificationSchedulerService.shared.scheduleNotifications(notificationTime: viewModel.notificationTime,
                                                                          quoteCategory: quoteCategory, defaults: false)
                viewModel.fetchNotificationScheduledTimeInfo()
            }) {
                Text("Done")
            }
            .buttonStyle(PrimaryButtonStyle(palette: palette))
            .padding(.horizontal, AppMetrics.screenPadding)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.backgroundGradient.ignoresSafeArea())
        .onAppear() {
            viewModel.fetchNotificationScheduledTimeInfo()
        }
    }

    private var renderedPickerOptions: some View {
        ForEach(QuoteCategory.allCases, id: \.self) { category in
            if let categoryCount: Int = viewModel.counts[category.rawValue] {
                Text("\(category.displayName) (\(categoryCount))")
                    .tag(category)
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
        .pickerStyle(.menu)
        .labelsHidden()
        .tint(palette.accent)
        .onAppear {
            viewModel.initializeCounts()
        }
        .onChange(of: quoteCategory) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        }
    }

    private var quoteCategoryPickerSection: some View {
        SettingsRowLabel(icon: "square.grid.2x2.fill", title: "Quote category") {
            quoteCategoryPicker
        }
    }
}
