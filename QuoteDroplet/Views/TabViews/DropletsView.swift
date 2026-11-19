//
//  DropletsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-05-18.
//
import SwiftUI

@available(iOS 16.0, *)
struct DropletsView: View {
    @StateObject var viewModel: DropletsViewModel = DropletsViewModel(
        localQuotesService: LocalQuotesService(),
        apiService: APIService()
    )

    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HeaderView(title: "Droplets", subtitle: Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                topNavBar
                quotesListView
            }
            .modifier(MainScreenBackgroundStyling())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                // Fetch initial quotes when the view appears
                viewModel.loadInitialQuotes()
                // ------------------------------------------

                sharedVars.reloadFromDefaults()

                // Schedule notifications:
                // will schedule with previous date and category values
                NotificationSchedulerService.shared.scheduleNotifications()
            }
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onEnded { value in
                    switch(value.translation.width, value.translation.height) {
                        case (...0, -30...30): // left swipe
                            if viewModel.selected == .feed {
                                viewModel.setSelected(newValue: .saved)
                            } else if viewModel.selected == .saved {
                                viewModel.setSelected(newValue: .recent)
                            }
                        case (0..., -30...30): // right swipe
                            if viewModel.selected == .recent {
                                viewModel.setSelected(newValue: .saved)
                            } else if viewModel.selected == .saved {
                                viewModel.setSelected(newValue: .feed)
                            }
                        default: break
                    }
                }
            )
        }
    }
}

@available(iOS 16.0, *)
struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
            .environmentObject(SharedVarsBetweenTabs())
    }
}

@available(iOS 16.0, *)
extension DropletsView {
    private var topNavBar: some View {
        PillSegmentedControl(
            options: [(SelectedPage.feed, "Feed"), (SelectedPage.saved, "Saved"), (SelectedPage.recent, "Recent")],
            selection: $viewModel.selected
        )
        .padding(.horizontal, AppMetrics.screenPadding)
        .onChange(of: viewModel.selected) { newValue in
            viewModel.loadMoreQuotes()
        }
    }

    private func emptyState(icon: String, title: String, message: String) -> some View {
        let palette = sharedVars.palette
        return VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(palette.accent)
                .frame(width: 64, height: 64)
                .background(Circle().fill(palette.accent.opacity(0.16)))
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundColor(palette.text)
            Text(message)
                .font(.subheadline)
                .foregroundColor(palette.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .modifier(CardStyling(padding: 28))
        .padding(.horizontal, AppMetrics.screenPadding)
        .padding(.top, 24)
    }

    private var quotesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.getPageSpecificQuotes().isEmpty {
                    switch viewModel.selected {
                        case .feed:
                            ProgressView()
                                .tint(sharedVars.palette.accent)
                                .scaleEffect(1.3)
                                .padding(.top, 80)
                        case .saved:
                            emptyState(icon: "bookmark", title: "Nothing saved yet",
                                       message: "Tap the bookmark on any quote in your feed to keep it here.")
                        case .recent:
                            emptyState(icon: "clock.arrow.circlepath", title: "No recent quotes yet",
                                       message: "Quotes from your daily notifications will be listed here. Turn on notifications to start collecting them.")
                    }
                } else {
                    if viewModel.selected == .recent {
                        Text("Your most recent quotes from notifications.")
                            .font(.footnote)
                            .foregroundColor(sharedVars.palette.secondaryText)
                    }
                    ForEach(viewModel.getPageSpecificQuotes()) { quote in
                        SingleQuoteView(
                            quote: quote,
                            from: .standardView,
                            onBookmarkRemoved: viewModel.selected == .saved ? {
                                viewModel.removeSavedQuote(quote)
                            } : nil
                        )
                    }
                }

                Color.clear.frame(height: 1)
                    .onAppear {
                        viewModel.checkMoreQuotesNeeded()
                    }
                if viewModel.checkLimitReached() {
                    Text("You've reached the quote limit of \(DropletsViewModel.maxQuotes). Maybe take a break?")
                        .modifier(QuotesPageTextStyling())
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
    }
}
