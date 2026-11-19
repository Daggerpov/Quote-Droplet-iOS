//
//  SettingsView.swift
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
    @State private var selected: SettingsPage = .appearance

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HeaderView(title: "Settings", subtitle: "Widget & app")
                topNavBar
                ScrollView {
                    Group {
                        if selected == .appearance {
                            AppearanceSubview()
                        } else {
                            QuotesSubview(viewModel: quotesViewModel)
                        }
                    }
                    .padding(.horizontal, AppMetrics.screenPadding)
                    .padding(.top, 6)
                    .padding(.bottom, 28)
                }
            }
            .modifier(MainScreenBackgroundStyling())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                sharedVars.reloadFromDefaults()
                quotesViewModel.fetchNotificationScheduledTimeInfo()
                quotesViewModel.initializeCounts()
            }
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onEnded { value in
                    switch(value.translation.width, value.translation.height) {
                        case (...0, -30...30): // left swipe
                            if selected == .appearance {
                                withAnimation { selected = .quotes }
                            }
                        case (0..., -30...30): // right swipe
                            if selected == .quotes {
                                withAnimation { selected = .appearance }
                            }
                        default: break
                    }
                }
            )
        }
    }
}

@available(iOS 16.0, *)
extension SettingsView {
    private var topNavBar: some View {
        PillSegmentedControl(
            options: [(SettingsPage.appearance, "Appearance"), (SettingsPage.quotes, "Quotes")],
            selection: $selected
        )
        .padding(.horizontal, AppMetrics.screenPadding)
    }
}

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SharedVarsBetweenTabs())
    }
}
