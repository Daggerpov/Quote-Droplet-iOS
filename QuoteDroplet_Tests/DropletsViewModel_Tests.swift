//
//  DropletsViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Droplets View Model Tests", .serialized) final class DropletsViewModel_Tests {
    let mockAPIService: MockAPIService
    let sut: DropletsViewModel
	weak var weakSUT: DropletsViewModel?
    init() {
        self.mockAPIService = MockAPIService()
        self.sut = DropletsViewModel(
            localQuotesService: MockLocalQuotesService(),
            apiService: mockAPIService
        )
		self.weakSUT = self.sut
    }

	deinit {
		// #expect(weakSUT == nil)
	}

    @Test func setSelected() {
        #expect(sut.selected == SelectedPage.feed)
        sut.setSelected(newValue: SelectedPage.recent)
        #expect(sut.selected == SelectedPage.recent)
        sut.setSelected(newValue: SelectedPage.saved)
        #expect(sut.selected == SelectedPage.saved)
    }

    @Test func getTitleText() {
        sut.setSelected(newValue: SelectedPage.feed)
        #expect(sut.getTitleText() == "Quotes Feed")
        sut.setSelected(newValue: SelectedPage.saved)
        #expect(sut.getTitleText() == "Saved Quotes")
        sut.setSelected(newValue: SelectedPage.recent)
        #expect(sut.getTitleText() == "Recent Quotes")
    }

    /*
    @Test func loadInitialQuotes() async throws {
        #expect(sut.quotes.isEmpty)
        #expect(sut.savedQuotes.isEmpty)
        #expect(sut.recentQuotes.isEmpty)

        let mockQuotes = [Quote.mockQuote(), Quote.mockQuote()]
        mockApiService.setQuoteByIDResponse(quotes: mockQuotes, error: nil)

        sut.loadInitialQuotes()

        #expect(sut.quotes.count > 0)
        #expect(sut.quotes.count <= sut.quotesPerPage)
    }
     */

    @Test func checkMoreQuotesNeeded() async throws {
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: DropletsViewModel.maxQuotes - 1)
        #expect(!sut.checkLimitReached())

        sut.checkMoreQuotesNeeded()

        #expect(sut.quotes.count > 0)
        #expect(sut.quotes.count <= DropletsViewModel.maxQuotes)
    }

    @Test func getPageSpecificQuotes_feed() {
        sut.setSelected(newValue: .feed)
        sut.quotes = [Quote.mockQuote(), Quote.mockQuote()]

        #expect(sut.getPageSpecificQuotes().count == sut.quotes.count)
    }

    @Test func getPageSpecificQuotes_saved() {
        sut.setSelected(newValue: .saved)
        sut.savedQuotes = [Quote.mockQuote(), Quote.mockQuote()]

        #expect(sut.getPageSpecificQuotes().count == sut.savedQuotes.count)
    }

    @Test func removeSavedQuote() {
        let keptQuote = Quote(id: 1, text: "Kept", author: nil, classification: nil, likes: nil)
        let removedQuote = Quote(id: 2, text: "Removed", author: nil, classification: nil, likes: nil)
        sut.savedQuotes = [keptQuote, removedQuote]

        sut.removeSavedQuote(removedQuote)

        #expect(sut.savedQuotes == [keptQuote])
    }

    @Test func checkLimitReached() {
        sut.setSelected(newValue: .feed)
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: DropletsViewModel.maxQuotes)

        #expect(sut.checkLimitReached())
    }

    @Test func getPageSpecificEmptyText() {
        sut.setSelected(newValue: .saved)
        let emptyText = sut.getPageSpecificEmptyText()

        #expect(emptyText == "You have no saved quotes. \n\nPlease save some from the Quotes Feed by pressing this:")
    }
}
