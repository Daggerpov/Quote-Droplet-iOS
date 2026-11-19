//
//  AuthorView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import SwiftUI
import Foundation

@available(iOS 16.0, *)
struct AuthorView: View {
    @StateObject var viewModel: AuthorViewModel
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    init(quote: Quote) {
        _viewModel = StateObject(wrappedValue: AuthorViewModel(
            quote: quote,
            localQuotesService: LocalQuotesService(),
            apiService: APIService()
        ))
    }

    var body: some View {
        let palette = sharedVars.palette
        ScrollView {
            LazyVStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("QUOTES BY")
                        .font(AppFont.eyebrow)
                        .tracking(1.4)
                        .foregroundColor(palette.accent)
                    Text(viewModel.quote.author ?? "Author")
                        .font(AppFont.screenTitle)
                        .foregroundColor(palette.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppMetrics.screenPadding)

                if viewModel.quotes.isEmpty {
                    ProgressView()
                        .tint(palette.accent)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.quotes) { quote in
                        SingleQuoteView(quote: quote, from: .authorView)
                    }
                }
                Color.clear.frame(height: 1)
                    .onAppear {
                        if !viewModel.isLoadingMore && viewModel.quotes.count < AuthorViewModel.maxQuotes {
                            viewModel.loadMoreQuotes()
                        }
                    }

                VStack(spacing: 14) {
                    Text("Missing a quote from this author? I'd greatly appreciate submissions.")
                        .font(.subheadline)
                        .foregroundColor(palette.secondaryText)
                        .multilineTextAlignment(.center)
                    SubmitView(viewModel: SubmitViewModel(apiService: viewModel.apiService))
                }
                .modifier(CardStyling(padding: 20))
                .padding(.horizontal, AppMetrics.screenPadding)

                if !viewModel.isLoadingMore {
                    if (viewModel.quotes.count >= AuthorViewModel.maxQuotes) {
                        Text("You've reached the quote limit of \(AuthorViewModel.maxQuotes). Maybe take a break?")
                            .modifier(QuotesPageTextStyling())
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .modifier(MainScreenBackgroundStyling())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Fetch initial quotes when the view appears
            viewModel.loadInitialQuotes()
            sharedVars.reloadFromDefaults()
        }
    }
}
