//
//  AuthorViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Author View Model Tests", .serialized) final class AuthorViewModel_Tests {
    let mockQuote: Quote
    let mockAPIService: MockAPIService
    let sut: AuthorViewModel
	weak var weakSUT: AuthorViewModel?
    init () {
        self.mockQuote = Quote.mockQuote()
        self.mockAPIService = MockAPIService()
        self.sut = AuthorViewModel(
            quote: mockQuote,
            localQuotesService: MockLocalQuotesService(),
            apiService: mockAPIService
        )
		self.weakSUT = self.sut
    }

	deinit {
		// #expect(weakSUT == nil)
	}

    @Test func initialization() {
        // Test initial values
        #expect(sut.quotes.isEmpty)
        #expect(sut.isLoadingMore == false)
    }

    @Test func loadInitialQuotes() async {
        // Set mock response for initial load
        let mockQuotes = [mockQuote]
        mockAPIService.setQuotesByAuthorResponse(quotes: mockQuotes, error: nil)

        // Test initial loading of quotes
        #expect(sut.quotes.isEmpty)
        sut.loadInitialQuotes()

        // Wait for async loading to complete
        #expect(sut.quotes.count == mockQuotes.count)
        #expect(sut.quotes.count <= AuthorViewModel.quotesPerPage)
    }

    @Test func loadMoreQuotes() async {
        // Initial setup
        let initialQuotes = [Quote](repeating: Quote.mockQuote(), count: AuthorViewModel.quotesPerPage)
        sut.quotes = initialQuotes

        // Set mock response for additional quotes
        let additionalQuotes = [Quote.mockQuote(), Quote.mockQuote()]
        mockAPIService.setQuotesByAuthorResponse(quotes: additionalQuotes, error: nil)

        // Trigger load more quotes
        sut.loadMoreQuotes()

        // Verify additional quotes loaded
        #expect(sut.quotes.count == initialQuotes.count + additionalQuotes.count)
        #expect(sut.quotes.count <= AuthorViewModel.maxQuotes)
    }

    @Test func loadMoreQuotes_limitReached() async {
        // Set quotes to max limit to simulate reaching the limit
        let maxQuotes = [Quote](repeating: Quote.mockQuote(), count: AuthorViewModel.maxQuotes)
        sut.quotes = maxQuotes

        // Set mock response (irrelevant here as no more quotes should load)
        mockAPIService.setQuotesByAuthorResponse(quotes: [Quote.mockQuote()], error: nil)

        // Trigger load more quotes
        sut.loadMoreQuotes()

        // Expect no additional quotes to be loaded beyond maxQuotes
        #expect(sut.quotes.count == AuthorViewModel.maxQuotes)
        #expect(sut.isLoadingMore == false)
    }
}
